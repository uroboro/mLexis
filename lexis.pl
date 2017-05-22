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

# main

my $data   = "file.dat";
my $length = 24;
my $verbose;
GetOptions( "length=i" => \$length,    # numeric
			"file=s"   => \$data,	   # string
			"verbose"  => \$verbose)   # flag
or die("Error in command line arguments\n");

# my $languagesDir = "./Languages/";
# my @configs = Core::FileUtils::listDirectory($languagesDir, "f");
# say "---";
# foreach (@configs) {
#	  say $languagesDir.$_;
#	  my $yml = LoadFile($languagesDir.$_);
#	  print Dumper($yml);
# }
# say "===";

Core::FileUtils::loadModulesAtPath("./Core/");
foreach (@ARGV) {
	my @tokens = Core::AST::tokensFromFile($_);
	#Core::AST::recursiveDescription(@tokens);

	my @ast = Core::AST::astFromTokens(0, @tokens);
	#Core::AST::recursiveDescription(@ast);

	#say "---";
	say Core::AST::fileFromAST(@ast);
	#say "===";
}
