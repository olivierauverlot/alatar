package SqlDataType;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
	my $this = $class->SUPER::new($owner,$name);
 	bless($this,$class);
 	return $this;            
}

sub isSqlDataType {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlDataType';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

# setters and getters
sub setName {
	my ($this,$name) = @_;
	$this->SUPER::setName($name);
	$this->{name} =~ s/\(.*?\)//g;
	$this->{name} = lc($this->{name});
}

1;