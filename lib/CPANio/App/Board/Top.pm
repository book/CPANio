package CPANio::App::Board::Top;

use Web::Simple;
use Plack::Response;
use CPANio::Schema;
use CPANio::Bins;
use List::MoreUtils qw( uniq );

sub _build_final_dispatcher {
    sub () { }
}

sub dispatch_request {
    my ($self) = @_;
    my $schema = $CPANio::schema;
    my $tt     = $self->config->{template};

    # useful hashes and lists
    my @games = qw( Releases Distributions NewDistributions );
    require "CPANio/Game/Regular/$_.pm" for @games;
    my @classes = map "CPANio::Game::Regular::$_", @games;
    my %game_class = ( map +( $_->game_name => $_ ), @classes );
    my %games;
    for my $class (@classes) {
        push @{ $games{$_} }, $class->game_name for $class->periods;
    }
    my @periods = uniq map $_->periods, @classes;

    # get the date of the latest release considered
    my $latest_release = $schema->resultset('Timestamps')
        ->find( { game => 'backpan-release' } )->latest_update;

    # compute common search attributes
    my %attr;
    for my $period (@periods) {

        my %bin;
        for ( [ safe => 0 ], [ active => 1 ], [ fallen => 2 ] ) {
            my %bins = CPANio::Bins->datetime_to_bins(
                DateTime->now->subtract( "${period}s" => $_->[1] ) );
            $bin{$period}{ $_->[0] } = $bins{$period};
        }

        $attr{$period} = {
            columns => [
                'bin',
                { count   => \'SUM(count)' },
                map +{ $_ => \"bin='$bin{$period}{$_}'" },
                qw( safe active fallen )
            ],
            group_by => 'bin',
            order_by => [ { -desc => \'SUM(count)' }, { -desc => 'bin' } ],
        };
    }

    # show every current competition
    sub (/) {
        my $vars = {
            latest => $latest_release,
            boards => [
                map {
                    my $class = $_;
                    my $game  = $class->game_name;
                    map +{
                        entries =>
                            $class->bins_rs($_)->search_rs( {}, $attr{$_} ),
                        title => "top $_ $game",
                        url   => "$_/$game/",
                        game  => $game,
                    },
                    $_->periods
                } @classes
            ],
            limit => 10,
        };

        $tt->process( 'board/top/index_main', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    },

    sub (/*/) {
        my ( $self, $period, $env ) = @_;

        return if !exists $games{$period};

        my $vars = {
            latest => $latest_release,
            boards => [
                map {
                    {   entries => $game_class{$_}->bins_rs($period)
                            ->search_rs( {}, $attr{$period} ),
                        title => $_,
                        game  => $_,
                        url   => "$_/",
                    }
                } @{ $games{$period} }
            ],
            limit  => 10,
            period => $period,
        };

        $tt->process( 'board/top/index_period', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];

    },

}

1;
