use Test::More;
use Path::Class;
use CPANio::App;

my $dir = dir( 't', 'site' );
my $app = CPANio::App->new( config => { static_dir => $dir->subdir('static') } );

# no methods other than GET allowed
for my $method (qw( POST PUT DELETE HEAD )) {
    my $r = $app->run_test_request( $method => '/' );
    is( $r->code, 405, "$method: Method Not Allowed" );
}

# these request are all 404
for my $uri ('/zlonk/') {
    my $r = $app->run_test_request( GET => $uri );
    is( $r->code, 404, "$uri Not Found" );
}

done_testing;
