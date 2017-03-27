package Alatar::Model::SqlRule;

use strict;
use Data::Dumper;
use Regexp::Common;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
 	my $this = $class->SUPER::new($owner,$name);
 	$this->{_availableEvents} = ['SELECT','UPDATE','INSERT','DELETE'];
 	$this->{_also} = 0;
 	$this->{_instead} = 0;
	$this->{_event} = '';
	$this->{_table} = undef;
	$this->{_request} = undef;
	bless($this,$class);    
 	return $this;    
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' ' . $this->getEvent() . ' ON ' . $this->getTable()->getName();
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlRule';
}

sub isSqlRule {
	my ($this) = @_;
	return 1;
}

sub setAlsoMode {
	my ($this) = @_;
	$this->{_also} = 1;
}

sub doAlso {
	my ($this) = @_;
	return $this->{_also};
}

sub setInsteadMode {
	my ($this) = @_;
	$this->{_instead} = 1;
}

sub doInstead {
	my ($this) = @_;
	return $this->{_instead};
}

sub setEvent {
	my ($this,$eventString) = @_;
	$this->{_event} = $eventString;
}

sub getEvent {
	my ($this) = @_;
	return $this->{_event};
}

sub isSelectEvent {
	my ($this) = @_;
	return $this->{_event} eq 'SELECT';
}

sub isInsertEvent {
	my ($this) = @_;
	return $this->{_event} eq 'INSERT';
}

sub isUpdateEvent {
	my ($this) = @_;
	return $this->{_event} eq 'UPDATE';
}

sub isDeleteEvent {
	my ($this) = @_;
	return $this->{_event} eq 'DELETE';
}

sub setTable {
	my ($this,$tableReference) = @_;
	$this->{_table} = $tableReference;
}

sub getTable {
	my ($this) = @_;
	return $this->{_table};
}

sub setSqlRequest {
	my ($this,$requestReference) = @_;
	$this->{_request} = $requestReference;
}

sub getSqlRequest {
	my ($this) = @_;
	return $this->{_request};
}

1;