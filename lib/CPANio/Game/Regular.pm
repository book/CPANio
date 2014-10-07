package CPANio::Game::Regular;

use 5.010;
use strict;
use warnings;

use CPANio;
use CPANio::Game;
our @ISA = qw( CPANio::Game );

use CPANio::Bins;

# CONSTANTS
my %LIKE = (
    month => 'M%',
    week  => 'W%',
    day   => 'D%',
);

sub resultclass_name {
    my ($class) = @_;
    die "resultclass_name not defined for $class";
}

# PRIVATE FUNCTIONS

sub _authors_chains {
    my ( $resultclass_name, @categories ) = @_;
    my $schema  = $CPANio::schema;
    my $bins_rs = $schema->resultset($resultclass_name);

    my %chains;
    for my $category (@categories) {

        # pick the bins for the current category
        my $bins = CPANio::Bins->bins_since()->{$category};

        # get the list of bins for all the authors
        my %bins;
        push @{ $bins{ $_->author } }, $_->bin
            for $bins_rs->search(
            { author => { '!=' => '' }, bin => { like => $LIKE{$category} } },
            { order_by => { -desc => 'bin' } }
            );

        # process each author's bins
        for my $author ( keys %bins ) {
            my $Bins = delete $bins{$author};
            my @chains;
            my $i = 0;

            # split the bins into chains
            while (@$Bins) {
                $i++ while $Bins->[0] ne $bins->[$i];
                my $j = 0;
                while ( $Bins->[$j] eq $bins->[$i] ) {
                    $i++;
                    $j++;
                    last if $j >= @$Bins;
                }
                my $chain = [ splice @$Bins, 0, $j ];
                push @chains, $chain if @$chain >= 2;
            }
            $bins{$author} = \@chains if @chains;
        }
        $chains{$category} = \%bins;
    }

    return \%chains;
}

sub _commit_entries {
    my ( $category, $contest, $entries ) = @_;

    # compute rank
    my $Rank = my $rank = my $prev = 0;
    my %seen;
    for my $entry (@$entries) {
        $Rank++ unless $seen{ $entry->{author} }++    # rank each author once
                || ( $entry->{fallen} && $contest eq 'current' );
        $rank          = $Rank if $entry->{count} != $prev;
        $prev          = $entry->{count};
        $entry->{rank} = $rank;
    }

    # update database
    my $rs = $CPANio::schema->resultset("OnceA\u$category");
    $rs->search( { contest => $contest } )->delete();
    $rs->populate($entries);
}

sub _compute_boards_current {
    my ( $chains, $game, $category ) = @_;

    # pick the bins for the current category
    my $bins = CPANio::Bins->bins_since()->{$category};

    # only keep the active chains
    my @entries;
    for my $author ( keys %{ $chains->{$category} } ) {
        my $chain = $chains->{$category}{$author}[0];    # current chain only
        if (   $chain->[0] eq $bins->[0]
            || $chain->[0] eq $bins->[1]
            || $chain->[0] eq $bins->[2] )
        {
            push @entries, {
                game    => $game,
                contest => 'current',
                author  => $author,
                count   => scalar @$chain,
                safe    => 0 + ( $chain->[0] eq $bins->[0] ),
                active  => 0,
                fallen  => 0 + ( $chain->[0] eq $bins->[2] ),
                };
        }
    }

    # sort chains
    @entries = sort { $b->{count} <=> $a->{count} || $a->{fallen} <=> $b->{fallen} }
        grep $_->{count} >= 2,
        @entries;

    _commit_entries( $category, 'current', \@entries );
}

