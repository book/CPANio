package CPANio::Schema::Result::DistributionBins;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('distribution_bins');

__PACKAGE__->add_columns(
    bin    => { data_type => 'text',    is_nullable => 0 },
    author => { data_type => 'text',    is_nullable => 0 },
    count  => { data_type => 'integer', is_nullable => 0, default_value => 0 },
);

__PACKAGE__->set_primary_key( 'bin', 'author' );

1;
