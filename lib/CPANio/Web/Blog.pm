package CPANio::Web::Blog;

sub run {
    my ( $class, $env ) = @_;
    [ 200, [ 'Content-type', 'text/plain' ], [ $env->{PATH_INFO} ] ];
}

1;
