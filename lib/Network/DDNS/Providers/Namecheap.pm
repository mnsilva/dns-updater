package Network::DDNS::Providers::Namecheap;

use strict;
use warnings;

use URI;
use LWP::UserAgent;
use Data::Dumper;

use base qw/ Network::DDNS::Providers::Base /;

sub provider {
    return 'namecheap';
}

sub _settings {
    my $class = shift;
    my %args  = @_;
    my %settings = ();

    my $dont_die = delete( $args{'__dont_die'} ) || 0;

    for my $attr (qw/key/) {
        if ( !defined($args{$attr}) ) {
            my $msg = sprintf('"%s" provider requires "%s" setting!', $class->provider, $attr);
            die $msg unless $dont_die;
            warn $msg;
            return;
        }
        $settings{$attr} = $args{$attr};
    }

    $settings{'_service'} = {
        'protocol' => ($args{'protocol'} || 'https'),
        'server'   => ($args{'server'}   || 'dynamicdns.park-your-domain.com'),
        'port'     => ($args{'port'}     || '443'),
        'path'     => ($args{'path'}     || 'update'),
    };
    
    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0');
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
        'host'     => $self->{'host'},
        'ip'       => $ip,
        'domain'   => $self->{'domain'},
        'password' => $settings{'key'},
    );
    print Dumper(\%params);
    $url->query_form( %params, );

    my $resp = $ua->get( $url->as_string() );
    print $url->as_string();
    print $resp->decoded_content();
    return $resp->is_success();
}

1;
