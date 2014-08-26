package CPANio::App::Board;

use Web::Simple;
use Plack::Response;
use CPANio::Schema;
use POSIX qw( strftime );

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

        return if $category !~ /^(?:day|week|month|hour)$/;

        my $year = 1900 + (gmtime)[5];
        my $monthday = strftime "%m-%d", gmtime;
        my @contests = ( $year, 'all-time' );
        unshift @contests, 'current'
            if $category ne 'hour'
                || ( $monthday eq '08-16' || $monthday eq '08-27' );
        my $schema = $self->config->{schema};
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
                                { order_by => [ 'rank', 'author' ] }
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

        return if $category !~ /^(?:day|week|month|hour)$/;
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
                                { order_by => [ 'rank', 'author' ] }
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
