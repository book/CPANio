package CPANio::App::Board;

use Web::Simple;
use Plack::Response;
use CPANio::Schema;

sub _build_final_dispatcher { sub () {} }

sub dispatch_request {
    my ($self) = @_;

    my $order_by
        = [ { -asc => 'rank' }, { -desc => 'count' }, { -asc => 'author' } ];

    sub (/once-a/) {
        my $schema = $self->config->{schema};
        my $tt     = $self->config->{template};
        my $vars   = {
            boards => {
                map {
                    (   $_ => {
                            entries =>
                                scalar $schema->resultset("OnceA\u$_")
                                ->search(
                                { contest  => 'current' },
                                { order_by => $order_by },
                                ),
                            title => "once a $_",
                            url   => "$_/",
                        }
                        )
                    } qw( day week month )
            },
            limit => 10,
        };

        $tt->process( 'board/once_a/main_index', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

    sub (/once-a/*/) {
        my ( $self, $category, $env ) = @_;

        return if $category !~ /^(?:day|week|month)$/;

        my $year = 1900 + (gmtime)[5];
        my @contests = ( 'current', $year, 'all-time' );
        my $schema   = $self->config->{schema};
        my $tt       = $self->config->{template};
        my $vars     = {
            boards => {
                map {
                    my @yearly = /^[0-9]+$/ ? (
                        url => "$_.html",
                      ( previous => $_ - 1 )x!! ( $_ > 1995 ),
                      ( next     => $_ + 1 )x!! ( $_ < 1900 + (gmtime)[5] ),
                    ) : ();
                    (   $_ => {
                            entries =>
                                scalar $schema->resultset("OnceA\u$category")
                                ->search(
                                { contest  => $_ },
                                { order_by => $order_by },
                                ),
                            title => $_,
                            @yearly,
                        }
                        )
                    } @contests
            },
            limit    => 200,
            period   => $category,
            contests => \@contests,
        };
        $tt->process( 'board/once_a/category_index', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

    sub (/once-a/*/*) {
        my ( $self, $category, $year, $env ) = @_;

        return if $category !~ /^(?:day|week|month)$/;
        return if $year !~ /^(?:199[5-9]|20[0-9][0-9])$/;

        my $schema   = $self->config->{schema};
        my $tt       = $self->config->{template};
        my $vars     = {
            boards => {
                map {
                    (   $_ => {
                            entries =>
                                scalar $schema->resultset("OnceA\u$category")
                                ->search(
                                { contest  => $_ },
                                { order_by => $order_by },
                                ),
                            title => $_,
                          ( previous => $_ - 1 )x!! ( $_ > 1995 ),
                          ( next     => $_ + 1 )x!! ( $year < 1900 + (gmtime)[5] ),
                        }
                        )
                    } $year
            },
            limit    => 200,
            period   => $category,
            contests => [ $year ],
            year     => $year,
        };
        $tt->process( 'board/once_a/year_index', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

}

1;
