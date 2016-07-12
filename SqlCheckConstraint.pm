package SqlCheckConstraint;

use strict;
use SqlObject;

our @ISA = qw(SqlConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{objects} = [ ];
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlCheckConstraint';
}

sub isSqlCheckConstraint {
	my ($this) = @_;
	return 1;
}

# setters and getters
sub addObject {
	my ($this,$object) = @_;
	push(@{$this->{objects}},$object);
	return $object;
}

sub getObjects {
	my ($this) = @_;
	return @{$this->{objects}};
}

1;