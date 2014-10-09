package CPANio::Game::Regular::Releases;

use strict;
use warnings;

use CPANio;
use CPANio::Game::Regular;
our @ISA = qw( CPANio::Game::Regular );

# PRIVATE FUNCTIONS

sub compute_author_bins {
    my ( $class, $since ) = @_;
    my %bins;
    my $latest_release;
    my $releases = $class->get_releases;
    while ( my $release = $releases->next ) {
        my $author = $release->cpanid;
        $latest_release = $release->date;
        my $dt = DateTime->from_epoch( epoch => $latest_release );
        my $i;
        $bins{$_}{$author}++
            for grep $i++ % 2, CPANio::Bins->datetime_to_bins($dt);
    }

    return ( \%bins, $latest_release );
}

# CLASS METHODS
sub game_name { 'releases' }

sub resultclass_name { 'ReleaseBins' }

sub periods {qw( month week day )}

1;

__END__

=head1 NAME

CPANio::Game::Regular::Releases - Compute the boards for regular releases

=head1 SYNPOPSIS

    use CPANio::Game::Regular::Releases;

    CPANio::Game::Regular::Releases->update;

=head1 DESCRIPTION

This board computes the chains for "regular releases" game, i.e. authors
who publish a new CPAN release at least once every period.

=head2 Periods

The boards for this game are computed for the following periods:
month, week and day.

=head1 AUTHOR

Philippe Bruhat (BOOK), based on the work of Christopher J. Madsen (CJM)
and Neil Bowers (NEILB).

=cut
