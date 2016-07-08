package SqlConstraint;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{columns} = [ ];
 	bless($this,$class);
 	return $this;            
}

sub isSqlConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlPrimaryKeyConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlForeignKeyConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlNotNullConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlCheckConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlDefaultConstraint {
	my ($this) = @_;
	return 0;
}

# Setters and getters
sub addColumn {
	my ($this,$column) = @_;
	push(@{$this->{columns}},$column);
	return $column;
}

sub getColumn {
	my ($this) = @_;
	if(scalar($this->{columns} == 1 ) {
		return $this->{columns}[0];
	else { return undef }
}

sub getColumns {
	my ($this) = @_;
	return @{$this->{columns}};
}

1;