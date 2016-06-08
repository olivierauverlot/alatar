package Configuration;

use strict;

# static variable
my %options;

# static methods
sub setOption {
	my ($this,$key,$value) = @_;
	$options{$key} = $value;
}

sub getOption {
	my ($this,$key) = @_;
	return $options{$key};
}

1;