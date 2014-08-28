package CPANio::Board::Bins;

use 5.010;
use strict;
use warnings;
use DateTime;
use BackPAN::Index;

use CPANio;
use CPANio::Board;
our @ISA = qw( CPANio::Board );

# CONSTANTS

my $FIRST_FILE_TIME    = 801459900;    # first file on CPAN
my $FIRST_RELEASE_TIME = 808582338;    # first well-formed distribution

# PRIVATE FUNCTIONS

sub _final_week_number {
    my $year = shift;
    state %final_week_number;

    return $final_week_number{$year} //= do {
        DateTime->new(
            year   => $year,
            month  => 12,
            day    => 31,
            hour   => 12,
            minute => 0,
            second => 0
        )->strftime('%U');
    };
}

# given an epoch time, return all the bins the dist belongs to
sub _datetime_to_bins {
    my $dt = shift;
    my ( $year, $month, $day, $week_year, $week_number ) = split / /,
        $dt->strftime('%Y %m %d %Y %U');

    # week 0 is actually the last week of the previous year
    if ( $week_number == 0 ) {
        $week_year--;
        $week_number = _final_week_number($week_year);
    }

    # all the bins for this date
    return
        month => "M$year-$month",
        week  => "W$week_year-$week_number",
        day   => "D$year-$month-$day",
        ;
}

sub _update_author_bins {
    my ($since) = @_;

    my $backpan = BackPAN::Index->new(
        cache_ttl => 3600,    # 1 hour
        backpan_index_url =>
            "http://backpan.cpantesters.org/backpan-full-index.txt.gz",
    );

    my $latest_release = $since || $FIRST_RELEASE_TIME - 1;
    my $releases
        = BackPAN::Index->new->releases->search(
        { date     => { '>', $latest_release } },
        { order_by => 'date' } );

    my %bins;
    while ( my $release = $releases->next ) {
        my $author = $release->cpanid;
        $latest_release = $release->date;
        my $dt = DateTime->from_epoch( epoch => $latest_release );
        my $i;
        $bins{$_}{$author}++ for grep ++$i % 2, _datetime_to_bins($dt);
    }

    my $bins_rs = $CPANio::schema->resultset('ReleaseBins');
    if ( $bins_rs->search( { author => { '!=' => '' } } )->count ) {  # update
        for my $bin ( keys %bins ) {
            for my $author ( keys %{ $bins{$bin} } ) {
                my $row = $bins_rs->find_or_create(
                    { author => $author, bin => $bin } );
                $row->count( ( $row->count || 0 ) + $bins{$bin}{$author} );
                $row->update;
            }
        }
    }
    else {                                                            # create
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
sub board_name { 'bins' }

sub bins_since {
    my ($class, $since) = @_;
    $since ||= $FIRST_RELEASE_TIME;
    state $Since;
    state %bins;

    # we might have already cached it
    return \%bins if defined $Since && $since eq $Since;

    # start at the beginning of the given day
    my $dt = DateTime->from_epoch( epoch => $since, time_zone => 'UTC' );
    $dt->set( hour => 0, minute => 0, second => 0 );

    # create all bins until NOW
    %bins = ();
    my $now = time;
    while ( $dt->epoch < $now ) {
        my @kv = _datetime_to_bins($dt);
        $bins{ shift @kv }{ shift @kv } = 0 while @kv;
        $dt->add( days => 1 );
    }
    $bins{$_} = [ reverse sort keys %{ $bins{$_} } ] for keys %bins;

    # cache the bins, and the argument use to generate them
    $Since = $since;

    return \%bins;
}

sub update {
    my $since = __PACKAGE__->latest_update;
    my $latest_release = _update_author_bins($since);
    __PACKAGE__->update_done($latest_release);
}

1;
