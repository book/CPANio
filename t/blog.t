use Test::More;
use CPANio::App::Document;

my @uri = (
    [ 't/site/docs',       '/pulse/hello.html', qr/Hello, world!/ ],
    [ 't/site/docs/pulse', '/hello.html',       qr/Hello, world!/ ],
);

for my $t (@uri) {
    my ( $dir, $uri, $re ) = @$t;
    my $app = CPANio::App::Document->new( config => { docs_dir => $dir } );

    my $r = $app->run_test_request( GET => $uri );
    is( $r->code, 200, "$uri OK" );
    like( $r->content, $re, "$uri =~ $re" );
}

done_testing;
