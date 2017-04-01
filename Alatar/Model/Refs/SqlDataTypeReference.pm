package Alatar::Model::Refs::SqlDataTypeReference;

use strict;
use Alatar::Model::Refs::SqlReference;
use Alatar::Model::SqlColumn;
use Alatar::Model::SqlFunction;
use Alatar::Model::SqlCursor;

our @ISA = qw(Alatar::Model::Refs::SqlReference);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->addBasicDataTypeIfNotExists();
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
	$name =~ s/\(.*?\)//g;
	$name =~ s/\[.*?\]//g;
	$name = lc($name);
	$this->SUPER::setName($name);
}

# action

# If not yet referenced, the basic datatype (INTEGER, VARCHAR, etc.) is added to 
# the collection of database's objects
sub addBasicDataTypeIfNotExists {
	my ($this) = @_;
	my @refs = [];
	
	my $database = $this->getOwner()->getDatabaseReference();
	my @datatypeObjects = $database->getSqlDataTypes();

	@refs = grep { $_->getName() eq $this->getName() } @datatypeObjects;
	if(scalar(@refs) == 0) {
		$this->setTarget($database->addObject(Alatar::Model::SqlDataType->new($database,$this->getName())));
	} else {
		$this->setTarget($refs[0]); 
	}
}

1;