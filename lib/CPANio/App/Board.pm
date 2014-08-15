package CPANio::App::Board;

use Web::Simple;
use Plack::Response;
use CPANio::Schema;

sub dispatch_request {
    my ($self) = @_;

    # various index pages
    sub (/) {...},

    sub (/once-a/*/) {
        my ( $self, $category, $env ) = @_;

        return Plack::Response->new(404)->finalize
            if $category !~ /^(day|week|month)/;

        my $schema = $self->config->{schema};
        my $tt     = $self->config->{template};
        my $vars
            = { entries => scalar $schema->resultset("OnceA\u$category")
                ->search( { contest => 'current' }, { order_by => 'rank' } ),
            };
        $tt->process( 'board/once-a.tt', $vars, \my $output )
            or die $tt->error();

        [ 200, [ 'Content-type', 'text/html' ], [$output] ];
    }

}

1;
