use Test::More;
use Path::Class;
use CPANio::App;

my $dir = dir( 't', 'site' );
my $app = CPANio::App->new( config => { base_dir => $dir } );

# no methods other than GET allowed
for my $method (qw( POST PUT DELETE HEAD )) {
    my $r = $app->run_test_request( $method => '/' );
    is( $r->code, 405, "$method => 405" );
}

# these request give various errors
my @uri = (
    [ '/zlonk/'                   => 404 ],
    [ '/../fail.t'                => 404 ],
    [ '/../../fail.t'             => 403 ],    # security
    [ '/pulse/../../goodbye.html' => 403 ],    # security
);

for my $t (@uri) {
    my ( $uri, $code ) = @$t;
    my $r = $app->run_test_request( GET => $uri );
    is( $r->code, $code, "$uri => $code" )
      or diag $r->content;
}

done_testing;
