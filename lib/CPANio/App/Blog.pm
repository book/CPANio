package CPANio::App::Blog;

use Web::Simple;
use Plack::Response;
use Path::Class;
use Text::Markdown 'markdown';

sub dispatch_request {
    my ($self) = @_;

    # various index pages
    sub (/)  { ... },

    sub (/**/)  { ... },

    # a blog post to render
    sub (/**) {
        my ( $self, $post, $env ) = @_;
        my $file = file( $self->config->{blog_dir}, $post . '.md' );
        return Plack::Response->new(404)->finalize if !-e $file;

        [   200,
            [ 'Content-type', 'text/plain' ],
            [ markdown( scalar $file->slurp ) ]
        ];
    }

}

1;
