package Alatar::Model::Refs::SqlArgumentReference;

use strict;
use Alatar::Model::SqlObject;
use Alatar::Model::Refs::SqlReference;

our @ISA = qw(Alatar::Model::Refs::SqlReference);

sub new {
	my ($class,$owner,$name,$objectName) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{_objectName} = $objectName;
   	bless($this,$class);      
 	return $this;            
}

sub isSqlArgumentReference {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlArgumentReference';
}

# setter and getter
sub setObjectName {
	my ($this,$objectName) = @_;
	$this->{_objectName} = $objectName;
}

sub getObjectName {
	my ($this) = @_;
	return $this->{_objectName};
}

1;