# NAME

HTTP::Entity::Parser - PSGI compliant HTTP Entity Parser

# SYNOPSIS

    use HTTP::Entity::Parser;
    

    my $parser = HTTP::Entity::Parser->new;
    $parser->register('application/x-www-form-urlencoded','HTTP::Entity::Parser::UrlEncoded');
    $parser->register('multipart/form-data','HTTP::Entity::Parser::MultiPart');
    $parser->register('application/json','HTTP::Entity::Parser::JSON');

    sub app {
        my $env = shift;
        my ( $params, $uploads) = $parser->parse($env);
    }

# DESCRIPTION

HTTP::Entity::Parser is PSGI compliant HTTP Entity parser. It also have compatibility with [HTTP::Body](http://search.cpan.org/perldoc?HTTP::Body)
HTTP::Entity::Parser reads HTTP entity from \`psgi.input\` and parse it.
This module support application/x-www-form-urlencoded, multipart/form-data and application/json.

# LICENSE

Copyright (C) Masahiro Nagano.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Masahiro Nagano <kazeburo@gmail.com>

Tokuhiro Matsuno <tokuhirom@gmail.com>
