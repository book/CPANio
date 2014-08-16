package CPANio::App::Document;

use Web::Simple;
use Plack::Response;
use Path::Class;
use Text::Markdown::PerlExtensions 'markdown';

sub dispatch_request {
    my ($self) = @_;

    # check the configuration
    my $docs_dir = dir( $self->config->{docs_dir} );
    die "docs_dir is not defined" if ! $docs_dir;

    # various index pages
    sub (/)  { redispatch_to '/index.html' },

    sub (/**/)  { redispatch_to "/$_[1]/index.html" },

    # a document page to render
    sub (/**) {
        my ( $self, $page, $env ) = @_;
        my $file = eval { file( $docs_dir, $page . '.md' )->resolve };
        return if !$file;
        return Plack::Response->new(403)->finalize
            if !$docs_dir->contains($file);

        [   200,
            [ 'Content-type', 'text/html' ],
            [ markdown( scalar $file->slurp ) ]
        ];
    }

}

1;
