package Alatar::Model::SqlForeignKeyConstraint;

use strict;
use Alatar::Model::SqlObject;
use Data::Dumper;

our @ISA = qw(Alatar::Model::SqlConstraint);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{reference} = undef;
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlForeignKeyConstraint';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' ' 
		. $this->getOneColumn()->getOwnerName() . '(' .  $this->getOneColumn()->getName() . ') -> ' 
		. $this->getReference()->getOwnerName() . '(' . $this->getReference()->getName . ')';
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