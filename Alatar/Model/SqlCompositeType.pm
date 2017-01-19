package Alatar::Model::SqlCompositeType;

use strict;
use Alatar::Model::SqlEnumerationType;

our @ISA = qw(Alatar::Model::SqlEnumerationType);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{fields} = [ ];
 	bless($this,$class);
 	return $this;            
}

sub isSqlCompositeType {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlCompositeType';
}

# setters and getters
sub addField {
	my ($this,$field) = @_;
	push(@{$this->{fields}},$field);
	return $field;
}

sub getFields {
	my ($this) = @_;
	return @{$this->{fields}};
}

sub getFieldWithName {
}

1;