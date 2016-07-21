package SqlColumnReference;

use strict;
use SqlObject;
use Data::Dumper;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$table,$column) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{table} = $table;
   	$this->{column} = $column;
 	bless($this,$class);      
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlColumnReference';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType();
}

sub isSqlColumnReference {
	my ($this) = @_;
	return 1;
}


1;