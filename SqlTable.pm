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
sub addColumn {
	my ($this,$column) = @_;
	push(@{$this->{columns}},$column);
	return $column;
}
sub getColumns {
	my ($this) = @_;
	return @{$this->{columns}};
}

1;
