package SqlInheritanceConstraint;

use strict;
use Data::Dumper;
use Attribute::Abstract;
use SqlConstraint;

our @ISA = qw(SqlConstraint);

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