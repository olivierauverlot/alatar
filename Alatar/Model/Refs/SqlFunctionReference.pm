package Alatar::Model::Refs::SqlFunctionInvocation;

use strict;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlReference);

sub new {
	my ($class,$owner,$name,$argumentsNumber) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{argumentsNumber} = $argumentsNumber;
 	bless($this,$class);      
 	return $this;            
}

sub isSqlFunctionReference {
	my ($this) = @_;
	return 1;
}

# return true if the function invocation aims a stub
sub isStub {
	my ($this) = @_;
	return !defined($this->getTarget())
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlFunctionReference';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' with ' . $this->getArgumentsNumber();
}

# Setters and getters
# ----------------------------------------------------
sub getArgumentsNumber {
	my ($this) = @_;
	return $this->{argumentsNumber};
}

sub setReturnType {
	my ($this,$returnType) = @_;
	$this->{returnType} = $returnType;
}

# Actions
# ----------------------------------------------------

# Return true if the function have the same signature that the other function
sub isInvocationOf {
	my ($this,$function) = @_;
	return (($this->getName() eq $function->getName()) && ($this->getArgumentsNumber() == $function->getArgumentsNumber()))
}

1;