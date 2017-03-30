package Alatar::Model::SqlView;

use Data::Dumper;

use strict;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{_request} = undef;
 	bless($this,$class);   
 	return $this;             
}

sub isSqlView {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlView';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

# setters and getters
# -----------------------------------------------------------------------------

sub setSqlRequest {
	my ($this,$request) = @_;
	$this->{_request} = $request;
}

sub getSqlRequest {
	my ($this) = @_;
	return $this->{_request};
}

1;