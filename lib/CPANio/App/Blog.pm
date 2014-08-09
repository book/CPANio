package CPANio::App::Blog;

use Web::Simple;

sub dispatch_request {

    # various index pages
    sub (/)  { ... },

    sub (/**/)  { ... },

    # a blog post to render
    sub (/**) {
        my ( $self, $post, $env ) = @_;
        [ 200, [ 'Content-type', 'text/plain' ], [$post] ];
    }

}

1;
