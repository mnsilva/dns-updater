package Network::DDNS::Providers::OVH;

use strict;
use warnings;

use URI;
use LWP::UserAgent;
use Data::Dumper;

use base qw/ Network::DDNS::Providers::Base /;

sub provider {
    return 'ovh';
}

sub _settings {
    my $class = shift;
    my %args  = @_;
    my %settings = ();

    my $dont_die = delete( $args{'__dont_die'} ) || 0;

    for my $attr (qw/username password/) {
        if ( !defined($args{$attr}) ) {
            my $msg = sprintf('"%s" provider requires "%s" setting!', $class->provider, $attr);
            die $msg unless $dont_die;
            warn $msg;
            return;
        }
        # $settings{$attr} = $args{$attr};
    }

    # http://www.ovh.com/nic/update?system=dyndns&hostname=$HOSTNAME&myip=$IP
    $settings{'_service'} = {
        'protocol' => ($args{'protocol'} || 'https'),
        'server'   => ($args{'server'}   || 'www.ovh.com'),
        'port'     => ($args{'port'}     || '443'),
        'path'     => ($args{'path'}     || 'nic/update'),
        'realm'    => ($args{'realm'}    || 'What is your nic handle and password ??'),
    };
    
    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0');
    $ua->credentials(
        sprintf("%s:%s", $settings{'_service'}->{'server'}, $settings{'_service'}->{'port'}),
        $settings{'_service'}->{'realm'},
        $args{'username'},
        $args{'password'},
    );
    $settings{'_ua'} = $ua;

    $settings{'_url'} = URI->new( sprintf('%s://%s:%s/%s',
        $settings{'_service'}->{'protocol'},
        $settings{'_service'}->{'server'},
        $settings{'_service'}->{'port'},
        $settings{'_service'}->{'path'},
    ), );

    return %settings;
}

sub _update {
    my $self = shift;
    my $ip   = shift;

    my %settings = $self->settings;
    my $ua  = $settings{'_ua'};
    my $url = $settings{'_url'};

    my %params = (
        'hostname' => sprintf("%s.%s", $self->{'host'}, $self->{'domain'}),
        'myip'     => $ip,
        'system'   => 'dyndns',
    );
    print Dumper(\%params);
    $url->query_form( %params, );

    my $resp = $ua->get( $url->as_string() );
    print $url->as_string() . "\n";
    my $response_body = $resp->decoded_content();
    print "$response_body\n";
    if ($resp->is_success() && $response_body =~ /^good/) {
        return 1;
    }

    return 0;
}

1;
