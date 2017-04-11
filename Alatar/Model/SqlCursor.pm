package Alatar::Model::SqlCursor;

use strict;
use Alatar::Model::SqlArgument;
use Alatar::Model::Refs::SqlDataTypeReference;
use Alatar::Model::Refs::SqlArgumentReference;

our @ISA = qw(Alatar::Model::SqlRequest);

sub new {
	my ($class,$owner,$name,$args,$request) = @_;
	my $this = $class->SUPER::new($owner,$name,$request);
	$this->{_argumentReferences} = [ ];
	$this->{_argumentsNumber} = 0;
 	bless($this,$class);      
	$this->_extractArguments($args);
 	return $this;            
}

sub isSqlRequest {
	my ($this) = @_;
	return 0;
}

sub isSqlCursor {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlCursor';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

# the owner of a cursor is a function and the owner of a function is the database
# we must take the owner of the onwer...
sub getDatabaseReference {
	my ($this) = @_;
	return $this->getOwner()->getOwner();
}

# Cursor arguments
# ----------------------------------------------------
sub getReferences {
	my ($this) = @_;
	return @{$this->{_argumentReferences}};
}

sub getArguments { 
	my ($this) = @_;
	my @args;
	foreach my $ref (grep { $_->isResolved() } $this->getReferences()) {
		push(@args,$ref->getTarget());
	}
	return @args;
}

sub _addArgumentReference {
	my ($this,$sqlArgRef) = @_;
	push(@{$this->{_argumentReferences}},$sqlArgRef);
	$this->{_argumentsNumber} = $this->{_argumentsNumber} + 1;
	return $sqlArgRef;
}

sub printArguments {
	my ($this) = @_;
	return '(' . join(',',@{$this->{_argumentReferences}}) . ')';
}

# arguments number
# ----------------------------------------------------
sub getArgumentsNumber {
	my ($this) = @_;
	return $this->{_argumentsNumber};
}

# Action
#  ----------------------------------------------------

# Extract arguments
sub _extractArguments {
	my ($this,$args) = @_;
	my @params = $args =~ /(\w+\s\w+\s?\w*)/g;
	foreach my $param (@params) {
		my @p = $param =~ /(\w+)\s(\w+\s?\w*)/g;
		# the argument is added to the database object list
		my $arg = Alatar::Model::SqlArgument->new($this,$p[0],Alatar::Model::Refs::SqlDataTypeReference->new($this,$p[1]));
		$this->getDatabaseReference()->addObject($arg);
		# a reference is created to the argument object
		# the reference is set now because two cursors could share the same name
		my $ref = Alatar::Model::Refs::SqlArgumentReference->new($this,$p[0],$this->getName());
		$ref->setTarget($arg);
		$this->_addArgumentReference($ref);
	}
}

1;