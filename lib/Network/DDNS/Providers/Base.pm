package Network::DDNS::Providers::Base;

use strict;
use warnings;

use DateTime;
use Network::IP;

our $curr_ip;

sub new {
    my $class = shift;
    my %args  = @_;

    my $dont_die = delete( $args{'dont_die'} ) || 0;
    my %setup = ( 'dont_die' => $dont_die );

    for my $attr (qw/domain host/) {
        if ( !defined($args{$attr})  || !length($args{$attr}) ) {
            my $msg = "Required attribute missing: ${attr}" ;
            die $msg unless $dont_die;
            warn $msg;
            return;
        }
        $setup{$attr} = $args{$attr};
    }

    my $settings = $args{'settings'} || {};
    if ( ref($settings) ne 'HASH' ) {
        my $msg = '"settings" attribute MUST be a hashref';
        die $msg unless $dont_die;
        warn $msg;
        return;
    }
    $setup{'settings'} = { $class->_settings(%{$settings}, '__dont_die' => $dont_die) },

    $setup{'__cache_path'} = $args{'cache_path'} || '/tmp/ddns';
    $setup{'__myip_blacklist'} = [
        'ipdetect.dnspark.com',
    ];

    return bless \%setup, $class;
}

sub settings {
    my $self = shift;
    return %{$self->{'settings'}};
}

sub _settings {
    die 'Must override "_settings" class method!';
}

sub provider {
    die 'Must override "provider" class method!';
}

sub _update {
    die 'Must override "_update" class method!';
}

sub ip {
    my $self = shift;
    return shift || $self->__curr_ip;
}

sub __curr_ip {
    my $self = shift;
    return $curr_ip if $curr_ip;

    my $ip_obj = Network::IP->new('blacklist' => $self->{'__myip_blacklist'});
    my $ip = $ip_obj->get_ip_address();

    if (!$ip) {
        warn "Unable to get current IP address.\n";
        return;
    }
    $curr_ip = $ip;
    return $curr_ip;
}

sub __prev_ip {
    my $self = shift;
    my $fh;

    open $fh, '<', $self->__file('lastip') or $fh = undef;
    return if !$fh;

    my $line = <$fh>;
    close($fh);

    return $line;
}

sub needs_update {
    my $self = shift;
    my $wanted_ip = shift;
    my $curr_ip   = $self->__prev_ip;

    if ( !$curr_ip || ($curr_ip ne $wanted_ip) ) {
        return 1;
    }
    return 0;
}

sub update {
    my $self = shift;
    my $ip   = $self->ip(@_);

    return 128 if ( !$self->needs_update( $ip ) );
    return 0 if ( !$self->_update($ip) );

    my $fh;
    open $fh, '>', $self->__file('lastip') or $fh = undef;
    print $fh sprintf('%s', $ip);
    close($fh);

    open($fh, '>>', $self->__file('history'));
    print $fh sprintf("%s,%s\n", DateTime->now->iso8601(), $ip);
    close($fh);
    return 1;
}

sub __file {
    my $self = shift;
    my $type = shift;

    return sprintf('%s/.%s.%s.%s',
        $self->{'__cache_path'},
        $self->{'host'},
        $self->{'domain'},
        $type,
    );
}

1;
