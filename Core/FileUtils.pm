package Core::FileUtils;

use 5.010;
use Module::Load;

sub loadModulesAtPath {
	my $path = shift;

	foreach (listDirectory($path)) {
		my $module = $path.$_;
		if (! -d($module)) {
			load $module;
		}
	}
}

sub listDirectory {
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

sub readFile {
	my $path = shift;
	open(FILE, $path) or die "Couldn't open file: $path";
	binmode FILE;
	my $string = <FILE>;
	close FILE;
	return $string;
}

1;