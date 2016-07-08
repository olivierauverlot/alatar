package SqlForeignKeyConstraint;

use strict;
use SqlObject;

our @ISA = qw(SqlConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{reference} = undef;
 	bless($this,$class);
 	return $this;            
}

sub isSqlForeignKeyConstraint {
	my ($this) = @_;
	return 1;
}

# setters and getters
sub setReference {
	my ($this,$reference) = @_;
	$this->{reference} = $reference; 
}

sub getReference {
	my ($this) = @_;
	return $this->{reference};
}

1;