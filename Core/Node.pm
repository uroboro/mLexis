package Core::Node;
use parent qw(Core::Object);

use 5.010;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

sub new {
	my $self = shift;
	if ($self = $self->SUPER::new($self)) {
		my $token = shift;

		$self->type($self->typeFromToken($token));
		$self->text($token->text);
	}

	return $self;
}

# Introspection

sub type {
	my $self = shift;
	if (@_) { $self->{TYPE} = shift; }
	return $self->{TYPE};
}

sub text {
	my $self = shift;
	if (@_) { $self->{TEXT} = shift; }
	return $self->{TEXT};
}

sub nodes {
	my $self = shift;
	if (@_) { @{$self->{SUBNODES}} = @_; }
	return $self->{SUBNODES} || [];
}

sub isArray {
	my $self = shift;

	return ($self->type eq "array");
}

sub description {
	my $self = shift;
	my $level = (shift || 0) + 1;

	my $type = $self->type;
	$type .= " " x (5-length($type));
	my $tab = "\t" x $level;
	my $content = "";
	if ($self->isArray) {
		$content = "nodes=".$self->text."\n".$tab.join("\n".$tab, map {$_->description($level)} @{$self->nodes})."\n".$self->pairForNode;
	} else {
		$content = "text=\"".$self->text."\"";
	}
	return "<".$self." type=\e[33m".$type."\e[m ".$content.">"
}

# Mutable

sub addSubnode {
	my $self = shift;
	my $token = shift;

	if ($self->isArray) {
		push(@{$self->{SUBNODES}}, $token);
	}
}

# Utility

sub typeFromToken {
	my $self = shift;
	my $token = shift;

	my $r = "";
	given($token->type) {
		when(/label/) {
			$r = "label";
		}
		when(/num/) {
			$r = "num";
		}
		when(/op/) {
			given ($token->text) {
				when (/[-]/) {
					$r = "minus";
				}
				when (/[+]/) {
					$r = "plus";
				}
				when (/[\*]/) {
					$r = "prod";
				}
				when (/[%]/) {
					$r = "mod";
				}
				when (/[\^]/) {
					$r = "pow";
				}
				when (/[&]/) {
					$r = "and";
				}
				when (/[|]/) {
					$r = "or";
				}
				when (/[!]/) {
					$r = "excl";
				}
				when (/[?]/) {
					$r = "elvis";
				}
			}
		}
		when(/comp/) {
			given ($token->text) {
				when (/[=]/) {
					$r = "idem";
				}
				when (/[<]/) {
					$r = "less";
				}
				when (/[>]/) {
					$r = "more";
				}
			}
		}
		when(/del/) {
			given ($token->text) {
				when (/[()\[\]{}]/) {
					$r = "array";
				}
				when (/["]/) {
					$r = "string";
				}
				when (/[']/) {
					$r = "char";
				}
				default {
					$r = "del";
				}
			}
		}
		default {
			$r = $_;
		}
	}

	return $r;
}

sub pairForNode {
	my $self = shift;

	given($self->text) {
		when(/\(/) {
			return ")";
		}
		when(/\[/) {
			return "]";
		}
		when(/{/) {
			return "}";
		}
		default {
			return "";
		}
	}
}

1;
