#!/usr/bin/perl

use strict;
use warnings;

use YAML;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Network::DDNS;

my $config_file = $ARGV[0] || "$FindBin::Bin/../etc/ddns-hosts.yml";

print "Reading: $config_file\n";

my $ddns_hosts = YAML::LoadFile( $config_file ) || die "Configuration file (${config_file}) is not a valid YAML";
die "Configuration file (${config_file}) does not set an array" if ( ref($ddns_hosts) ne 'ARRAY' );

for my $ddns_host ( @{$ddns_hosts} ) {
    if ( ref( $ddns_host ) ne 'HASH' ) {
        warn "Element from configuration is not a HASH";
        next;
    }

    my $ddns;
    $ddns = Network::DDNS->new(
        'cache_path' => "$FindBin::Bin/../data/",
        %{$ddns_host},
        'dont_die' => 1,
    );
    next unless $ddns;

    if ( !$ddns->update() ) {
        warn "Failed to update!";
    }
}
