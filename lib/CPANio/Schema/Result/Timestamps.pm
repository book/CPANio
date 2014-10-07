package CPANio::Schema::Result::Timestamps;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('timestamps');

__PACKAGE__->add_columns(
    game          => { data_type => 'text',     is_nullable => 0 },
    latest_update => { data_type => 'datetime', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('game');

1;
