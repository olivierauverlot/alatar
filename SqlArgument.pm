package SqlArgument;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$type) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{type} = $type;
 	bless($this,$class);      
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlArgument';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' = ' . $this->{type};
}

sub isSqlArgument {
	my ($this) = @_;
	return 1;
}

sub getType {
	my ($this) = @_;
	return $this->{type};
}

1;