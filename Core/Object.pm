package Core::Object;

sub new {
	my $proto = shift;

	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);

	return $self;
}

sub description {
	my $self = shift;

	my $r = "<$self>";
	return $r;
}

1;
