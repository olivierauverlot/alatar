package Alatar::Model::SqlReference;

use strict;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub isSqlReference {
	my ($this) = @_;
	return 1;
}

sub isSqlDataTypeReference {
	my ($this) = @_;
	return 0;
}

sub isSqlColumnReference {
	my ($this) = @_;
	return 0;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlReference';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

1;