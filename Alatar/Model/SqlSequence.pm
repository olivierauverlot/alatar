package Alatar::Model::SqlSequence;

use strict;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);      
 	return $this;            
}

sub isSqlSequence {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlSequence';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

1;