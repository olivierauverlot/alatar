package PgExtractor;

use Attribute::Abstract;
use strict;

use Data::Dumper;
sub new {
	my ($class,$owner,$objects,$code,@properties) = @_;
	my $this = { 
		owner => $owner,
		objects => $objects
	};
	foreach my $var (@properties) {
		$this->{$var} = undef;
	}
 	bless($this,$class); 
 	if(defined($code)) {
	 	$this->_extractObject($code);
 	}
 	return $this;            
}

# setters and getters
# --------------------------------------------------
sub addObject {
	my ($this,$sqlObject) = @_;
	push(@{$this->{objects}},$sqlObject);
	return $sqlObject;
}

# actions
# --------------------------------------------------
sub _extractObject: Abstract;

1;