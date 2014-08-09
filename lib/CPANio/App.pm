package CPANio::App;

use Web::Simple;
use Plack::Response;

# cache the various handlers
my %handler;

# the top-level dispatcher
sub dispatch_request {

    # we're a static site, so we only do GET
    sub (GET) {

        # each top-level directory is handled by a different module
        sub (/*/...) {
            my ( $self, $top, $env ) = @_;
            my $app = $handler{$top} ||= do {
                eval { require "CPANio/App/\u$top.pm" }
                    or return Plack::Response->new(404)->finalize;
                "CPANio::App::\u$top"
                    ->new( config => $self->config )->to_psgi_app;
            };
            $app->($env);

        },

        # not found
        sub () { Plack::Response->new(404)->finalize }
    },

    # any other method is an error
    sub () { Plack::Response->new(405)->finalize }

}

1;
