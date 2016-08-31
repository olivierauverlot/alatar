package SqlColumnReference;

use strict;
use SqlObject;
use Data::Dumper;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$table,$column) = @_;
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

# setter and getter
sub setTable {
	my ($this,$table) = @_;
	$this->{table} = $table;
}

sub getTable {
	my ($this) = @_;
	return $this->{table};
}

sub setColumn {
	my ($this,$column) = @_;
	$this->{column} = $column;
}

sub getColumn {
	my ($this) = @_;
	return $this->{column};
}


1;