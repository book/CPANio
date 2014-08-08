package CPANio::Web;

use Web::Simple;

# the top-level dispatcher
sub dispatch_request {

    # we're a static site, so we only do GET
    sub (GET) {

        # each top-level directory handled by a different module
        sub (/*/...) {
            my ( $self, $top, $env ) = @_;
            eval { require "CPANio/Web/\u$top.pm" }
                or return [ 404, [ 'Content-type', 'text/plain' ], [ "Not Found" ] ];

            sub (/*) { shift; "CPANio::Web::\u$top"->dispatch(@_) }
        },

        # not found
        sub () { [ 404, [ 'Content-type', 'text/plain' ], [ "Not Found" ] ] }
    },
    sub () {
        [ 405, [ 'Content-type', 'text/plain' ], [ "Method not allowed\n" ] ]
    }

}

1;
