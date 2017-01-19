package Alatar::Model::SqlConstraint;

use strict;
use Data::Dumper;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{columns} = [ ];
	$this->{_inheritanceConstraint} = 0;
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlConstraint';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

sub isInheritable {
	my ($this) = @_;
	return $this->{_inheritanceConstraint};
}

sub isSqlConstraint {
	my ($this) = @_;
	return 1;
}

sub isSqlPrimaryKeyConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlForeignKeyConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlNotNullConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlCheckConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlDefaultConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlUniqueConstraint {
	my ($this) = @_;
	return 0;
}

# Setters and getters
sub addColumn {
	my ($this,$column) = @_;
	push(@{$this->{columns}},$column);
	return $column;
}

sub getOneColumn {
	my ($this) = @_;
	return $this->{columns}[0];
}

sub getColumns {
	my ($this) = @_;
	return @{$this->{columns}};
}

sub setColumns {
	my ($this,@columns) = @_;
	$this->{columns} = \@columns;
}

# visitors
# sub acceptVisitor: Abstract;

# actions
# Return a formated name for cursors and request
sub buildName {
	my ($this,$name) = @_;
	return ($this->getObjectType() . '_' . $name);
}


1;