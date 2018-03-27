package Core::StringUtils;

use 5.010;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

sub colorText {
	my $color = shift;
	my $text = shift;

	my $r = 37;
	given($color) {
		when(/black/) {
			$r = 30;
		}
		when(/red/) {
			$r = 31;
		}
		when(/green/) {
			$r = 32;
		}
		when(/yellow/) {
			$r = 33;
		}
		when(/blue/) {
			$r = 34;
		}
		when(/magenta/) {
			$r = 35;
		}
		when(/cyan/) {
			$r = 36;
		}
		default {
			$r = 37;
		}
	};
	return "\033[".$r."m$text\033[0m"
}

sub colorTextBlack {
	my $text = shift;
	return colorText('black', $text);
}
sub colorTextRed {
	my $text = shift;
	return colorText('red', $text);
}
sub colorTextGreen {
	my $text = shift;
	return colorText('green', $text);
}
sub colorTextYellow {
	my $text = shift;
	return colorText('yellow', $text);
}
sub colorTextBlue {
	my $text = shift;
	return colorText('blue', $text);
}
sub colorTextMagenta {
	my $text = shift;
	return colorText('magenta', $text);
}
sub colorTextCyan {
	my $text = shift;
	return colorText('cyan', $text);
}
sub colorTextWhite {
	my $text = shift;
	return colorText('white', $text);
}

1;
