package CPANio::Board;

use strict;
use warnings;
use CPANio;

sub board_name {
    my ($class) = @_;
    die "board_name not defined for $class";
}

sub latest_update {
    my ($class) = @_;
    return eval {
        $CPANio::schema->resultset('Timestamps')
            ->find( { board => $class->board_name } )->latest_update;
    } || 0;
}

sub update_done {
    my ( $class, $time ) = @_;
    $time ||= time;
    $CPANio::schema->txn_do(
        sub {
            $CPANio::schema->resultset('Timestamps')
                ->update_or_create(
                { board => $class->board_name, latest_update => $time } );
        }
    );
    return $time;
}

1;
