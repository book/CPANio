package CPANio::App::Document;

use Web::Simple;
use Plack::Response;
use Path::Class;
use Text::Markdown::PerlExtensions 'markdown';

sub dispatch_request {
    my ($self) = @_;

    # check the configuration
    my $doc_dir = dir( $self->config->{doc_dir} );
    die "doc_dir is not defined" if ! $doc_dir;

    # various index pages
    sub (/)  { ... },

    sub (/**/)  { ... },

    # a doc page to render
    sub (/**) {
        my ( $self, $page, $env ) = @_;
        my $file = eval { file( $doc_dir, $page . '.md' )->resolve };
        return if !$file;
        return Plack::Response->new(403)->finalize
            if !$doc_dir->contains($file);

        [   200,
            [ 'Content-type', 'text/html' ],
            [ markdown( scalar $file->slurp ) ]
        ];
    }

}

1;
