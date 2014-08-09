package CPANio::Error;

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw( error );

# be lazy with error messages
my %response = (
    404 => 'Not Found',
    405 => 'Method Not Allowed',
);
$response{$_} = [ $_, [ 'Content-type', 'text/plain' ], ["$response{$_}\n"] ]
    for keys %response;

sub error { $response{ shift || 404 }; }

1;
