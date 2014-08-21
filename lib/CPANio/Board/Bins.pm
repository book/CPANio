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
    my $dt    = shift;
    my $year  = $dt->year;
    my $month = sprintf '%02d', $dt->month;
    my $day   = sprintf '%02d', $dt->day;
    my $hour  = sprintf '%02d', $dt->hour;

    # these are needed for the weekly stuff
    my $week_number = $dt->strftime('%U');
    my $week_year   = $year;
    if ($week_number == 0) {
        $week_year--;
        $week_number = _final_week_number($week_year);
    }

    # all the bins for this date
    return                             # once-a
        "M$year-$month",               # month
        "W$week_year-$week_number",    # week
        "D$year-$month-$day",          # day
        ;
}

sub _update_empty_bins {
    my ($since) = @_;

    # start at the beginning of the given day
    my $dt = DateTime->from_epoch(
        epoch => $since || $FIRST_RELEASE_TIME,
        time_zone => 'UTC'
    );
    $dt->set( hour => 0, minute => 0, second => 0 );

    # create all bins until NOW
    my $now = time;
    my %bins;
    while ( $dt->epoch < $now ) {
        $bins{$_} = 0 for _datetime_to_bins($dt);
        $dt->add( days => 1 );
    }

    my $bins_rs = $CPANio::schema->resultset('ReleaseBins');
    if ( $bins_rs->search( { author => '' } )->count ) {    # update
        $bins_rs->update_or_create( { bin => $_, author => '' } )
            for keys %bins;
    }
    else {                                                  # create
        $bins_rs->populate( [ map +{ bin => $_ }, keys %bins ] );
    }
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
        $bins{$_}{$author}++ for _datetime_to_bins($dt);
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

sub update {
    my $since = __PACKAGE__->latest_update;
    _update_empty_bins($since);
    my $latest_release = _update_author_bins($since);
    __PACKAGE__->update_done($latest_release);
}

1;
