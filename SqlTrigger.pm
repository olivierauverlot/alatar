package SqlTrigger;

use strict;
use Data::Dumper;
use Regexp::Common;
use SqlObject;

our @ISA = qw(SqlObject);

# il faut gérer les appels de fonctions avec arguments
# On ne conserve que le nom de la table, il faudrait une référence vers la table

sub new {
	my ($class,$owner) = @_;
 	my $this = $class->SUPER::new($owner,'undef');
	$this->{fire} = '';
	$this->{events} = [ ];
	$this->{table} = '';
	$this->{level} = '';
	$this->{invokedFunction} = undef;
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
sub getFire {
	my ($this) = @_;
	return $this->{fire};
}

sub setFire {
	my ($this,$value) = @_;
	$this->{fire} = $value;	
}

sub getEvents {
	my ($this) = @_;
	return $this->{events};
}

sub addEvent {
	my ($this,$event) = @_;
	push(@{$this->{events}},$event);	
}

sub getTable {
	my ($this) = @_;
	return $this->{table};
}

sub setTable {
	my ($this,$value) = @_;
	$this->{table} = $value;	
}

sub getLevel {
	my ($this) = @_;
	return $this->{level};
}

sub setLevel {
	my ($this,$value) = @_;
	$this->{level} = $value;	
}

sub getInvokedFunction {
	my ($this) = @_;
	return $this->{invokedFunction};
}

sub setInvokedFunction {
	my ($this,$value) = @_;
	$this->{invokedFunction} = $value;	
}

