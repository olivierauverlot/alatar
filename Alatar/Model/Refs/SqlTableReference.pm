package Alatar::Model::Refs::SqlTableReference;

use strict;
use Alatar::Model::SqlObject;
use Alatar::Model::Refs::SqlReference;

our @ISA = qw(Alatar::Model::Refs::SqlReference);

sub isSqlTableReference {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlTableReference';
}

1;