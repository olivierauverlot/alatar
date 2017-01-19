package Alatar::Model::SqlPrimaryKeyConstraint;

use strict;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlPrimaryKeyConstraint';
}

sub isSqlPrimaryKeyConstraint {
	my ($this) = @_;
	return 1;
}

# visitor
sub acceptVisitor {
	my ($this,$visitor) = @_;
	$visitor->visitSqlPrimaryKeyConstraint($this);
}

1;