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
		'ip-adress.com' => {
			'url'    => 'http://www.ip-adress.com/',
			'regexp' => qr/My IP address: +(([0-9]{1,3}\.){3}[0-9]{1,3})/m,
		},
		'ipdetect.dnspark.com' => {
			'url'    => 'http://ipdetect.dnspark.com/',
    			'regexp' => qr/Current Address: +(([0-9]{1,3}\.){3}[0-9]{1,3})/m,
		},
	);

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

		my ($ip) = $resp->{'_content'} =~ $srv->{'regexp'};
		return $ip if ($ip);
	}

	return;
}

1;
