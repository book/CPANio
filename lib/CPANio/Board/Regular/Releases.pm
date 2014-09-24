package CPANio::Board::Regular::Releases;

use strict;
use warnings;

use CPANio;
use CPANio::Board::Regular;
our @ISA = qw( CPANio::Board::Regular );

# PRIVATE FUNCTIONS

sub update_author_bins {
    my ( $class, $since ) = @_;
    my %bins;
    my $latest_release;
    my $releases = __PACKAGE__->get_releases;
    while ( my $release = $releases->next ) {
        my $author = $release->cpanid;
        $latest_release = $release->date;
        my $dt = DateTime->from_epoch( epoch => $latest_release );
        my $i;
        $bins{$_}{$author}++
            for grep $i++ % 2, CPANio::Bins->datetime_to_bins($dt);
    }

    my $bins_rs = $CPANio::schema->resultset('ReleaseBins');
    if ( $bins_rs->count ) {    # update
        for my $bin ( keys %bins ) {
            for my $author ( keys %{ $bins{$bin} } ) {
                my $row = $bins_rs->find_or_create(
                    { author => $author, bin => $bin } );
                $row->count( ( $row->count || 0 ) + $bins{$bin}{$author} );
                $row->update;
            }
        }
    }
    else {                      # create
        $bins_rs->populate(
            [   map {
                    my $bin = $_;
                    map +{
                        bin    => $bin,
                        author => $_,
                        count  => $bins{$bin}{$_}
                        },
                        keys %{ $bins{$bin} }
                    } keys %bins
            ]
        );
    }

    return $latest_release;
}

# CLASS METHODS
sub board_name { 'releases' }

sub resultclass_name { 'ReleaseBins' }

sub periods {qw( month week day )}

1;

__END__

=head1 NAME

CPANio::Board::Regular::Releases - Compute the board for regular releases

=head1 SYNPOPSIS

    use CPANio::Board::Regular::Releases;

    CPANio::Board::Regular::Releases->update;

=head1 DESCRIPTION

This board computes the chains for "regular releases", i.e. authors who
publish a new CPAN release at least once every period.

=head2 Periods

This board is computed for every month, week and day.

=head1 AUTHOR

Philippe Bruhat (BOOK), based on the work of Christopher J. Madsen (CJM)
and Neil Bowers (NEILB).

=cut
