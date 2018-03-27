package Core::TokenList;
use parent qw(Core::Object);

use strict;
use warnings;
use 5.010;

# Instance methods

sub new {
	my $self = shift;
	if ($self = $self->SUPER::new($self)) {
		$self->tokens(@_);
	}
	return $self;
}

# Introspection

sub tokens {
	my $self = shift;
	if (@_) { @{$self->{TOKENS}} = @_; }
	return $self->{TOKENS} || [];
}

sub tokenCount {
	my $self = shift;
	my @tokens = @{$self->tokens};
	return scalar @tokens;
}

sub peek {
	my $self = shift;
	my @tokens = @{$self->tokens};
	my $token = $tokens[0];
	return $token;
}

sub pop {
	my $self = shift;
	my @tokens = @{$self->tokens};
	my $token = shift @tokens;
	if (scalar @tokens > 0) {
		$self->tokens(@tokens);
	} else {
		$self->{TOKENS} = [];
	}
	return $token;
}

sub description {
	my $self = shift;

	my $r = "<$self count=".$self->tokenCount.">";
	return $r;
}

1;
