package SqlObject;

use strict;
use Attribute::Abstract;
use String::Util qw(trim);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = {
		owner => $owner
	};
 	bless($this,$class);      
	$this->setName($name);
 	return $this;            
}

# sub printString: Abstract;
sub printString {
	my ($this) = @_;
	return $this->getObjectType();
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlObject';
}

sub getOwner {
	my ($this) = @_;
	return $this->{owner};
}

sub getOwnerName {
	my ($this) = @_;
	return $this->getOwner()->getName();
}

# this method must surcharged by the objects that need
# to access directly to the database reference
# The owner of most objects is generaly the database herself.
sub getDatabaseReference {
	my ($this) = @_;
	return $this->getOwner();
}

sub setOwner {
	my ($this,$owner) = @_;
	$this->{owner} = $owner;
}

sub getName {
	my ($this) = @_;
	return $this->{name};
}

sub setName {
	my ($this,$name) = @_;
	$this->{name} = trim($name);
}

sub isSqlDataTypeReference {
	my ($this) = @_;
	return 0;
}

sub isSqlDataType {
	my ($this) = @_;
	return 0;
}

sub isSqlEnumerationType {
	my ($this) = @_;
	return 0;
}

sub isSqlCompositeType {
	my ($this) = @_;
	return 0;
}

sub isSqlTable {
	my ($this) = @_;
	return 0;
}

sub isSqlView {
	my ($this) = @_;
	return 0;
}

sub isSqlTrigger {
	my ($this) = @_;
	return 0;
}

sub isSqlSequence {
	my ($this) = @_;
	return 0;
}

sub isSqlFunction {
	my ($this) = @_;
	return 0;
}

sub isSqlArgument {
	my ($this) = @_;
	return 0;
}

sub isSqlFunctionInvocation {
	my ($this) = @_;
	return 0;
}

sub isSqlCursor {
	my ($this) = @_;
	return 0;
}

sub isSqlColumn {
	my ($this) = @_;
	return 0;
}

sub isSqlConstraint {
	my ($this) = @_;
	return 0;
}

sub isSqlColumnReference {
	my ($this) = @_;
	return 1;
}

1;