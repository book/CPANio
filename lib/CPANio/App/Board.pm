package CPANio::App::Board;

use Web::Simple;
use Plack::Response;
use CPANio::Schema;

sub _build_final_dispatcher { sub () {} }

sub dispatch_request {
    my ($self) = @_;

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
                                { order_by => [ 'rank', 'author' ] }
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

        return if $category !~ /^(day|week|month)/;

        my $schema = $self->config->{schema};
        my $tt     = $self->config->{template};
        my $vars   = {
            boards => {
                map {
                    (   $_ => {
                            entries =>
                                scalar $schema->resultset("OnceA\u$category")
                                ->search(
                                { contest  => $_ },
                                { order_by => [ 'rank', 'author' ] }
                                ),
                            title => $_
                        }
                        )
                    } qw( current all-times )
            },
            limit => 200,
            period => $category,
        };
        $tt->process( 'board/once_a/category_index', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

}

1;
