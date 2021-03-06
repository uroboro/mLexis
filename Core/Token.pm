package Core::Token;
use parent qw(Core::Object);

use 5.010;
use strict;
use warnings;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';
use FindBin;

# Class methods

sub tokensFromFile {
    my $filename = shift;
    return mergeTokens(_allTokensFromFile($filename));
}

sub _allTokensFromFile {
    my $filename = shift;

    die "Syntax: $FindBin::Script filename\n" if !$filename;

    my $FILE;
    open(FILE, $filename) or die $!." [$filename]";

    my @tokens = ();
    my ($c, $n);
    my ($O, $L, $C) = (0, 0, 0);
    while (($n = read(FILE, $c, 1)) != 0) {
        my $token = Core::Token->new($c);
        $token->offset($O);
        $token->line($L);
        $token->column($C);
        push(@tokens, $token);
        if ($c eq "\n") {
            $L++;
            $C = 0;
        } else {
            $C++;
        }
        $O++;
    }
    close(FILE);

    return @tokens;
}

sub mergeTokens {
    my @allTokens = @_;

    my @tokens = ();
    foreach (@allTokens) {
        my $t = $tokens[$#tokens];
        if ($t && $t->isMergeableWithToken($_)) {
            $t->mergeWithToken($_);
        } else {
            push(@tokens, $_);
        }
    }
    return @tokens;
}

# Instance methods

sub new {
	my $self = shift;
	if ($self = $self->SUPER::new($self)) {
		my $text = shift;
		$self->text($text);
	}
	return $self;
}

# Logistics

sub offset {
	my $self = shift;
	if (@_) { $self->{OFFSET} = shift; }
	return $self->{OFFSET};
}

sub line {
	my $self = shift;
	if (@_) { $self->{LINE} = shift; }
	return $self->{LINE};
}

sub column {
	my $self = shift;
	if (@_) { $self->{COLUMN} = shift; }
	return $self->{COLUMN};
}

# Introspection

sub text {
	my $self = shift;
	if (@_) { $self->{TEXT} = shift; }
	return $self->{TEXT};
}

sub type {
	my $self = shift;
	my $text = $self->text;
	my $firstType = $self->typeForCharacter(substr($text, 0, 1));
	given($firstType) {
		when (/esc/) {
			return $firstType if (length($text) == 1);
			my $escapedType = $self->typeForCharacter(substr($text, -1, 1));
			return $firstType."-".$escapedType;
		}
		default {
			return $firstType;
		}
	}
}

sub isMergeable {
	my $self = shift;

	my $r = 0;
	for ($self->type) {
		when(/label|num|space/) {
			$r = 1;
		}
		when(/esc/) {
			$r = (length($self->text) == 1);
		}
	}
	return $r;
}

sub isMergeableWithToken {
	my $self = shift;
	my $other = shift;

	if ($self->type eq "esc") {
		return (length($self->text) == 1);
	}
	if ($self->isMergeable && $other->isMergeable) {
		return $self->type eq $other->type || ($self->type eq "label" && $other->type eq "num");
	}
	return 0;
}

sub description {
	my $self = shift;

	my $type = $self->type;
	$type .= " " x (4-length($type));
	my $s = 4;
	my $o = "0" x ($s-length($self->offset)).$self->offset;
	my $l = "0" x ($s-length($self->line)).$self->line;
	my $c = "0" x ($s-length($self->column)).$self->column;

	my $r = "<$self position(O:L:C)=\e[34m$o:$l:$c\e[m type=\e[33m$type\e[m text=\e[31m\"".$self->text."\"\e[m>";

	return $r;
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
		when(/[\\]/) {
			$r = "esc";
		}
		default {
			$r = "else";
		}
	};

	return $r;
}

1;
