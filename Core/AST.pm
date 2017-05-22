#Abstract Syntax Tree
package Core::AST;

use 5.010;
use strict;
use warnings;
use FindBin;

#use Core::Token;
#use Core::Node;

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
    my $O = 0;
    my $L = 0;
    my $C = 0;
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
                        my @subnodes = astFromTokens($deep + 1, @buffer);
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

sub fileFromAST {
    my @ast = @_;
    my $r = "";
    foreach (@ast) {
        if ($_->isContainer) {
            $r .= $_->text;
            $r .= fileFromAST(@{$_->nodes});
            $r .= $_->pairForNode;
        } else {
            $r .= $_->text;
        }
    }
    return $r;
}

# Introspection

sub recursiveDescription {
    my @ast = @_;
    say "---";
    foreach (@ast) {
        say $_->description;
    }
    say "===";
}

1;