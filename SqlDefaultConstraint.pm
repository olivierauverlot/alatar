package SqlDefaultConstraint;

use strict;
use SqlObject;
use SqlInheritedConstraint;

our @ISA = qw(SqlInheritedConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlDefaultConstraint';
}

sub isSqlDefaultConstraint {
	my ($this) = @_;
	return 1;
}

sub clone {
	my ($this) = @_;
}

1;