package SqlDataTypeReference;

use strict;
use SqlReference;
use SqlColumn;
use SqlFunction;
use SqlCursor;

our @ISA = qw(SqlReference);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{dataTypeName} = $this->getName();
	$this->addBasicDataTypeIfNotExists();
	$this->{dataTypeReference} = undef;
 	bless($this,$class);
 	return $this;            
}

sub isSqlDataTypeReference {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlDataTypeReference';
}

# setters and getters
sub setName {
	my ($this,$name) = @_;
	$this->SUPER::setName($name);
	$this->{name} =~ s/\(.*?\)//g;
	$this->{name} =~ s/\[.*?\]//g;
	$this->{name} = lc($this->{name});
}

# action

# If not yet referenced, the basic datatype (INTEGER, VARCHAR, etc.) is added to 
# the collection of database's objects
sub addBasicDataTypeIfNotExists {
	my ($this) = @_;
	my $database = $this->getOwner()->getDatabaseReference();
	my @datatypeObjects = $database->getSqlDataTypes();
	my $found = grep { $_->getName() eq $this->{dataTypeName} } @datatypeObjects;
	if(!$found) {
		# print "$this->{dataTypeName}\n";
		$database->addObject(SqlDataType->new($database,$this->{dataTypeName}));
	}
}

1;