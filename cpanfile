# Create database
requires 'Path::Class';
requires 'DBIx::Class::Schema';
requires 'SQL::Translator';

# Populate database (boards)
requires 'BackPAN::Index';
requires 'DateTime';

# Populate database (refs)
requires 'YAML::Tiny';
requires 'Git::Repository';

# Run the development website
requires 'Plack';
requires 'Web::Simple';
requires 'Template';
requires 'Text::Markdown::PerlExtensions';
requires 'HTTP::Headers';

# Generate production version
requires 'App::Wallflower';
