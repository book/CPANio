#!/usr/bin/env perl
use FindBin;
use Path::Class;

use CPANio::App;

my $base   = dir($FindBin::Bin)->parent;
my $config = {
    blog_dir => $base->subdir( 'src', 'blog' ),    # CPANio::App::Blog
};

CPANio::App->new( config => $config )->run_if_script;
