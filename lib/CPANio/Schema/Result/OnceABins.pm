package CPANio::Schema::Result::OnceABins;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('once_a_bins');

__PACKAGE__->add_columns(
    bin    => { data_type => 'text',    is_nullable => 0 },
    author => { data_type => 'text',    is_nullable => 0 },
    count  => { data_type => 'integer', is_nullable => 0 },
);

__PACKAGE__->add_unique_constraint(
    'once_a_bins_bin_author' => [ 'bin', 'author' ] );

1;
