package HTTP::Entity::Parser;

use 5.008005;
use strict;
use warnings;
use Stream::Buffered;
use HTTP::Entity::Parser::OctetStream;
use Module::Load;

our $VERSION = "0.01";

# This Parser is based on tokuhirom's code
# see https://github.com/plack/Plack/pull/434

sub new {
    my $class = shift;
    bless { handlers => [] }, $class;
}

sub register {
    my ($self, $content_type, $klass, $opts) = @_;
    load $klass;
    push @{$self->{handlers}}, [$content_type, $klass, $opts];
}

sub get_parser {
    my ($self, $env) = @_;

    if (defined $env->{CONTENT_TYPE}) {
        for my $handler (@{$self->{handlers}}) {
            if (index($env->{CONTENT_TYPE}, $handler->[0]) == 0) {
                return $handler->[1]->new($env, $handler->[2]);
            }
        }
    }
    return HTTP::Entity::Parser::OctetStream->new();
}

sub parse {
    my ($self, $env) = @_;

    my $parser = $self->get_parser($env);

    my $ct = $env->{CONTENT_TYPE};
    if (!$ct) {
        # No Content-Type
        return ([], []);
    }

    my $input = $env->{'psgi.input'};

    my $buffer;
    if ($env->{'psgix.input.buffered'}) {
        # Just in case if input is read by middleware/apps beforehand
        $input->seek(0, 0);
    } else {
        $buffer = Stream::Buffered->new();
    }

    my $chunked = do { no warnings; lc delete $env->{HTTP_TRANSFER_ENCODING} eq 'chunked' };
    if ( my $cl = $env->{CONTENT_LENGTH} ) {
        my $spin = 0;
        while ($cl > 0) {
            $input->read(my $chunk, $cl < 8192 ? $cl : 8192);
            my $read = length $chunk;
            $cl -= $read;
            $parser->add($chunk);
            $buffer->print($chunk) if $buffer;
            
            if ($read == 0 && $spin++ > 2000) {
                Carp::croak "Bad Content-Length: maybe client disconnect? ($cl bytes remaining)";
            }
        }
    }
    elsif ($chunked) {
        my $chunk_buffer = '';
        my $length;
        DECHUNK: while(1) {
            $input->read(my $chunk, 8192);
            $chunk_buffer .= $chunk;
            while ( $chunk_buffer =~ s/^(([0-9a-fA-F]+).*\015\012)// ) {
                my $trailer   = $1;
                my $chunk_len = hex $2;
                if ($chunk_len == 0) {
                    last DECHUNK;
                } elsif (length $chunk_buffer < $chunk_len + 2) {
                    $chunk_buffer = $trailer . $chunk_buffer;
                    last;
                }
                my $loaded = substr $chunk_buffer, 0, $chunk_len, '';
                $parser->add($loaded);
                $buffer->print($loaded);
                $chunk_buffer =~ s/^\015\012//;
                $length += $chunk_len;                        
            }
        }
        $env->{CONTENT_LENGTH} = $length;
    }

    if ($buffer) {
        $env->{'psgix.input.buffered'} = 1;
        $env->{'psgi.input'} = $buffer->rewind;
    } else {
        $input->seek(0, 0);
    }

    $parser->finalize();
}

1;
__END__

=encoding utf-8

=head1 NAME

HTTP::Entity::Parser - It's new $module

=head1 SYNOPSIS

    use HTTP::Entity::Parser;

=head1 DESCRIPTION

HTTP::Entity::Parser is ...

=head1 LICENSE

Copyright (C) Masahiro Nagano.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo@gmail.comE<gt>

=cut

