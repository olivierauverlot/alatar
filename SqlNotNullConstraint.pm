package SqlNotNullConstraint;

use strict;
use SqlObject;
use SqlConstraint;

our @ISA = qw(SqlConstraint);

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

# visitor
sub acceptVisitor {
	my ($this,$visitor) = @_;
	$visitor->visitSqlNotNullConstraint($this);
}

1;