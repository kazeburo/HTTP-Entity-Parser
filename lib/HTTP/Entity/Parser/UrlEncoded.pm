package HTTP::Entity::Parser::UrlEncoded;

use strict;
use warnings;

our $DECODE = qr/%([0-9a-fA-F]{2})/;
our %DecodeMap;
for my $num ( 0 .. 255 ) {
    my $h = sprintf "%02X", $num;
    my $chr = chr $num;
    $DecodeMap{ lc $h } = $chr; #%aa
    $DecodeMap{ uc $h } = $chr; #%AA
    $DecodeMap{ ucfirst lc $h } = $chr; #%Aa
    $DecodeMap{ lcfirst uc $h } = $chr; #%aA
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
        $pair =~ y/\+/\x20/;
        my ($key, $val) = split /=/, $pair, 2;
        for ($key, $val) {
            if ( ! defined $_ ) { 
                push @params, '';
                next;
            }
            s/$DECODE/$DecodeMap{$1}/gs;
            push @params, $_;
        }
    }

    return (\@params, []);
}

1;
__END__

=encoding utf-8

=head1 NAME

HTTP::Entity::Parser::MultiPart - parser for application/x-www-form-urlencoded

=head1 SYNOPSIS

    use HTTP::Entity::Parser;
    
    my $parser = HTTP::Entity::Parser->new;
    $parser->register('application/x-www-form-urlencoded','HTTP::Entity::Parser::UrlEncoded');

=head1 DESCRIPTION

This is a parser class for application/x-www-form-urlencoded.

=head1 LICENSE

Copyright (C) Masahiro Nagano.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo@gmail.comE<gt>

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=cut


