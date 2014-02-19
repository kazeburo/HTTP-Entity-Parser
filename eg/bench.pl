#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Entity::Parser;
use HTTP::Body;
use Benchmark qw/:all/;

my $content1 = 'xxx=hogehoge&yyy=aaaaaaaaaaaaaaaaaaaaa';

my $content2 = 'xxx=hogehoge&yyy=aaaaaaaaaaaaaaaaaaaaa&%E6%97%A5%E6%9C%AC%E8%AA%9E=%E3%81%AB%E3%81%BB%E3%82%93%E3%81%94&%E3%81%BB%E3%81%92%E3%81%BB%E3%81%92=%E3%81%B5%E3%81%8C%E3%81%B5%E3%81%8C';

my $content3 = join '&', map { "$_=%E3%81%B5%E3%81%8C%E3%81%B5%E3%81%8C%E3%81%B5%E3%81%8C%E3%81%B5%E3%81%8C%E3%81%B5%E3%81%8C%E3%81%B5%E3%81%8C" } 'A'..'R';

my $parser = HTTP::Entity::Parser->new;
$parser->register('application/x-www-form-urlencoded','HTTP::Entity::Parser::UrlEncoded');

for my $content ($content1, $content2, $content3) {
    print "\n## content length => ", length($content) . "\n\n";
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
}

__END__

## content length => 38

Benchmark: running http_body, http_entity for at least 1 CPU seconds...
 http_body:  1 wallclock secs ( 1.02 usr +  0.00 sys =  1.02 CPU) @ 34132.35/s (n=34815)
http_entity:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 79643.52/s (n=86015)
               Rate   http_body http_entity
http_body   34132/s          --        -57%
http_entity 79644/s        133%          --

## content length => 177

Benchmark: running http_body, http_entity for at least 1 CPU seconds...
 http_body:  2 wallclock secs ( 1.17 usr +  0.00 sys =  1.17 CPU) @ 14137.61/s (n=16541)
http_entity:  1 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 67621.70/s (n=71679)
               Rate   http_body http_entity
http_body   14138/s          --        -79%
http_entity 67622/s        378%          --

## content length => 1997

Benchmark: running http_body, http_entity for at least 1 CPU seconds...
 http_body:  1 wallclock secs ( 1.09 usr +  0.00 sys =  1.09 CPU) @ 2054.13/s (n=2239)
http_entity:  2 wallclock secs ( 1.13 usr +  0.00 sys =  1.13 CPU) @ 29276.99/s (n=33083)
               Rate   http_body http_entity
http_body    2054/s          --        -93%
http_entity 29277/s       1325%          --
