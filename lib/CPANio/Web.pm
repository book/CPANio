package CPANio::Web;

use Web::Simple;

# be lazy with error messages
my %response = (
   404 => 'Not Found',
   405 => 'Method Not Allowed',
);
$response{$_} = [ $_, [ 'Content-type', 'text/plain' ], ["$response{$_}\n"] ]
    for keys %response;

# the top-level dispatcher
sub dispatch_request {

    # we're a static site, so we only do GET
    sub (GET) {

        # each top-level directory handled by a different module
        sub (/*/...) {
            my ( $self, $top, $env ) = @_;
            eval { require "CPANio/Web/\u$top.pm" } or return $response{404};

            sub (/*) { shift; "CPANio::Web::\u$top"->dispatch(@_) }
        },

        # not found
        sub () { $response{404} }
    },

    # any other method is an error
    sub () { $response{405} }

}

1;
