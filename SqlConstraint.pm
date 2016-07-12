package SqlConstraint;

use strict;
use Attribute::Abstract;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{columns} = [ ];
 	bless($this,$class);
 	return $this;            
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlConstraint';
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
	if(scalar($this->{columns}) == 1 ) {
		return $this->{columns}[0];
	} else { return undef }
}

sub getColumns {
	my ($this) = @_;
	return @{$this->{columns}};
}

sub getName {
	my ($this) = @_;
	return $this->getName();
}

# visitors
sub acceptVisitor: Abstract;

# actions
# Return a formated name for cursors and request
sub buildName {
	my ($this,$name) = @_;
	return ($this->getObjectType() . '_' . $name);
}
1;