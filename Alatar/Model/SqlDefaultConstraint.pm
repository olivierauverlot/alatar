package Alatar::Model::SqlDefaultConstraint;

use strict;
use Alatar::Model::SqlObject;
use Alatar::Model::SqlInheritedConstraint;

our @ISA = qw(Alatar::Model::SqlInheritedConstraint);

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