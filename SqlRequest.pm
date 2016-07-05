package SqlRequest;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$request) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{request} = $request;
 	bless($this,$class);      
 	return $this;            
}

sub isSqlRequest {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlRequest';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

sub getRequest {
	my ($this) = @_;
	return $this->{request};
}

1;