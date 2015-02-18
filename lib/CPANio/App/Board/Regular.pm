package CPANio::App::Board::Regular;

use Web::Simple;
use Plack::Response;

use CPANio;
use CPANio::Schema;

sub _build_final_dispatcher { sub () {} }

sub dispatch_request {
    my ($self) = @_;
    my $schema = $CPANio::schema;

    my $order_by
        = [ { -asc => 'rank' }, { -desc => 'count' }, { -asc => 'author' } ];

    my @games = qw( Releases Distributions NewDistributions );
    require "CPANio/Game/Regular/$_.pm" for @games;
    my @classes = map "CPANio::Game::Regular::$_", @games;
    my %game_class = ( map +( $_->game_name => $_ ), @classes );

    # get the date of the latest release considered
    my $latest_release =
      $schema->resultset('Timestamps')
      ->find( { game => 'backpan-release' } )->latest_update;

    # show every current competition
    sub (/) {
        my $tt     = $self->config->{template};
        my $vars   = {
            latest => $latest_release,
            boards => [
                map {
                    my $game = $_->game_name;
                    map +{
                        entries =>
                            scalar $schema->resultset("OnceA\u$_")->search(
                            { game => $game, contest => 'current' },
                            { order_by => $order_by }
                            ),
                        title => "once a $_ $game",
                        url   => "$_/$game/",
                        game  => $game,
                        },
                        $_->author_periods
                    } @classes
            ],
            limit => 10,
        };

        $tt->process( 'board/once_a/index_main', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

    sub (/*/) {
        my ( $self, $period, $env ) = @_;

        my %games;
        for my $class (@classes) {
            push @{ $games{$_} }, $class->game_name
                for $class->author_periods;
        }

        return if !exists $games{$period};

        my $tt     = $self->config->{template};
        my $vars   = {
            latest => $latest_release,
            boards => [
                map +{
                    entries =>
                        scalar $schema->resultset("OnceA\u$period")->search(
                        { game     => $_,       contest => 'current', },
                        { order_by => $order_by }
                        ),
                    title => $_,
                    game  => $_,
                    url   => "$_/",
                },
                @{ $games{$period} }
            ],
            limit  => 10,
            period => $period,
        };

        $tt->process( 'board/once_a/index_period', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];

    },

    sub (/*/*/) {
        my ( $self, $period, $game, $env ) = @_;

        my $class = $game_class{$game};
        return if !$class;
        return if !grep $period eq $_, $class->author_periods;

        my $year = 1900 + (gmtime)[5];
        my @contests = ( 'current', $year, 'all-time' );
        my $tt       = $self->config->{template};
        my $vars     = {
            latest => $latest_release,
            boards => [
                map {
                    my @yearly = /^[0-9]+$/ ? (
                        url      => "$_.html",
                        previous => ( $_ > 1995  ? $_ - 1 : 'years' ),
                        next     => ( $_ < $year ? $_ + 1 : 'years' ),
                    ) : ();
                    {   entries =>
                            scalar $schema->resultset("OnceA\u$period")
                            ->search(
                            { game => $game, contest  => $_ },
                            { order_by => $order_by }
                            ),
                        title => $_,
                        game  => $game,
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

    sub (/*/*/*) {
        my ( $self, $period, $game, $year, $env ) = @_;

        my $class = $game_class{$game};
        return if !$class;
        return if !grep $period eq $_, $class->author_periods;
        return if $year !~ /^(?:199[5-9]|20[0-9][0-9]|years)$/;

        my $current = 1900 + (gmtime)[5];
        my @years   = $year ne 'years' ? $year : reverse 1995 .. $current;
        my $tt      = $self->config->{template};
        my $vars    = {
            latest => $latest_release,
            boards => [
                map {
                    my @yearly = @years == 1
                        ? ( previous => $_ > 1995     ? $_ - 1 : 'years',
                            next     => $_ < $current ? $_ + 1 : 'years' )
                        : ( url      => "$_.html" );
                    {   entries =>
                            scalar $schema->resultset("OnceA\u$period")
                            ->search(
                            { game     => $game, contest => $_ },
                            { order_by => $order_by }
                            ),
                        title => $_,
                        game  => $game,
                        @yearly,
                    }
                }
                @years
            ],
            limit    => @years == 1 ? 200 : 10,
            period   => $period,
            game     => $game,
            contests => [$year],
            year     => $year,
        };

        $tt->process( 'board/once_a/index_year', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

}

1;
