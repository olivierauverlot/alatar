package Alatar::Model::SqlTrigger;

use strict;
use Data::Dumper;
use Regexp::Common;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

# il faut gérer les appels de fonctions avec arguments
# On ne conserve que le nom de la table, il faudrait une référence vers la table

sub new {
	my ($class,$owner) = @_;
 	my $this = $class->SUPER::new($owner,'undef');
 	$this->{_request} = '';
	$this->{_fire} = '';
	$this->{_events} = [ ];
	$this->{_tableReference} = undef;
	$this->{_level} = '';
	$this->{_invokedFunctionReference} = undef;
	bless($this,$class);    
 	return $this;            
}

sub isSqlTrigger {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlTrigger';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType();
}

# setters and getters
# ----------------------------------------------------

sub getReferences {
	my ($this) = @_;
	my @references = [ ];
	push(@references,$this->{_tableReference});	
	push(@references,$this->{_invokedFunctionReference});
	return @references;
}

sub getSqlRequest {
	my ($this) = @_;
	return $this->{_request};
}

sub setSqlRequest {
	my ($this,$request) = @_;
	$this->{_request} = $request;
}

sub getFire {
	my ($this) = @_;
	return $this->{_fire};
}

sub setFire {
	my ($this,$value) = @_;
	$this->{_fire} = $value;	
}

sub getEvents {
	my ($this) = @_;
	return @{$this->{_events}};
}

sub addEvent {
	my ($this,$event) = @_;
	push(@{$this->{_events}},$event);	
}

sub getLevel {
	my ($this) = @_;
	return $this->{_level};
}

sub setLevel {
	my ($this,$value) = @_;
	$this->{_level} = $value;	
}

sub getTableReference {
	my ($this) = @_;
	return $this->{tableReference};
}

sub setTableReference {
	my ($this,$tableRef) = @_;
	$this->{tableReference} = $tableRef;	
}

sub getInvokedFunctionReference {
	my ($this) = @_;
	return $this->{_invokedFunctionReference};
}

sub setInvokedFunctionReference {
	my ($this,$value) = @_;
	$this->{_invokedFunctionReference} = $value;	
}

