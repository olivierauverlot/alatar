package SqlUniqueConstraint;

use strict;
use SqlObject;

our @ISA = qw(SqlConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlUniqueConstraint';
}

sub isSqlDefaultConstraint {
	my ($this) = @_;
	return 1;
}

1;