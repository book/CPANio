package CPANio::Schema::Result::OnceAWeek;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('once_a_week');

__PACKAGE__->add_columns(
    contest => { data_type => 'text',    is_nullable => 0 },
    rank    => { data_type => 'integer', is_nullable => 0 },
    author  => { data_type => 'text',    is_nullable => 0 },
    count   => { data_type => 'integer', is_nullable => 0 },
    active  => { data_type => 'boolean', is_nullable => 0 },
    safe    => { data_type => 'boolean', is_nullable => 0 },
    fallen  => { data_type => 'boolean', is_nullable => 0 },
);

1;
