package SqlSequence;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner);
	$this->setName($name);
 	bless($this,$class);      
 	return $this;            
}

sub isSqlSequence {
	my ($this) = @_;
	return 1;
}

1;