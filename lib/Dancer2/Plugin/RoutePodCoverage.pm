package Dancer2::Plugin::RoutePodCoverage;

use strict;
use warnings;

use Dancer2 ':syntax';
use Dancer2::Plugin;
use Pod::Simple::Search;
use Pod::Simple::SimpleTree;
use Carp 'croak';

our $VERSION = '0.02';

my $PACKAGES_TO_COVER = [];

register 'packages_to_cover' => sub {
    my ( $dsl, $packages_to_cover ) = @_;
    croak "no package(s) provided for 'packages_to_cover' "
      if ( !$packages_to_cover
        || ref $packages_to_cover ne 'ARRAY'
        || !@$packages_to_cover );
    $PACKAGES_TO_COVER = $packages_to_cover;
};

register 'routes_pod_coverage' => sub {
    return _get_routes();
};

sub _get_routes {
    my @apps = @{ runner->server->apps };

    my $all_routes = {};

    for my $app (@apps) {
        next
          if ( @$PACKAGES_TO_COVER && !grep { $app->name eq $_ }
            @$PACKAGES_TO_COVER );
        my $routes           = $app->routes;
        my $available_routes = [];
        foreach my $method ( keys %$routes ) {
            foreach my $r ( @{ $routes->{$method} } ) {

                # we don't need pod coverage for head
                next if $method eq 'head';
                push @$available_routes, [ $method, $r->spec_route ];
            }
        }
        ## copy unreferenced array
        $all_routes->{ $app->name }{routes} = [@$available_routes]
          if @$available_routes;

        my $undocumented_routes = [];
        my $file                = Pod::Simple::Search->new->find( $app->name );
        if ($file) {
            my $parser       = Pod::Simple::SimpleTree->new->parse_file($file);
            my $pod_dataref  = $parser->root;
            my $found_routes = {};
            for ( my $i = 0 ; $i < @$available_routes ; $i++ ) {

                my $r          = $available_routes->[$i];
                my $app_string = lc $r->[0] . $r->[1];
                $app_string =~ s/\*/_REPLACED_STAR_/g;

                ## discard first 2 elements
                for ( my $idx = 2 ; $idx < @$pod_dataref ; $idx++ ) {

                    my $pod_part = $pod_dataref->[$idx];
                    next if $pod_part->[0] !~ m/head1|head2|head3|head4|over/;

                    my $pod_string = lc $pod_part->[2];
                    if ($pod_part->[0] =~ m/over/) {
                        $pod_string = lc $pod_part->[2][2];       
                    }
                    $pod_string =~ s/['|"|\s]+//g;
                    $pod_string =~ s/\*/_REPLACED_STAR_/g;
                    if ( $pod_string =~ m/^$app_string$/ ) {
                        $found_routes->{$app_string} = 1;
                        next;
                    }
                }
                if ( !$found_routes->{$app_string} ) {
                    push @$undocumented_routes, [@$r];
                }
            }
        }
        $all_routes->{ $app->name }{undocumented_routes} = $undocumented_routes
          if @$undocumented_routes;
    }
    return $all_routes;
}

register_plugin for_versions => [2];

1;

__END__

=pod

=head1 NAME

Dancer2::Plugin::RoutePodCoverage - Plugin to verify pod coverage in our app routes.

=head1 SYNOPSYS

    package MyApp::Route;

    use Dancer2;
    use Dancer2::Plugin::RoutePodCoverage;
    
    get '/' => sub {
        my $routes_couverage = routes_pod_coverage();

        # or 

        packages_to_cover(['MYAPP::Routes','MYAPP::Routes::Something']);
        my $routes_couverage = routes_pod_coverage();

    };

=head1 DESCRIPTION

Plugin to verify pod coverage in our app routes.

=head1 KEYWORDS

=head2 packages_to_cover

Keyword to define which packages to check coverage

=head2 routes_pod_coverage

Keyword that returns all routes e all undocumented routes for each package of the app or packages defined with 'packages_to_cover' 

=head1 LICENSE

This module is released under the same terms as Perl itself.

=head1 AUTHOR

Dinis Rebolo C<< <drebolo@cpan.org> >>

=cut
