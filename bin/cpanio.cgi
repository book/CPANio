#!/usr/bin/env perl
use local::lib;
use FindBin;
use Path::Class;

my $base;

BEGIN {
    unshift @INC, dir($FindBin::Bin)->parent->subdir('lib')->stringify;
}

use CPANio::App;

CPANio::App->new( config => { ui => 'layout', docs_wrapper => 'document' } )
    ->run_if_script;
