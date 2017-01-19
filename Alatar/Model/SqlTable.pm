package Alatar::Model::SqlTable;

use strict;
use Alatar::Model::SqlObject;
use Alatar::Model::SqlColumn;
use Alatar::Model::SqlTableReference;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{_request} = '';
	$this->{view} = 0;
	$this->{columns} = [ ];
	$this->{constraints} = [ ];
	$this->{invokedFunctions} = [ ];
   	$this->{callers} = [ ];
   	$this->{parentTables} = [ ];
 	bless($this,$class);
 	return $this;            
}

sub isSqlTable {
	my ($this) = @_;
	return 1;
}

sub isSqlView {
	my ($this) = @_;
	return $this->{view};
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlTable';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

# setters and getters
sub getSqlRequest {
	my ($this) = @_;
	return $this->{_request};
}

sub setSqlRequest {
	my ($this,$request) = @_;
	$this->{_request} = $request;
}


# actions
# answer true if the table inherits from another table
sub isChild {
	my ($this) = @_;
	my @tables = @{ ($this->{parentTables}) };
	return (scalar(@tables) > 0)
}

# answer true if the table inherits from the specified table
sub inheritsFrom {
	my ($this,$tableReference) = @_;
	my @references = grep { $_->getTableReference() == $tableReference } $this->getParentTables();
	return @references;
}

# setters and getters
sub getParentTables {
	my ($this) = @_;
	return @{$this->{parentTables}};
}

sub addParentTableReference {
	my ($this,$tableName) = @_;
	push(@{$this->{parentTables}},Alatar::Model::SqlTableReference->new($this,('parent_' . $tableName),$tableName));
}

sub addColumn {
	my ($this,$column) = @_;
	push(@{$this->{columns}},$column);
	return $column;
}

# answer only the columns defined in the table
sub getLocalColumns {
	my ($this) = @_;
	my @columns = grep { $_->isInherited() == 0 } $this->getColumns();
	return @columns;
}

# return all columns (private columns and columns
# defined in parent tables (if defined)
sub getColumns {
	my ($this) = @_;
	return @{$this->{columns}};
}

sub addConstraint {
	my ($this,$constraint) = @_;
	push(@{$this->{constraints}},$constraint);
	return $constraint;
}

sub getConstraints {
	my ($this) = @_;
	return @{ $this->{constraints} };
}

sub getColumnWithName {
	my ($this,$columnName) = @_;
	my @columns;
	@columns = grep { $_->getName() eq $columnName} @{$this->{columns}};
	if(scalar(@columns) == 1) {
		return $columns[0];
	} else { return undef }
}

1;
