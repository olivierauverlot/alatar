package Alatar::Model::SqlArgument;

use strict;
use Alatar::Model::SqlObject;
use Data::Dumper;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name,$type) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{dataType} = $type;
 	bless($this,$class);      
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlArgument';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' = ' . $this->getDataTypeName();
}

sub isSqlArgument {
	my ($this) = @_;
	return 1;
}

sub getDataType {
	my ($this) = @_;
	return $this->{dataType};
}

1;