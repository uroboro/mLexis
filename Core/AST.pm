#Abstract Syntax Tree
package Core::AST;

use 5.010;
use strict;
use warnings;

sub _astFromTokens {
    my $deep = shift;
    my @tokens = @_;

    my $level = 0;
    my @buffer = ();

    my $current;
    my $close = "";
    my @ast = ();
    foreach (@tokens) {
        my $node = Core::Node->new($_);
		# check for single line and multi line comment
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

	my $rootNode = Core::Node->new($rootToken);
	$rootNode->type("root");
	$rootNode->nodes(@ast);

	return $rootNode;
}

sub ASTFromFile {
	my $file = shift;
	my @tokens = Core::Token::tokensFromFile($file);
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
