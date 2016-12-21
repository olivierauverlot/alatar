package SqlTableReference;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$tableName) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{_tableName} = $tableName;
	$this->{_tableReference} = undef;
 	bless($this,$class);
 	return $this;            
}

sub isSqlTableReference {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlReference';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

# setters and getters
sub getTableName {
	my ($this) = @_;
	return $this->{_tableName};
}

sub setTableName {
	my ($this,$tableName) = @_;
	$this->{_tableName} = $tableName; 
}

sub getTableReference {
	my ($this) = @_;
	return $this->{_tableReference};
}

sub setTableReference {
	my ($this,$tableReference) = @_;
	$this->{_tableReference} = $tableReference;
}

1;