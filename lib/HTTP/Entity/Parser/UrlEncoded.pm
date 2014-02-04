package HTTP::Entity::Parser::UrlEncoded;

use strict;
use warnings;

our $DECODE = qr/%([0-9a-fA-F]{2})/;
our %DecodeMap;
for my $num ( 0 .. 255 ) {
    my $h = sprintf "%02X", $num;
    my $chr = chr $num;
    $DecodeMap{ lc $h } = $chr;
    $DecodeMap{ uc $h } = $chr;
    $DecodeMap{ ucfirst lc $h } = $chr;
    $DecodeMap{ lcfirst uc $h } = $chr;
}

sub new {
    my $class = shift;
    bless { buffer => '' }, $class;
}

sub add {
    my $self = shift;
    if (defined $_[0]) {
        $self->{buffer} .= $_[0];
    }
}

sub finalize {
    my $self = shift;
    my @params;
    for my $pair ( split( /[&;] ?/, $self->{buffer}, -1 ) ) {
        my ($key, $val) = split /=/, $pair, 2;
        for ($key, $val) {
            if ( ! defined $_ ) { 
                push @params, '';
                next;
            }
            s/\+/\x20/gs;
            s/$DECODE/$DecodeMap{$1}/gs;
            push @params, $_;
        }
    }

    return (\@params, []);
}

1;
