package Alatar::Model::Refs::SqlArgumentReference;

use strict;
use Alatar::Model::SqlObject;
use Alatar::Model::Refs::SqlReference;

our @ISA = qw(Alatar::Model::Refs::SqlReference);

sub isSqlArgumentReference {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlArgumentReference';
}

1;