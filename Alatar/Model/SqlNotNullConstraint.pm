package Alatar::Model::SqlNotNullConstraint;

use strict;
use Alatar::Model::SqlObject;
use Alatar::Model::SqlInheritedConstraint;
use Data::Dumper;

our @ISA = qw(Alatar::Model::SqlInheritedConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlNotNullConstraint';
}

sub isSqlNotNullConstraint {
	my ($this) = @_;
	return 1;
}

sub clone {
	my ($this,$inheritedTable) = @_; 
	my $c = Alatar::Model::SqlNotNullConstraint->new($inheritedTable,undef);
	$c->addAllColumnsFrom($this,$inheritedTable);
	return $c;
}

1;