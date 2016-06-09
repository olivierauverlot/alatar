package SqlCursor;

use strict;
use SqlArgument;

our @ISA = qw(SqlRequest);

sub new {
	my ($class,$owner,$name,$args,$request) = @_;
	my $this = $class->SUPER::new($owner,$name,$request);
	$this->{args} = [ ];
	$this->{argumentsNumber} = 0;
 	bless($this,$class);      
	$this->_extractArguments($args);
 	return $this;            
}

sub isSqlRequest {
	my ($this) = @_;
	return 0;
}

sub isSqlCursor {
	my ($this) = @_;
	return 1;
}

# Cursor arguments
# ----------------------------------------------------
sub getArgs {
	my ($this) = @_;
	return @{$this->{args}};
}

sub _addArg {
	my ($this,$sqlArg) = @_;
	push(@{$this->{args}},$sqlArg);
	$this->{argumentsNumber} = $this->{argumentsNumber} + 1;
	return $sqlArg;
}

sub printArgs {
	my ($this) = @_;
	return '(' . join(',',@{$this->{args}}) . ')';
}

# arguments number
# ----------------------------------------------------
sub getArgumentsNumber {
	my ($this) = @_;
	return $this->{argumentsNumber};
}

# Action
#  ----------------------------------------------------

# Extract arguments
sub _extractArguments {
	my ($this,$args) = @_;
	my @params = $args =~ /(\w+\s\w+\s?\w*)/g;
	foreach my $param (@params) {
		my @p = $param =~ /(\w+)\s(\w+\s?\w*)/g;
		$this->_addArg(SqlArgument->new($this,$p[0],$p[1]));
	}
}

1;