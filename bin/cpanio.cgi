#!/usr/bin/env perl
use FindBin;
use Path::Class;

use CPANio::App;

my $base = dir($FindBin::Bin)->parent->subdir('site');

CPANio::App->new( config => { base_dir => $base } )->run_if_script;
