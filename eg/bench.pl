#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Entity::Parser;
use HTTP::Body;
use Benchmark qw/:all/;

my $content = 'xxx=hogehoge&yyy=aaaaaaaaaaaaaaaaaaaaa&%E6%97%A5%E6%9C%AC%E8%AA%9E=%E3%81%AB%E3%81%BB%E3%82%93%E3%81%94&%E3%81%BB%E3%81%92%E3%81%BB%E3%81%92=%E3%81%B5%E3%81%8C%E3%81%B5%E3%81%8C';

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
 http_body:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 14339.81/s (n=15487)
http_entity:  2 wallclock secs ( 1.10 usr +  0.00 sys =  1.10 CPU) @ 65162.73/s (n=71679)
               Rate   http_body http_entity
http_body   14340/s          --        -78%
http_entity 65163/s        354%          --

