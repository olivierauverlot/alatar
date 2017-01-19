package Alatar::Model::SqlEnumerationType;

use strict;
use Alatar::Model::SqlDataType;

our @ISA = qw(Alatar::Model::SqlDataType);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub isSqlEnumerationType {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlEnumerationType';
}

1;