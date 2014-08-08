package CPANio::Web;

use Web::Simple;

sub dispatch_request {

    sub (GET) {
        [ 200, [ 'Content-type', 'text/plain' ], [ "Hello world!\n" ] ]
    },
    sub () {
        [ 405, [ 'Content-type', 'text/plain' ], [ "Method not allowed\n" ] ]
    }

}

1;
