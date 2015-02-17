#!/usr/bin/env perl
use local::lib;
use FindBin;
use Path::Class;

my $base;

BEGIN {
    unshift @INC, dir($FindBin::Bin)->parent->subdir('lib')->stringify;
}

use CPANio::App;

CPANio::App->new( config => { ui => 'layout' } )
    ->run_if_script;
