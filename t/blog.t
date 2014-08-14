use Test::More;
use CPANio::App::Blog;

my @uri = (
    [ 't/site',       '/pulse/hello.html', qr/Hello, world!/ ],
    [ 't/site/pulse', '/hello.html',       qr/Hello, world!/ ],
);

for my $t (@uri) {
    my ( $dir, $uri, $re ) = @$t;
    my $blog = CPANio::App::Blog->new( config => { blog_dir => $dir } );

    my $r = $blog->run_test_request( GET => $uri );
    is( $r->code, 200, "$uri OK" );
    like( $r->content, $re, "$uri =~ $re" );
}

done_testing;
