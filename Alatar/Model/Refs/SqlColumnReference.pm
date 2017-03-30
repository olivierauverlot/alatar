package Alatar::Model::Refs::SqlColumnReference;

use strict;
use Alatar::Model::SqlReference;
use Data::Dumper;

our @ISA = qw(Alatar::Model::SqlReference);

sub new {
	my ($class,$owner,$name,$tableName) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{_tableName} = $tableName;
   	bless($this,$class);      
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlColumnReference';
}

sub isSqlColumnReference {
	my ($this) = @_;
	return 1;
}

# setter and getter
sub setTableName {
	my ($this,$tableName) = @_;
	$this->{_tableName} = $tableName;
}

sub getTableName {
	my ($this) = @_;
	return $this->{_tableName};
}

1;