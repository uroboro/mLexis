#!/usr/bin/perl

package Lexis;

use 5.010;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';
use strict;
use warnings;
use FindBin;
use Module::Load;

# Utilities

sub loadModulesAtPath {
	my $path = shift;

	foreach (listDir($path)) {
		my $module = $path.$_;
		if (! -d($module)) {
			load $module;
		}
	}
}

sub listDir {
	my $path = shift;
	my $mode = shift;

	opendir(my $dh, $path) || die "can't opendir $path: $!";
	my @files = grep(!/^\.+$/, readdir($dh));
	closedir $dh;

	if ($mode) {
		my @filtered = ();
		foreach (@files) {
			if ($mode eq "f" && -f($path.$_)) {
				push(@filtered, $_);
			}
			if ($mode eq "d" && -d($path.$_)) {
				push(@filtered, $_);
			}
		}
		@files = @filtered;
	}

	return @files;
}

sub tokenize {
	my $filename = shift;

	return mergeTokens(getTokens($filename));
}

sub getTokens {
	my $filename = shift;

	die "Syntax: $FindBin::Script filename\n" if !$filename;

	my $FILE;
	open(FILE, $filename) or die $!." [$filename]";

	my @tokens = ();
	my ($c, $n);
	while (($n = read(FILE, $c, 1)) != 0) {
		push(@tokens, Core::Token->new($c));
	}
	close(FILE);

	return @tokens;
}

sub mergeTokens {
	my @Tokens = @_;

	my @tokens = ();
	foreach (@Tokens) {
		my $t = $tokens[$#tokens];
		if ($t && $t->isMergeableWithToken($_)) {
			$t->mergeWithToken($_);
		} else {
			push(@tokens, $_);
		}
	}
	return @tokens;
}

sub astFromTokens {
	my $deep = shift;
	my @Tokens = @_;

	my $level = 0;
	my @buffer = ();

	my $current;
	my $close = "";
	my @ast = ();
	foreach (@Tokens) {
		my $node = Core::Node->new($_);
		if ($node->isArray || $level != 0) { # Node is array or an array has been started
			if (!$current) {
				$level += 1;
				push(@ast, $node);
				$current = $node;
				$close = $node->pairForNode;
			} else {
				if ($node->text eq $current->text) { # Node is same as current array kind
					$level += 1;
					push(@buffer, $node);
				} elsif ($node->text eq $close) { # Node closes current array
					$level -= 1;
					if ($level == 0) { # Node actually closes array so push array
						my @subnodes = astFromTokens($deep + 1, @buffer);
						$current->nodes(@subnodes);
						@buffer = ();
						$current = undef;
						$close = "";
					} else { # Node does not close array
						push(@buffer, $node);
					}
				} else { # Array level
					push(@buffer, $node);
				}
			}
		} else { # Root level
			push(@ast, $node);
		}
	}
	return @ast;
}

sub recursiveASTDescription {
	my @ast = @_;
	say "---";
	foreach (@ast) {
		say $_->description;
	}
	say "===";
}

sub fileFromAST {
	my @ast = @_;
	my $r = "";
	foreach (@ast) {
		if ($_->isArray) {
			$r .= $_->text;
			$r .= fileFromAST(@{$_->nodes});
			$r .= $_->pairForNode;
		} else {
			$r .= $_->text;
		}
	}
	return $r;
}


# main

loadModulesAtPath("./Core/");

my @tokens = tokenize($ARGV[0]);

# my @lexis = listDir("./Lexis/", "d");
# say "---";
# foreach (@lexis) {
#	say $_;
# }
# say "===";

# say "---";
# foreach (@tokens) {
#	say $_->description;
# }
# say "===";

my @ast = astFromTokens(0, @tokens);

recursiveASTDescription(@ast);

say "---";
say fileFromAST(@ast);
say "===";
