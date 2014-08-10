package CPANio::App;

use Web::Simple;
use Plack::Response;
use Template;

# cache the various handlers
my %handler;

# default configuration
sub default_config {
    ( ui => \"<html><body>\n[% content %]\n</body></html>", );
}

# the top-level dispatcher
sub dispatch_request {

    # we're a static site, so we only do GET
    sub (GET) {
        my ($self) = @_;

        # any .html will be wrapped in the default layout
        sub (.html) {
            response_filter {
                my ($res) = @_;

                # do not deal with streams
                return if ref $res->[2] ne 'ARRAY';

                my $tt = Template->new;
                $tt->process(
                    $self->config->{ui},
                    { content => join( '', @{ $res->[2] } ) },
                    \( my $output = "" )
                ) or die $tt->error();
                $res->[2] = [$output];
                return $res;
            }
        },

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
