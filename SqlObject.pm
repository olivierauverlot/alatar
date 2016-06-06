package SqlObject;

use strict;

sub new {
	my ($class,$owner,$name) = @_;
	my $this = {
		owner => $owner,
		name => ''
	};
 	bless($this,$class);      
 	return $this;            
}

sub getOwner {
	my ($this) = @_;
	return $this->{owner};
}

sub getName {
	my ($this) = @_;
	return $this->{name};
}

sub setName {
	my ($this,$name) = @_;
	$this->{name} = $name;
}

sub isSqlTable {
	my ($this) = @_;
	return 0;
}

sub isSqlView {
	my ($this) = @_;
	return 0;
}

sub isSqlTrigger {
	my ($this) = @_;
	return 0;
}

sub isSqlSequence {
	my ($this) = @_;
	return 0;
}

sub isSqlFunction {
	my ($this) = @_;
	return 0;
}

sub isSqlArgument {
	my ($this) = @_;
	return 0;
}

sub isSqlFunctionInvocation {
	my ($this) = @_;
	return 0;
}

sub isSqlCursor {
	my ($this) = @_;
	return 0;
}

sub getName {
	my ($this) = @_;
	return $this->{name};
}

1;