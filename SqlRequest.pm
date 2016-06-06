package SqlRequest;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$request) = @_;
	my $this = $class->SUPER::new($owner);
	$this->setName($name);
	$this->{request} = $request;
 	bless($this,$class);      
 	return $this;            
}

sub isSqlRequest {
	my ($this) = @_;
	return 1;
}

sub getRequest {
	my ($this) = @_;
	return $this->{request};
}

1;