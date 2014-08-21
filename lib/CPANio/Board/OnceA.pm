package CPANio::Board::OnceA;

use 5.010;
use strict;
use warnings;
use DateTime;

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

sub _build_bins {
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
    while( $dt->epoch < $now ) {
        $bins{$_} = 0 for _datetime_to_bins($dt);
        $dt->add( days => 1 );
    }

    $CPANio::schema->resultset('OnceABins')
        ->populate( [ map +{ bin => $_ }, keys %bins ] );
}

# CLASS METHODS
sub board_name { 'once-a' }

1;
