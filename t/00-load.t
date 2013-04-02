use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use_ok( 'Dancer2::Plugin::RoutePodCoverage' ) || print "Bail out!";
}

diag( "Testing Dancer2::Plugin::RoutePodCoverage $Dancer2::Plugin::RoutePodCoverage::VERSION, Perl $], $^X" );
