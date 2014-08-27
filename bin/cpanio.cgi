#!/usr/bin/env perl
use local::lib;
use FindBin;
use Path::Class;

my $base;

BEGIN {
    $base = dir($FindBin::Bin)->parent->subdir('site');
    unshift @INC, $base->parent->subdir('lib')->stringify;
}

use CPANio::App;

CPANio::App->new( config => { base_dir => $base, ui => 'layout' } )
    ->run_if_script;
