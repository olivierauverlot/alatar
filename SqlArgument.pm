package SqlArgument;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$type) = @_;
	my $this = $class->SUPER::new($owner,$name);
   	$this->{type} = $type;
 	bless($this,$class);      
 	return $this;            
}

sub isSqlArgument {
	my ($this) = @_;
	return 1;
}

sub getType {
	my ($this) = @_;
	return $this->{type};
}

1;