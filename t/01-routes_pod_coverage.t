use strict;
use warnings;

use Test::More tests => 3;
use Dancer2 qw(:syntax);

use t::lib::MyApp::Routes;
use t::lib::MyApp::Routes2;

use Dancer2::Plugin::RoutePodCoverage;


## test all packages
my $data_struct = {'t::lib::MyApp::Routes' => {
                    routes => [
                        ['post','/'],
                        ['get','/']
                    ],
                    undocumented_routes => [
                        ['post','/']
                    ]
                    },
                    't::lib::MyApp::Routes2' => {
                    routes => [
                        ['post','/'],
                        ['get','/']
                    ],
                    undocumented_routes => [
                        ['post','/'],
                        ['get','/']
                    ]
                    }

                   };

is_deeply(routes_pod_coverage(),$data_struct, 'route_pod_coverege');


### test t::lib::MyApp::Routes
my $data_struct_1 = {'t::lib::MyApp::Routes' => {
                    routes => [
                        ['post','/'],
                        ['get','/']
                    ],
                    undocumented_routes => [
                        ['post','/']
                    ]
                    }
                   };

packages_to_cover(['t::lib::MyApp::Routes']);
is_deeply(routes_pod_coverage(),$data_struct_1, 'route_pod_coverege');


### test t::lib::MyApp::Routes2
my $data_struct_2 = {'t::lib::MyApp::Routes2' => {
                    routes => [
                        ['post','/'],
                        ['get','/']
                    ],
                    undocumented_routes => [
                        ['post','/'],
                        ['get','/']
                    ]
                    }
                   };

packages_to_cover(['t::lib::MyApp::Routes2']);
is_deeply(routes_pod_coverage(),$data_struct_2, 'route_pod_coverege');

