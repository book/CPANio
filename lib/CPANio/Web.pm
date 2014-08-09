package CPANio::Web;

use Web::Simple;
use CPANio::Web::Error;


# the top-level dispatcher
sub dispatch_request {

    # we're a static site, so we only do GET
    sub (GET) {

        # each top-level directory is handled by a different module
        sub (/*/...) {
            my ( $self, $top, $env ) = @_;
            eval { require "CPANio/Web/\u$top.pm" } or return error 404;

            sub (/|/*) { "CPANio::Web::\u$top"->run($env) }
        },

        # not found
        sub () { error 404 }
    },

    # any other method is an error
    sub () { error 405 }

}

1;
