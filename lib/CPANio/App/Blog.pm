package CPANio::App::Blog;

use Web::Simple;
use Plack::Response;
use Path::Class;
use Text::Markdown 'markdown';

sub dispatch_request {
    my ($self) = @_;

    # check the configuration
    my $dir = dir( $self->config->{blog_dir} );
    die "blog_dir is not defined" if ! $dir;

    # various index pages
    sub (/)  { ... },

    sub (/**/)  { ... },

    # a blog post to render
    sub (/**) {
        my ( $self, $post, $env ) = @_;
        my $blog_dir = dir( $self->config->{blog_dir} );
        my $file = eval { file( $blog_dir, $post . '.md' )->resolve };
        return Plack::Response->new(404)->finalize if !$file;
        return Plack::Response->new(403)->finalize
            if !$blog_dir->contains($file);

        [   200,
            [ 'Content-type', 'text/plain' ],
            [ markdown( scalar $file->slurp ) ]
        ];
    }

}

1;
