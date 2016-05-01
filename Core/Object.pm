package Core::Object;

sub new {
	my $proto = shift;

	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);

	return $self;
}

1;
