#!/usr/bin/perl

package Lexis;

use 5.010;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';
use strict;
use warnings;
use Getopt::Long;
use FindBin;
use Module::Load;
use CPAN::Meta::YAML qw(LoadFile);
use Data::Dumper;

use Core::FileUtils;
# use Core::StringUtils;
# use Core::AST;
# use Core::Token;

# main

my $data   = "file.dat";
my $length = 24;
my $outputFormat = "xml";
my $verbose;
GetOptions( "length=i" => \$length,    # numeric
			"file=s"   => \$data,	   # string
			"outputFormat=s" => \$outputFormat,	   # string
			"verbose"  => \$verbose)   # flag
or die("Error in command line arguments\n");

# my $languagesDir = "./Languages/";
# my @configs = Core::FileUtils::listDirectory($languagesDir, "f");
# say "---";
# foreach (@configs) {
# 	say $languagesDir.$_;
# 	my $yml = LoadFile($languagesDir.$_);
# 	print Dumper($yml);
# }
my $yml = LoadFile("./Languages/logos.yml");
# print Dumper($yml);
# say "===";
# exit 0;

# say join(" ", map { "\033[".$_."m".$_."\033[0m"} (30, 31, 32, 33, 34, 35, 36, 37));

Core::FileUtils::loadModulesAtPath("./Core/");
# print join("\n", sort %INC)."\n\n";
foreach (@ARGV) {
	my @tokens = Core::Token::tokensFromFile($_);
	say Core::StringUtils::colorTextRed("|").join(Core::StringUtils::colorTextGreen("|"), map { $_->text } @tokens).Core::StringUtils::colorTextRed("|");
	# say join(Core::StringUtils::colorTextGreen("|"), map { $_->text if !($_->type =~ /space/) } @tokens);

	# to-do: consume tokens and make decision after, not first.
	# create node types for:
	# - comment
	# - preprocessor directive
	# - expression list
	# - expression
	# - assignment
	# - operation
	# - comparison
	# - subscript
	# - subscript
	# - string
	# - character
	# - type
	# - casting
	# - scope
	# - condition
	# - function call
	# - function definition
	# - function declaration
	my $list = Core::TokenList->new(@tokens);
	my @ast = astFromTokens($list, $yml);
	# foreach (@ast) {
	# 	my $t = Core::StringUtils::colorTextYellow("> ".$_->type)."\n";
	# 	$t .= $_->text if defined $_->text;
	# 	say $t;
	# 	if (defined($_->nodes) && scalar @{$_->nodes} > 0) {
	# 		say Core::StringUtils::colorTextGreen("> ").$_->nodes;
	# 	}
	# }
	say describeAST(1, '', @ast);

	# my $ast = Core::AST::ASTFromFile($_);
    # say "---";
	# $ast->description($outputFormat);
    # say "===";
	#
	# say "---";
	# say Core::AST::fileFromAST($ast);
	# say "===";
	# say "===";
	# findDirectives($yml);
}

sub describeNode {
	my $sublevel = shift;
	my $node = shift;

	my $tab = "    ";
	given ($node->type) {
		when (/expr/) {
			return join(' ', map { describeAST($sublevel, '', $_) } @{$node->nodes});
		}
		when (/container/) {
			my $text .= Core::StringUtils::colorTextYellow($node->text);
			$text .= "\n".($tab x $sublevel) if ($node->text eq "{");
			if (scalar @{$node->nodes} > 0) {
				my $sep = ($node->text eq "(") ? Core::StringUtils::colorTextRed(", ") : Core::StringUtils::colorTextRed(";\n").($tab x $sublevel);
				$text .= describeAST($sublevel+1, $sep, @{$node->nodes});
			}
			$text .= "\n".($tab x ($sublevel - 1)) if ($node->text eq "{");
			$text .= Core::StringUtils::colorTextYellow(pairForNode($node->text));
			return $text;
		}
		when (/comments/) {
			return Core::StringUtils::colorTextBlue("/* ".$node->text."*/")."\n";
		}
		when (/comment/) {
			return Core::StringUtils::colorTextBlue("//".$node->text);
		}
		when (/string/) {
			return Core::StringUtils::colorTextMagenta('"'.$node->text.'"');
		}
		when (/character/) {
			return Core::StringUtils::colorTextMagenta("'".$node->text."'");
		}
		when (/logos/) {
			return Core::StringUtils::colorTextGreen($node->text);
		}
		default {
			return $node->text if defined $node->text;
		}
	}
}

sub describeAST {
	my $level = shift;
	my $separator = shift;
	my @ast = @_;

	return join($separator, map { describeNode($level, $_) } @ast);

	# my $tab = ' ' x $level;
	# my $text = "";
	# foreach my $node (@ast) {
	# 	given ($node->type) {
	# 		when (/expr/) {
	# 			$text .= join(' ', map { describeAST($level, '', $_) } @{$node->nodes});
	# 		}
	# 		when (/container/) {
	# 			$text .= Core::StringUtils::colorTextYellow($node->text);
	# 			if (scalar @{$node->nodes} > 0) {
	# 				my $sep = ($node->text eq "(") ? ", " : ";\n";
	# 				$text .= describeAST($level+1, $sep, @{$node->nodes});
	# 			}
	# 			$text .= Core::StringUtils::colorTextYellow(pairForNode($node->text));
	# 			# $text .= "\n";
	# 		}
	# 		when (/comment/) {
	# 			$text .= Core::StringUtils::colorTextBlue("//".$node->text);
	# 		}
	# 		when (/string/) {
	# 			$text .= Core::StringUtils::colorTextMagenta('"'.$node->text.'"');
	# 		}
	# 		when (/character/) {
	# 			$text .= Core::StringUtils::colorTextMagenta("'".$node->text."'");
	# 		}
	# 		# when (/logos/) {
	# 		# 	$text .= $node->text;
	# 		# }
	# 		default {
	# 			$text .= $node->text if defined $node->text;
	# 		}
	# 	}
	# 	# $text .= $separator;
	# }
	# return $text;
}

