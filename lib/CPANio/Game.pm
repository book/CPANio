package CPANio::Game;

use strict;
use warnings;
use CPANio;

# VIRTUAL METHODS

sub game_name {
    my ($class) = @_;
    die "board_name not defined for $class";
}

sub update {
    my ($class) = @_;
    die "update not defined for $class";
}

# METHODS

sub latest_update {
    my ($class) = @_;
    return eval {
        $CPANio::schema->resultset('Timestamps')
            ->find( { game => $class->game_name } )->latest_update;
    } || 0;
}

sub update_done {
    my ( $class, $time ) = @_;
    $time ||= time;
    $CPANio::schema->txn_do(
        sub {
            $CPANio::schema->resultset('Timestamps')
                ->update_or_create(
                { game => $class->game_name, latest_update => $time } );
        }
    );
    return $time;
}

1;
