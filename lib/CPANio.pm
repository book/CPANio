package CPANio;

use strict;
use warnings;
use Path::Class;
use CPANio::Schema;

my $base = file( $INC{'CPANio.pm'} )->dir->parent;

our $schema
    = CPANio::Schema->connect(
    "dbi:SQLite:dbname=" . $base->file( site => 'boards.sqlite' ),
    '', '', { AutoCommit => 1 } );

1;
