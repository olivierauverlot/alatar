package SqlTable;

use strict;
use SqlObject;
use SqlColumn;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{view} = 0;
	$this->{columns} = [ ];
	$this->{constraints} = [ ];
	$this->{invokedFunctions} = [ ];
   	$this->{callers} = [ ];
   	$this->{parentTableName} = '';
   	$this->{parentTableReference} = undef;
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

# answer true if the table inherits from another table
sub isChildren {
	my ($this) = @_;
	return ($this->{parentTableName} ne '')
}

# setters and getters
sub getParentTableName {
	my ($this) = @_;
	return $this->{parentTableName};
}

sub setParentTableName {
	my ($this,$parent) = @_;
	$this->{parentTableName} = $parent;
}

sub getParentTableReference {
	my ($this) = @_;
	return $this->{parentTableReference};
}

sub setParentTableReference {
	my ($this,$parent) = @_;
	$this->{parentTableReference} = $parent;
}

sub addColumn {
	my ($this,$column) = @_;
	push(@{$this->{columns}},$column);
	return $column;
}
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
	return @{$this->{constraints}};
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
