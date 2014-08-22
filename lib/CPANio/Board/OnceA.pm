package CPANio::Board::OnceA;

use 5.010;
use strict;
use warnings;

use CPANio;
use CPANio::Board;
our @ISA = qw( CPANio::Board );

# CONSTANTS
my @CATEGORIES = qw( month week day );
my %LIKE = (
    month => 'M%',
    week  => 'W%',
    day   => 'D%',
);

# PRIVATE FUNCTIONS
sub _find_current_chains {
    my $schema  = $CPANio::schema;
    my $bins_rs = $schema->resultset('ReleaseBins');

    for my $category (@CATEGORIES) {

        # pick the active bins for the current contest
        my $bins = $LIKE{$category};
        my @bins = $bins_rs->search(
            {   author => '',
                bin    => { like => $bins },
            },
            { order_by => { -desc => 'bin' } }
        )->get_column('bin')->all;

        # only pick the users having at least a relase in the latest bins
        my @authors = $schema->resultset('ReleaseBins')->search(
            { author => { '!=' => '' }, bin => [ @bins[ 0, 1 ] ] },
            { group_by => 'author', order_by => { -asc => 'author' } }
        )->get_column('author')->all;

        # get the list of bins for all the selected authors
        my %bins;
        push @{ $bins{ $_->author } }, $_->bin
            for $bins_rs->search(
            { author   => { -in   => \@authors }, bin => { like => $bins } },
            { order_by => { -desc => 'bin' } } );

        # compute each author's current chain
        my @entries;
        for my $author ( keys %bins ) {
            push @entries, my $entry = {
                author  => $author,
                contest => 'current',
                active  => 0,
            };

            ( $entry->{safe}, my $i, my $j ) = $bins{$author}[0] eq $bins[0]
                ? ( 1, 0, 0 )    # safe, count from the latest bin
                : ( 0, 1, 0 );   # not safe yet, count from penultimate bin

            # move till the end of the current chain
            ( $i++, $j++ ) while $bins[$i] eq ( $bins{$author}[$j] // '' );
            $entry->{count} = $j;
        }

        # sort chains and weed out the short ones
        @entries = sort { $b->{count} <=> $a->{count} }
            grep { $_->{count} >= 2 } @entries;

        # compute rank
        my $Rank = my $rank = my $prev = 0;
        for my $entry (@entries) {
            $Rank++;
            $rank          = $Rank if $entry->{count} != $prev;
            $prev          = $entry->{count};
            $entry->{rank} = $rank;
        }

        # update database
        my $rs = $schema->resultset("OnceA\u$category");
        $rs->search( { contest => 'current' } )->delete();
        $rs->populate( \@entries );
    }
}

# CLASS METHODS
sub board_name { 'once-a' }

sub update {
    my $since = __PACKAGE__->latest_update;

    # we depend on the bins
    require CPANio::Board::Bins;
    return if $since > CPANio::Board::Bins->latest_update;

    _find_current_chains();
    __PACKAGE__->update_done();
}

1;
