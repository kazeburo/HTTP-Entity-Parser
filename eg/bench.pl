#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Entity::Parser;
use HTTP::Body;
use Benchmark qw/:all/;

my $content = 'xxx=hogehoge&yyy=aaaaaaaaaaaaaaaaaaaaa';

my $parser = HTTP::Entity::Parser->new;
$parser->register('application/x-www-form-urlencoded','HTTP::Entity::Parser::UrlEncoded');

cmpthese(timethese(-1, {
    'http_entity' => sub {
        open my $input, '<', \$content;
        my $env = {
            'psgi.input' => $input,
            'psgix.input.buffered' => 1,
            CONTENT_LENGTH => length($content),
            CONTENT_TYPE => 'application/x-www-form-urlencoded',
        };
        $parser->parse($env);
    },
    'http_body' => sub {
        open my $input, '<', \$content;
        my $body   = HTTP::Body->new( 'application/x-www-form-urlencoded', length($content) );
        $input->read( my $buffer, 8192);
        $body->add($buffer);
        $body->param;
    }
}));

__END__
Benchmark: running http_body, http_entity for at least 1 CPU seconds...
 http_body:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 36201.85/s (n=39098)
http_entity:  1 wallclock secs ( 1.10 usr +  0.01 sys =  1.11 CPU) @ 51661.26/s (n=57344)
               Rate   http_body http_entity
http_body   36202/s          --        -30%
http_entity 51661/s         43%          --

