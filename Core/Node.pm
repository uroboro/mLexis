package Core::Node;
use parent qw(Core::Object);

use 5.010;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

sub new {
	my $self = shift;
	if ($self = $self->SUPER::new($self)) {
		my $type = shift;
		$self->type($type);
		my $text = shift;
		$self->text($text) if defined($text);
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

sub copyMetadataFromToken {
	my $self = shift;
	my $token = shift;

	$self->offset($token->offset);
	$self->line($token->line);
	$self->column($token->column);
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

sub description {
	my $self = shift;
	my $style = shift;
	my $level = (shift || 0);
	my $r = "";

	if ($self->type eq "root") {
	    my @ast = @{$self->nodes};
	    foreach (@ast) {
	        say $_->description($style);
	    }
		return;
	}
	my $type = $self->type;
	my $tab = "\t" x $level;
	if ($style eq "xml") {
		$type .= " " x (5-length($type));
		my $content = "";
		if ($self->isContainer) {
			$content = "nodes=".$self->text."\n\t$tab".join("\n\t$tab", map {$_->description($style, $level + 1)} @{$self->nodes})."\n$tab".$self->pairForNode;
		} else {
			if ($self->text =~ /\n/) {
				$content = "text=".($self->text =~ s/\n/\\n/r);
			} elsif ($self->text =~ /\t/) {
				$content = "text=".($self->text =~ s/\t/\\t/r);
			} else {
				$content = "text=\"".$self->text."\"";
			}
		}

		my $s = 4;
		my $o = "0" x ($s-length($self->offset)).$self->offset;
		my $l = "0" x ($s-length($self->line)).$self->line;
		my $c = "0" x ($s-length($self->column)).$self->column;

		$r = "<$self position(O:L:C)=\e[34m$o:$l:$c\e[m type=\e[33m$type\e[m $content>";
	} elsif ($style eq "json") {
		if ($self->isContainer) {
			$r = $self->text."\n\t$tab".join(" | ", map {$_->description($style, $level + 1)} @{$self->nodes})."\n$tab".$self->pairForNode;
		} else {
			if ($type =~ /space|cr/) {
				return;
			} else {
				$r = "\"".$self->text."\"";
			}
		}
	}
	return $r;
}

# Mutable

# sub addSubnode {
# 	my $self = shift;
# 	my $token = shift;
#
# 	if ($self->isContainer) {
# 		push(@{$self->{SUBNODES}}, $token);
# 	}
# }

# Utility

# sub typeFromToken {
# 	my $self = shift;
# 	my $token = shift;
#
# 	my $r = "";
# 	given($token->type) {
# 		when(/label/) {
# 			$r = "label";
# 		}
# 		when(/num/) {
# 			$r = "num";
# 		}
# 		when(/op/) {
# 			given ($token->text) {
# 				when (/[-]/) {
# 					$r = "minus";
# 				}
# 				when (/[+]/) {
# 					$r = "plus";
# 				}
# 				when (/[\*]/) {
# 					$r = "prod";
# 				}
# 				when (/[%]/) {
# 					$r = "mod";
# 				}
# 				when (/[\^]/) {
# 					$r = "pow";
# 				}
# 				when (/[&]/) {
# 					$r = "and";
# 				}
# 				when (/[|]/) {
# 					$r = "or";
# 				}
# 				when (/[!]/) {
# 					$r = "excl";
# 				}
# 				when (/[?]/) {
# 					$r = "elvis";
# 				}
# 			}
# 		}
# 		when(/comp/) {
# 			given ($token->text) {
# 				when (/[=]/) {
# 					$r = "idem";
# 				}
# 				when (/[<]/) {
# 					$r = "less";
# 				}
# 				when (/[>]/) {
# 					$r = "more";
# 				}
# 			}
# 		}
# 		when(/del/) {
# 			given ($token->text) {
# 				when (/[()\[\]{}]/) {
# 					$r = "container";
# 				}
# 				when (/["]/) {
# 					$r = "string";
# 				}
# 				when (/[']/) {
# 					$r = "char";
# 				}
# 				default {
# 					$r = "del";
# 				}
# 			}
# 		}
# 		default {
# 			$r = $_;
# 		}
# 	}
#
# 	return $r;
# }

1;
