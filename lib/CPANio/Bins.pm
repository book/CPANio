package CPANio::Bins;

use 5.010;
use strict;
use warnings;
use DateTime;
use BackPAN::Index;

use CPANio;

# CONSTANTS

our $FIRST_FILE_TIME    = 801459900;    # first file on CPAN
our $FIRST_RELEASE_TIME = 808582338;    # first well-formed distribution

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

# CLASS METHODS

# given an epoch time, return all the bins the dist belongs to
sub datetime_to_bins {
    my ( $class, $dt ) = @_;
    my ( $year, $month, $day, $week_year, $week_number ) = split / /,
        $dt->strftime('%Y %m %d %Y %U');

    # week 0 is actually the last week of the previous year
    if ( $week_number == 0 ) {
        $week_year--;
        $week_number = _final_week_number($week_year);
    }

    # all the bins for this date
    return
        month => "M$year-$month",               # month
        week  => "W$week_year-$week_number",    # week
        day   => "D$year-$month-$day",          # day
        ;
}

sub bin_to_epoch {
    my ( $class, $bin ) = @_;
    my ($type) = substr( $bin, 0, 1 );
    my ($date) = substr( $bin, 1 );

    my %fmt = (
        M => [ qw( year month ) ],
        D => [ qw( year month day ) ],
    );
    die "Don't know how to convert $bin to epoch" if !exists $fmt{$type};

    my %args = (
        year   => '?',
        month  => '?',
        day    => 1,
        hour   => 0,
        minute => 0,
        second => 0,
    );
    @args{ @{$fmt{$type}} } = split /-/, $date;

    return DateTime->new( %args )->epoch;
}

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
        my @kv = $class->datetime_to_bins($dt);
        $bins{ shift @kv }{ shift @kv } = 0 while @kv;
        $dt->add( days => 1 );
    }
    $bins{$_} = [ reverse sort keys %{ $bins{$_} } ] for keys %bins;

    # cache the bins, and the argument used to generate them
    $Since = $since;

    return \%bins;
}

1;
