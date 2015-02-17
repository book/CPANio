package CPANio::App;

use 5.010;
use Web::Simple;
use Plack::Response;
use Template;
use Path::Class;

use CPANio;

# cache the various handlers
has handler => (
    is      => 'ro',
    default => sub { {} },
);

# default configuration
sub default_config {
    (   ui       => \"<html><body>\n[% content %]\n</body></html>",
        base_dir => CPANio->base_dir->subdir('site'),
    );
}

sub BUILD {
    my ($self) = @_;
    my $config = $self->config;
    my $base   = dir( $config->{base_dir} );

    # generate the rest of the config from the defaults
    $config->{"${_}_dir"} //= $base->subdir($_)
        for qw( static docs templates );

    $config->{template} //= Template->new(
        INCLUDE_PATH => $config->{templates_dir},
    );
}

# automatically load, configure and cache a sub-application handler
sub handler_for {
    my ( $self, $module, $extra ) = @_;
    return $self->handler->{$module} ||= do {
        require "CPANio/App/$module.pm";
        my $config = { %{ $self->config } };
        @{$config}{ keys %$extra } = values %$extra if $extra;
        my $class = join '::', split '/', "CPANio/App/$module";
        $class->new( config => $config )->to_psgi_app;
    };
}

# the top-level dispatcher
sub dispatch_request {

    # we're a static site, so we only do GET
    sub (GET) {
        my ($self) = @_;

        # handler for static resources
        sub (/**.*) {
            my ( $self, $static, $env ) = @_;
            my $static_dir = dir( $self->config->{static_dir} );
            my $file = eval { file( $static_dir, $static )->resolve };

            # compute the response
            return if !$file;
            return Plack::Response->new(403)->finalize
                if !$static_dir->contains($file);
            return [ 200, [], $file->openr ];
        },

        # any .html will be wrapped in the default layout
        sub (.html | / | /**/) {
            response_filter {
                my ($res) = @_;

                # do not deal with streams
                return if ref $res->[2] ne 'ARRAY';

                # only wrap text/html responses in the html layout
                my $headers = HTTP::Headers->new( @{$res->[1]} );
                return if $headers->content_type ne 'text/html';

                my $tt = $self->config->{template};
                $tt->process(
                    $self->config->{ui},
                    { content => join( '', @{ $res->[2] } ) },
                    \( my $output = "" )
                ) or die $tt->error();
                $res->[2] = [$output];
                return $res;
            }
        },

        # other handlers
        sub (/board/once-a/...) {
            my ( $self, $env ) = @_;
            $self->handler_for('Board/Regular')->($env);
        },

        # assume the requested page is a "document"
        sub (/...) {
            my ( $self, $env ) = @_;
            $self->handler_for('Document')->($env);
        },

        # not found
        sub () { Plack::Response->new(404)->finalize }
    },

    # any other method is an error
    sub () { Plack::Response->new(405)->finalize }

}

1;
