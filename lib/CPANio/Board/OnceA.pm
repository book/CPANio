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
sub _get_bins_for {
    my ($category) = @_;
    state %bins;

    return $bins{$category} ||= [
        $CPANio::schema->resultset('ReleaseBins')->search(
            {   author => '',
                bin    => { like => $LIKE{$category} },
            },
            { order_by => { -desc => 'bin' } }
        )->get_column('bin')->all
    ];
}

sub _find_current_chains {

    for my $category (@CATEGORIES) {

        # pick the bins for the current category
        my @bins = @{ _get_bins_for($category) };

        # only pick the users having at least a relase in the latest bins
        my @authors = $CPANio::schema->resultset('ReleaseBins')->search(
            { author => { '!=' => '' }, bin => [ @bins[ 0, 1 ] ] },
            { group_by => 'author', order_by => { -asc => 'author' } }
        )->get_column('author')->all;

        # get the list of bins for all the selected authors
        my %bins;
        push @{ $bins{ $_->author } }, $_->bin
            for $CPANio::schema->resultset('ReleaseBins')->search(
            {   author => { -in  => \@authors },
                bin    => { like => $LIKE{$category} }
            },
            { order_by => { -desc => 'bin' } }
            );

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
        my $rs = $CPANio::schema->resultset("OnceA\u$category");
        $rs->search( { contest => 'current' } )->delete();
        $rs->populate( \@entries );
    }
}

sub _find_authors_chains {
    my $schema  = $CPANio::schema;
    my $bins_rs = $schema->resultset('ReleaseBins');

    my %chains;

    for my $category (@CATEGORIES) {

        # pick the bins for the current category
        my @bins = @{ _get_bins_for($category) };

        # get the list of bins for all the authors
        my %bins;
        push @{ $bins{ $_->author } }, $_->bin
            for $bins_rs->search(
            { author => { '!=' => '' }, bin => { like => $LIKE{$category} } },
            { order_by => { -desc => 'bin' } }
            );

        # process each author's bins
        for my $author ( keys %bins ) {
            my $Bins = $bins{$author};
            my @chains;
            my $i = 0;

            # split the bins into chains
            while (@$Bins) {
                $i++ while $Bins->[0] ne $bins[$i];
                my $j = 0;
                while ( $Bins->[$j] eq $bins[$i] ) {
                    $i++;
                    $j++;
                    last if $j >= @$Bins;
                }
                my $chain = [ splice @$Bins, 0, $j ];
                push @chains, $chain if @$chain >= 2;
            }
            $bins{$author} = \@chains;
        }
    }

    return \%bins;
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
