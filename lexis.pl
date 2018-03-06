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

Core::FileUtils::loadModulesAtPath("./Core/");
foreach (@ARGV) {
	my $ast = Core::AST::ASTFromFile($_);
    say "---";
	$ast->description($outputFormat);
    say "===";

	say "---";
	say Core::AST::fileFromAST($ast);
	say "===";
}
