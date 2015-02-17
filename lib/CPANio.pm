package CPANio;

use strict;
use warnings;
use Path::Class;
use CPANio::Schema;

my $base = file( $INC{'CPANio.pm'} )->dir->parent;

sub base_dir { dir($base) }

our $schema
    = CPANio::Schema->connect(
    "dbi:SQLite:dbname=" . $base->file( site => 'boards.sqlite' ),
    '', '', { AutoCommit => 1 } );

1;
