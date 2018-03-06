#Abstract Syntax Tree
package Core::AST;

use 5.010;
use strict;
use warnings;
use FindBin;

sub tokensFromFile {
    my $filename = shift;
    return mergeTokens(allTokensFromFile($filename));
}

sub allTokensFromFile {
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

sub _astFromTokens {
    my $deep = shift;
    my @tokens = @_;

    my $level = 0;
    my @buffer = ();

    my $current;
    my $close = "";
    my @ast = ();
    foreach (@tokens) {
        my $node = Core::TokenNode->new($_);
        if ($node->isContainer || $level != 0) { # Node is a container or a container has been started
            if (!$current) {
                $level += 1;
                push(@ast, $node);
                $current = $node;
                $close = $node->pairForNode;
            } else {
                if ($node->text eq $current->text) { # Node is same as current container kind
                    $level += 1;
                    push(@buffer, $node);
                } elsif ($node->text eq $close) { # Node closes current container
                    $level -= 1;
                    if ($level == 0) { # Node actually closes container so push container
                        my @subnodes = _astFromTokens($deep + 1, @buffer);
                        $current->nodes(@subnodes);
                        @buffer = ();
                        $current = undef;
                        $close = "";
                    } else { # Node does not close container
                        push(@buffer, $node);
                    }
                } else { # Container level
                    push(@buffer, $node);
                }
            }
        } else { # Root level
            push(@ast, $node);
        }
    }
    return @ast;
}

sub astFromTokens {
    my @tokens = @_;
	my @ast = _astFromTokens(0, @tokens);

	my $rootToken = Core::Token->new("root");
	$rootToken->offset(0);
	$rootToken->line(0);
	$rootToken->column(0);

	my $rootNode = Core::TokenNode->new($rootToken);
	$rootNode->type("root");
	$rootNode->nodes(@ast);

	return $rootNode;
}

sub ASTFromFile {
	my $file = shift;
	my @tokens = tokensFromFile($file);
	my $ast = astFromTokens(@tokens);
	return $ast;
}

sub _fileFromAST {
    my @ast = @_;
    my $r = "";
    foreach (@ast) {
        if ($_->isContainer) {
            $r .= $_->text;
            $r .= _fileFromAST(@{$_->nodes});
            $r .= $_->pairForNode;
        } else {
            $r .= $_->text;
        }
    }
    return $r;
}

sub fileFromAST {
    my $rootNode = shift;
    my @ast = @{$rootNode->nodes};
    my $r = "";
    foreach (@ast) {
        if ($_->isContainer) {
            $r .= $_->text;
            $r .= _fileFromAST(@{$_->nodes});
            $r .= $_->pairForNode;
        } else {
            $r .= $_->text;
        }
    }
    return $r;
}

1;
