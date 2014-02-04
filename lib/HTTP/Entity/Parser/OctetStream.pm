package HTTP::Entity::Parser::OctetStream;

use strict;
use warnings;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub add { }

sub finalize {
    return ([],[]);
}

1;

