use strict;
use Test::More;

use_ok $_ for qw(
    HTTP::Entity::Parser
    HTTP::Entity::Parser::JSON
    HTTP::Entity::Parser::MultiPart
    HTTP::Entity::Parser::OctetStream
    HTTP::Entity::Parser::UrlEncoded
);

done_testing;

