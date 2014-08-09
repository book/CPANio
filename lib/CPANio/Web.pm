package CPANio::Web;

use Web::Simple;
use Plack::Response;


# the top-level dispatcher
sub dispatch_request {

    # we're a static site, so we only do GET
    sub (GET) {

        # each top-level directory is handled by a different module
        sub (/*/...) {
            my ( $self, $top, $env ) = @_;
            eval { require "CPANio/Web/\u$top.pm" }
                or return Plack::Response->new(404)->finalize;

            sub (/|/*) { "CPANio::Web::\u$top"->run($env) }
        },

        # not found
        sub () { Plack::Response->new(404)->finalize }
    },

    # any other method is an error
    sub () { Plack::Response->new(405)->finalize }

}

1;
