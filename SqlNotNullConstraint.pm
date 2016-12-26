package SqlNotNullConstraint;

use strict;
use SqlObject;
use SqlInheritedConstraint;
use Data::Dumper;

our @ISA = qw(SqlInheritedConstraint);

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
	my $c = SqlNotNullConstraint->new($inheritedTable,undef);
	$c->addAllColumnsFrom($this,$inheritedTable);
	return $c;
}

1;