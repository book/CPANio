#!/usr/bin/env perl
use FindBin;
use Path::Class;

use CPANio::App;

my $base   = dir($FindBin::Bin)->parent->subdir('site');
my $config = {
    static_dir => $base->subdir('static'),
    blog_dir   => $base->subdir('blog'),
};

CPANio::App->new( config => $config )->run_if_script;
