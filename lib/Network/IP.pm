package Network::IP;

use strict;
use warnings;

use LWP::UserAgent;
use Data::Dumper;

sub new {
    my $class = shift;
    my %args  = @_;

    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0');

    my %services = (
        'api.ipify.org' => {
            'url'    => 'http://api.ipify.org?format=text',
            'regexp' => qr/^(([0-9]{1,3}\.){3}[0-9]{1,3})$/,
        },
        'icanhazip.com' => {
            'url'    => 'http://icanhazip.com/',
            'regexp' => qr/^(([0-9]{1,3}\.){3}[0-9]{1,3})$/,
        },
        'wtfismyip.com' => {
            'url' => 'https://wtfismyip.com/text',
            'regexp' => qr/^(([0-9]{1,3}\.){3}[0-9]{1,3})$/,
        },
        'ip-adress.com' => {
            'url'    => 'http://www.ip-adress.com/',
            'regexp' => qr/Your IP address is: <strong>(([0-9]{1,3}\.){3}[0-9]{1,3})<\/strong>/m,
        },
#        'ipdetect.dnspark.com' => {
#            'url'    => 'http://ipdetect.dnspark.com/',
#            'regexp' => qr/Current Address: +(([0-9]{1,3}\.){3}[0-9]{1,3})/m,
#        },
    );

    if ( my $bl = $args{'blacklist'} ) {
        $bl = [ $bl ] if ( !ref($bl) );
        die "Invalid blacklist" if ( ref($bl) ne 'ARRAY' );
        for my $srv (@{$bl}) {
            delete $services{ $srv };
        }
    }

    die "No IP discovery services whitelisted\n" unless %services;

    return bless {
        '_init_args' => \%args,
        '_ua'        => $ua,
        'ip_getters' => \%services,
    }, $class;
}

sub get_ip_address {
    my $self = shift;
    my %args = @_;

    for my $service (keys(%{$self->{'ip_getters'}})) {
        my $srv = $self->{'ip_getters'}->{$service};
        my $resp = $self->{'_ua'}->get($srv->{'url'});

        my ($ip) = $resp->decoded_content() =~ $srv->{'regexp'};
        return $ip if ($ip);
    }

    return;
}

1;
