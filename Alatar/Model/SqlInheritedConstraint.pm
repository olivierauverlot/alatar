package Alatar::Model::SqlInheritedConstraint;

use strict;
use Data::Dumper;
use Attribute::Abstract;
use Alatar::Model::SqlConstraint;

our @ISA = qw(Alatar::Model::SqlConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{_inheritanceConstraint} = 1;
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlInheritanceConstraint';
}

# an abstract method that return a clone of 
# the herited constraint
sub clone: Abstract;

# Copy all the columns from the constraint defined 
# on the parent table
sub addAllColumnsFrom {
	my ($this,$parentConstraint,$inheritedTable) = @_;
	my $db = $this->getOwner()->getDatabaseReference();
	foreach my $columnReference ($parentConstraint->getColumns()) {
		my $r = Alatar::Model::SqlColumnReference->new($db,undef,$inheritedTable,$columnReference->getColumn());
		$this->addColumn($r);
	}
}