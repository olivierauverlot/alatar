package SqlView;

use Data::Dumper;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{request} = undef;
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
	$this->{request} = $request;
}

sub getSqlRequest {
	my ($this) = @_;
	return $this->{request};
}

1;