sub astFromTokens {
	my $list = shift;
	my $yml = shift;

	my @buffer = ();
	my @outBuffer = ();
	my @currentExpr = ();
	my $nextToken;
	while ($list->tokenCount > 0) {
		my $token = $list->pop();
		# todo: break like `last if ! defined $token;` when consuming extra tokens
		given($token->text) {
			when(/ |\t|\n/) {
				# Ignore
			}
			when(/,|;/) {
		        my $node = Core::Node->new('expr', $_);
				$node->nodes(@currentExpr);
				push(@outBuffer, $node);
				@currentExpr = ();
			}
			when(/%/) {
				$nextToken = $list->peek();
				my %syntax = %{$yml->{'syntax'}};
				if (defined %syntax->{$nextToken->text}) {
					$token = $list->pop();

					my $text = "%".$token->text;
					my $node = Core::Node->new('logos', $text);
					push(@currentExpr, $node);
				} else {
					my $text = $_;
			        my $node = Core::Node->new('other', $text);
					push(@currentExpr, $node);
				}
			}
			when(/"|'/) {
				while (1) {
					$token = $list->pop();
					last if ($token->text eq $_);
					push(@buffer, $token);
				}

				my $text = join('', map { $_->text } @buffer);
				my $node = Core::Node->new(($_ eq '"') ? 'string' : 'character', $text);
				push(@currentExpr, $node);
				@buffer = ();
			}
			when(/\//) {
				$nextToken = $list->peek();

				if ($nextToken->text eq '/') {
					$list->pop(); # pop '/'
					while (1) {
						$token = $list->pop();
						last if ($token->type eq "cr");
						push(@buffer, $token);
					}

					my $text = join('', map { $_->text } @buffer);
			        my $node = Core::Node->new('comment', $text);
					push(@outBuffer, $node);
					@buffer = ();
				} elsif ($nextToken->text eq '*') {
					$list->pop(); # pop '*'
					while (1) {
						$token = $list->pop();
						$nextToken = $list->peek();
						last if ($token->text eq "*" && $nextToken->text eq "/");
						push(@buffer, $token);
					}
					$list->pop(); # pop '/'

					my $text = join('', map { $_->text } @buffer);
			        my $node = Core::Node->new('comments', $text);
					push(@outBuffer, $node);
					@buffer = ();
				} else {
					my $node = Core::Node->new('other', $_);
					push(@currentExpr, $node);
				}
			}
			when(/\(|\{|\[/) {
				my $level = 1;
				my $open = $token->text;
				my $close = pairForNode($token->text);
				while (1) {
					$token = $list->pop();
					if ($token->text eq $open) {
						$level += 1;
						push(@buffer, $token);
					} elsif ($token->text eq $close) {
						$level -= 1;
						if ($level != 0) {
							push(@buffer, $token);
						} else {
					        my $node = Core::Node->new('container', $open);
							my $sublist = Core::TokenList->new(@buffer);
							my @ast = astFromTokens($sublist, $yml);
							$node->nodes(@ast);
							push(@currentExpr, $node);
							@buffer = ();

							if ($open eq "{") {
								my $node = Core::Node->new('expr', $_);
								$node->nodes(@currentExpr);
								push(@outBuffer, $node);
								@currentExpr = ();
							}

							last;
						}
					} else {
						push(@buffer, $token);
					}
				}
			}
			default {
				my $node = Core::Node->new('other', $_);
				push(@currentExpr, $node);
			}
		}
	}

	if (scalar @currentExpr > 0) {
		my $node = Core::Node->new('expr', $_);
		$node->nodes(@currentExpr);
		push(@outBuffer, $node);
		@currentExpr = ();
	}
	return @outBuffer;
}


sub pairForNode {
	my $char = shift;

	given($char) {
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

sub findDirectives {
	my $logos = shift;

	# print Dumper($logos);
	say "name: ".$logos->{'name'};
	say "extensions: ";
	foreach (@{$logos->{'extensions'}}) {
		say "  - $_";
	}

	say "syntax: ";
	my %syntax = %{$logos->{'syntax'}};
	# say join(" | ", map { $_ } (keys %syntax));
	# test if token is directive
	# say join(" | ", keys %syntax);
	# foreach ('hookf', 'cuantity', 'min') {
	# 	say $_ if defined %syntax->{$_};
	# }

	while (my ($key, $value) = each %syntax) {
		say "- $key";
		say "  type: ".$value->{'type'};
		say "  arguments: ".$value->{'arguments'} if defined $value->{'arguments'};
		say "  hints: ";
		foreach (@{$value->{'hints'}}) {
		say "  - $_";
		}
	}
}
