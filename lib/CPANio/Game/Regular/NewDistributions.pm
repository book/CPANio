package CPANio::Game::Regular::NewDistributions;

use strict;
use warnings;

use CPANio;
use CPANio::Game::Regular;
our @ISA = qw( CPANio::Game::Regular );

# PRIVATE FUNCTIONS

sub update_author_bins {
    my ( $class, $since ) = @_;
    my %bins;
    my $latest_release;
    my $releases = $class->get_releases;
    my %seen;
    while ( my $release = $releases->next ) {
        my $author = $release->cpanid;
        $latest_release = $release->date;
        next if $seen{ $release->dist }++;
        my $dt = DateTime->from_epoch( epoch => $latest_release );
        my $i;
        $bins{$_}{$author}++
            for grep $i++ % 2, CPANio::Bins->datetime_to_bins($dt);
    }

    my $bins_rs = $CPANio::schema->resultset('DistributionBins');
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
sub game_name { 'new-distributions' }

sub resultclass_name { 'NewDistributionBins' }

sub periods {qw( month week )}

1;

__END__

=head1 NAME

CPANio::Game::Regular::NewDistributions - Compute the boards for regular distributions

=head1 SYNPOPSIS

    use CPANio::Game::Regular::NewDistributions;

    CPANio::Game::Regular::NewDistributions->update;

=head1 DESCRIPTION

This board computes the chains for "regular distributions" game, i.e. authors
who publish a new CPAN distribution (for CPAN) at least once every period.

=head2 Periods

The boards for this game are computed for the following periods:
month and week.

=head1 AUTHOR

Philippe Bruhat (BOOK), based on the work of Christopher J. Madsen (CJM)
and Neil Bowers (NEILB).

=cut
