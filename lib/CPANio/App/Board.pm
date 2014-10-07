package CPANio::App::Board;

use Web::Simple;
use Plack::Response;
use CPANio::Schema;

sub _build_final_dispatcher { sub () {} }

sub dispatch_request {
    my ($self) = @_;

    my @games = qw( Releases );
    require "CPANio/Game/Regular/$_.pm" for @games;
    my @classes = map "CPANio::Game::Regular::$_", @games;
    my %game_class = ( map +( $_->game_name => $_ ), @classes );

    # show every current competition
    sub (/once-a/) {
        my $schema = $self->config->{schema};
        my $tt     = $self->config->{template};
        my $vars   = {
            boards => [
                map {
                    my $game = $_->game_name;
                    map +{
                        entries =>
                            scalar $schema->resultset("OnceA\u$_")->search(
                            { contest  => 'current' },
                            { order_by => [ 'rank', 'author' ] }
                            ),
                        title => "once a $_ $game",
                        url   => "$_/$game/",
                        },
                        $_->periods
                    } @classes
            ],
            limit => 10,
        };

        $tt->process( 'board/once_a/index_main', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

    sub (/once-a/*/) {
        my ( $self, $period, $env ) = @_;

        my %games;
        for my $class (@classes) {
            push @{ $games{$_} }, $class->game_name for $class->periods;
        }

        return if !exists $games{$period};

        my $schema = $self->config->{schema};
        my $tt     = $self->config->{template};
        my $vars   = {
            boards => [
                map +{
                    entries =>
                        scalar $schema->resultset("OnceA\u$period")->search(
                        { game     => $_,       contest => 'current', },
                        { order_by => [ 'rank', 'author' ] }
                        ),
                    title => "once a $period",
                    url   => "$_/",
                },
                @{ $games{$period} }
            ],
            limit => 10,
        };

        $tt->process( 'board/once_a/period_index', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

    sub (/once-a/*/*/) {
        my ( $self, $period, $game, $env ) = @_;

        my $class = $game_class{$game};
        return if !$class;
        return if !grep $period eq $_, $class->periods;

        my $year = 1900 + (gmtime)[5];
        my @contests = ( 'current', $year, 'all-time' );
        my $schema   = $self->config->{schema};
        my $tt       = $self->config->{template};
        my $vars     = {
            boards => [
                map {
                    my @yearly = /^[0-9]+$/ ? (
                        url => "$_.html",
                      ( previous => $_ - 1 )x!! ( $_ > 1995 ),
                      ( next     => $_ + 1 )x!! ( $_ < 1900 + (gmtime)[5] ),
                    ) : ();
                    {   entries =>
                            scalar $schema->resultset("OnceA\u$period")
                            ->search(
                            { contest  => $_ },
                            { order_by => [ 'rank', 'author' ] }
                            ),
                        title => $_,
                        @yearly,
                    }
                } @contests
            ],
            limit    => 200,
            period   => $period,
            game     => $game,
            contests => \@contests,
        };
        $tt->process( 'board/once_a/index_game', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

    sub (/once-a/*/*/*) {
        my ( $self, $period, $game, $year, $env ) = @_;

        my $class = $game_class{$game};
        return if !$class;
        return if !grep $period eq $_, $class->periods;
        return if $year !~ /^(?:199[5-9]|20[0-9][0-9])$/;

        my $schema   = $self->config->{schema};
        my $tt       = $self->config->{template};
        my $vars     = {
            boards => [
                map +{
                    entries =>
                        scalar $schema->resultset("OnceA\u$period")->search(
                        { contest  => $_ },
                        { order_by => [ 'rank', 'author' ] }
                        ),
                    title => $_,
                  ( previous => $_ - 1 )x!! ( $_ > 1995 ),
                  ( next     => $_ + 1 )x!! ( $year < 1900 + (gmtime)[5] ),
                },
                $year
            ],
            limit    => 200,
            period   => $period,
            contests => [$year],
            year     => $year,
        };

        $tt->process( 'board/once_a/index_year', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

}

1;
