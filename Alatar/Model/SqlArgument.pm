package Alatar::Model::SqlArgument;

use strict;
use Alatar::Model::SqlObject;
use Data::Dumper;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name,$typeReference) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{_dataTypeReference} = $typeReference;
 	bless($this,$class);      
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlArgument';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' = ' . $this->getDataTypeReference()->getTarget()->getName();
}

sub isSqlArgument {
	my ($this) = @_;
	return 1;
}

# setters and getters

sub getReferences {
	my ($this) = @_;
	my @references = [ ];
	push(@references,$this->{_dataTypeReference});	
	return @references;
}

sub getDataTypeReference {
	my ($this) = @_;
	return $this->{_dataTypeReference};
}

sub getDataTypeName {
	my ($this) = @_;
	return $this->getDataTypeReference()->getTarget()->getName();
}

1;