package CPANio::App::Document;

use Web::Simple;
use Plack::Response;
use Path::Class;
use Text::Markdown::PerlExtensions 'markdown';

my %process = (
    md   => sub { markdown(shift) },
    html => sub { shift },
);

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

        # pick up the source file
        my ( $file, $format );
        for my $ext (qw( html md )) {
            $format = $ext;
            $file = eval { file( $docs_dir, "$page.$ext" )->resolve };
            last if defined $file;
        }

        return if !$file;
        return Plack::Response->new(403)->finalize
            if !$docs_dir->contains($file);

        my $tt = $self->config->{template};
        $tt->process(
            $self->config->{docs_wrapper},
            { content => $process{$format}->( scalar $file->slurp ) },
            \( my $output = "" )
        ) or die $tt->error();

        [   200,
            [ 'Content-type', 'text/html' ],
            [ $output ]
        ];
    }

}

1;
