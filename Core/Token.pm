package Core::Token;
use parent qw(Core::Object);

use 5.010;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

sub new {
	my $self = shift;
	if ($self = $self->SUPER::new($self)) {
		my $text = shift;
		$self->text($text);
	}
	return $self;
}

# Introspection

sub text {
	my $self = shift;
	if (@_) { $self->{TEXT} = shift; }
	return $self->{TEXT};
}

sub type {
	my $self = shift;
	return $self->typeForCharacter($self->text);
}

sub isMergeable {
	my $self = shift;

	my $r = 0;
	for ($self->type) {
		when(/label|num|space/) {
			$r = 1;
		}
	}
	return $r;
}

sub isMergeableWithToken {
	my $self = shift;
	my $other = shift;
	if ($self->isMergeable && $other->isMergeable) {
		return $self->type eq $other->type || ($self->type eq "label" && $other->type eq "num");
	}
	return 0;
}

sub description {
	my $self = shift;

	my $type = $self->type;
	$type .= " " x (4-length($type));
	return "<".$self." type=\e[33m".$type."\e[m text=\e[31m\"".$self->text."\"\e[m>"
}

# Mutable

sub appendText {
	my $self = shift;
	my $text = shift;

	$self->text($self->text.$text);
}

sub mergeWithToken {
	my $self = shift;
	my $other = shift;

	my $r = 0;
	if ($self->isMergeable && $self->isMergeableWithToken($other)) {
		$self->appendText($other->text);
		$r = 1;
	}
	return $r;
}

# Utility

sub typeForCharacter {
	my $self = shift;
	my $c = shift;

	my $r = "";
	given($c) {
		when(/[a-zA-Z_\$]/) {
			$r = "label";
		}
		when(/[0-9]/) {
			$r = "num";
		}
		when(/[-+\*\/%^&|!?]/) {
			$r = "op";
		}
		when(/[=<>]/) {
			$r = "comp";
		}
		when(/[()\[\]{};:,'"]/) {
			$r = "delim";
		}
		when(/[ \t]/) {
			$r = "space";
		}
		when(/[\n]/) {
			$r = "cr";
		}
		when(/[\r]/) {
			$r = "ign";
		}
		when(/[#]/) {
			$r = "macro";
		}
		default {
			$r = "else";
		}
	};

	return $r;
}

1;