sub _compute_boards_alltime {
    my ( $chains, $game, $category ) = @_;

    # pick the bins for the current category
    my $bins = CPANio::Bins->bins_since()->{$category};

    my @entries = map {
        my $author = $_;
        my @chains = @{ $chains->{$category}{$author} };
        my $chain  = shift @chains;                  # possibly active
        {   game    => $game,
            contest => 'all-time',
            author  => $author,
            count   => scalar @$chain,
            safe    => 0 + ( $chain->[0] eq $bins->[0] ),
            active  => 0 + ( $chain->[0] eq $bins->[1] ),
            fallen  => 0 + ( $chain->[0] eq $bins->[2] ),
        },
            map +{
            game    => $game,
            contest => 'all-time',
            author  => $author,
            count   => scalar @$_,
            safe    => 0,
            active  => 0,
            fallen  => 0,
            }, @chains;
    } keys %{ $chains->{$category} };

    # sort chains, and keep only one per author
    my %seen;
    @entries = grep $seen{ $_->{author} }++ ? $_->{safe} || $_->{active} || $_->{fallen} : 1,
        sort { $b->{count} <=> $a->{count} }
        grep $_->{count} >= 2,
        @entries;

    _commit_entries( $category, 'all-time', \@entries );
}

sub _compute_boards_yearly {
    my ( $chains, $game, $category ) = @_;
    my @years = ( 1995 .. 1900 + (gmtime)[5] );

    # pick the bins for the current category
    my $bins = CPANio::Bins->bins_since()->{$category};

    for my $year (@years) {
        my @entries = map {
            my $author = $_;   # keep the sub-chains that occured during $year
            my @chains = grep @$_, map [ grep /^\w$year\b/, @$_ ],
                @{ $chains->{$category}{$author} };
            @chains
                ? do {
                my $chain = shift @chains;    # possibly active
                {   game    => $game,
                    contest => $year,
                    author  => $author,
                    count   => scalar @$chain,
                    safe    => 0 + ( $chain->[0] eq $bins->[0] ),
                    active  => 0 + ( $chain->[0] eq $bins->[1] ),
                    fallen  => 0 + ( $chain->[0] eq $bins->[2] ),
                },
                    map +{
                    game    => $game,
                    contest => $year,
                    author  => $author,
                    count   => scalar @$_,
                    safe    => 0,
                    active  => 0,
                    fallen  => 0,
                    },
                    @chains;
                }
                : ();
        } keys %{ $chains->{$category} };

        # sort chains, and keep only one per author
        my %seen;
        @entries = grep $seen{ $_->{author} }++ ? $_->{safe} || $_->{active} || $_->{fallen} : 1,
            sort { $b->{count} <=> $a->{count} }
            grep $_->{count} >= 2,
            @entries;

        _commit_entries( $category, $year, \@entries );
    }
}

# VIRTUAL METHODS

sub update_author_bins {
    my ($class) = @_;
    die "update_author_bins not defined for $class";
}

sub periods {
    my ($class) = @_;
    die "periods not defined for $class";
}

# CLASS METHODS

sub latest_bins_update {
    my $class = shift;
    my $bin = $CPANio::schema->resultset( $class->resultclass_name )
        ->search( { bin => { like => 'D%' } } )->get_column('bin')->max;
    return $bin
        ? CPANio::Bins->bin_to_epoch($bin)
        : $CPANio::Bins::FIRST_RELEASE_TIME;
}

sub get_releases {
    my $class = shift;

    my $backpan = BackPAN::Index->new(
        cache_ttl => 3600,    # 1 hour
        backpan_index_url =>
            "http://backpan.cpantesters.org/backpan-full-index.txt.gz",
    );

    return BackPAN::Index->new->releases->search(
        { date     => { '>', $class->latest_bins_update } },
        { order_by => 'date' } );
}

sub update_boards {
    my ( $class, @categories ) = @_;

    # pick up all the chains
    my $chains = _authors_chains( $class->resultclass_name, @categories );

    # compute all contests
    for my $category (@categories) {
        _compute_boards_current( $chains, $class->game_name, $category );
        _compute_boards_alltime( $chains, $class->game_name, $category );
        _compute_boards_yearly( $chains, $class->game_name, $category );
    }
}

sub update {
    my ($class) = @_;
    $class->update_author_bins();
    $class->update_boards( $class->periods );
    $class->update_done();
}
1;