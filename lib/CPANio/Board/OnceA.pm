package CPANio::Board::OnceA;

use 5.010;
use strict;
use warnings;

use CPANio;
use CPANio::Board;
our @ISA = qw( CPANio::Board );

use CPANio::Board::Bins;

# CONSTANTS
my %LIKE = (
    month => 'M%',
    week  => 'W%',
    day   => 'D%',
);

# PRIVATE FUNCTIONS

sub _find_authors_chains {
    my ( $board, @categories ) = @_;
    my $schema  = $CPANio::schema;
    my $bins_rs = $schema->resultset("\u${board}Bins");

    my %chains;
    for my $category (@categories) {

        # pick the bins for the current category
        my $bins = CPANio::Board::Bins->bins_since()->{$category};

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
    for my $entry (@$entries) {
        $Rank++ unless $entry->{fallen} && $contest eq 'current';
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
    my ( $chains, $category ) = @_;

    # pick the bins for the current category
    my $bins = CPANio::Board::Bins->bins_since()->{$category};

    # only keep the active chains
    my @entries;
    for my $author ( keys %{ $chains->{$category} } ) {
        my $chain = $chains->{$category}{$author}[0];    # current chain only
        if (   $chain->[0] eq $bins->[0]
            || $chain->[0] eq $bins->[1]
            || $chain->[0] eq $bins->[2] )
        {
            push @entries, {
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
    @entries = sort { $b->{count} <=> $a->{count} }
        grep $_->{count} >= 2,
        @entries;

    _commit_entries( $category, 'current', \@entries );
}

sub _compute_boards_alltime {
    my ( $chains, $category ) = @_;

    # pick the bins for the current category
    my $bins = CPANio::Board::Bins->bins_since()->{$category};

    my @entries = map {
        my $author = $_;
        my @chains = @{ $chains->{$category}{$author} };
        my $chain  = shift @chains;                  # possibly active
        {   contest => 'all-time',
            author  => $author,
            count   => scalar @$chain,
            safe    => 0 + ( $chain->[0] eq $bins->[0] ),
            active  => 0 + ( $chain->[0] eq $bins->[1] ),
            fallen  => 0 + ( $chain->[0] eq $bins->[2] ),
        },
            map +{
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
    @entries = grep !$seen{ $_->{author} }++,
        sort { $b->{count} <=> $a->{count} }
        grep $_->{count} >= 2,
        @entries;

    _commit_entries( $category, 'all-time', \@entries );
}

sub _compute_boards_yearly {
    my ( $chains, $category ) = @_;
    my @years = ( 1995 .. 1900 + (gmtime)[5] );

    # pick the bins for the current category
    my $bins = CPANio::Board::Bins->bins_since()->{$category};

    for my $year (@years) {
        my @entries = map {
            my $author = $_;   # keep the sub-chains that occured during $year
            my @chains = grep @$_, map [ grep /^\w$year\b/, @$_ ],
                @{ $chains->{$category}{$author} };
            @chains
                ? do {
                my $chain = shift @chains;    # possibly active
                {   contest => $year,
                    author  => $author,
                    count   => scalar @$chain,
                    safe    => 0 + ( $chain->[0] eq $bins->[0] ),
                    active  => 0 + ( $chain->[0] eq $bins->[1] ),
                    fallen  => 0 + ( $chain->[0] eq $bins->[2] ),
                },
                    map +{
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
        @entries = grep !$seen{ $_->{author} }++,
            sort { $b->{count} <=> $a->{count} }
            grep $_->{count} >= 2,
            @entries;

        _commit_entries( $category, $year, \@entries );
    }
}

sub _update_board {
    my ( $board, @categories ) = @_;

    # pick up all the chains
    my $chains = _find_authors_chains( $board, @categories );

    # compute all contests
    for my $category (@categories) {
        _compute_boards_current( $chains, $category );
        _compute_boards_alltime( $chains, $category );
        _compute_boards_yearly( $chains, $category );
    }
}

# CLASS METHODS
sub board_name { 'once-a' }

sub update {
    my $since = __PACKAGE__->latest_update;

    # we depend on the bins
    return if $since > CPANio::Board::Bins->latest_update;

    # do all the boards
    _update_board( release => qw( month week day ) );    # regulars

    __PACKAGE__->update_done();
}

1;
