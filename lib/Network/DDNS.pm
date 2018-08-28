package Network::DDNS;

use strict;
use warnings;

use Module::Pluggable require => 1, search_path => [ __PACKAGE__ . "::Providers" ], except => __PACKAGE__ . '::Providers::Base';

our %providers;

sub new {
    my $class = shift;
    my %args  = @_;

    my $dont_die = $args{'dont_die'} || 0;

    for my $attr (qw/provider domain host/) {
        if ( !defined($args{$attr}) ) {
            my $msg = "Required attribute missing or empty: ${attr}";
            die $msg unless $dont_die;
            warn $msg;
            return;
        }
    }

    my $provider = delete( $args{'provider'} );
    my $module   = $class->_provider(lc($provider));
    if (!$module) {
        warn "No module for provider ${provider}";
        return;
    }
    return $module->new( %args );
}

sub _provider {
    my $class = shift;
    my $wp    = lc( shift );

    # If we already identified which provider we want to use
    return $providers{ $wp } if ( defined($providers{ $wp }) );

    # Load plugins until we find the one we need
    foreach my $plugin ($class->plugins) {
        my $provider = $plugin->provider;

        next if ( defined($providers{ $provider } ) );
        $providers{$provider} = $plugin;
        last if ( $wp eq $provider );
    }

    return $providers{ $wp }
}

1;
