package PgExtension;

use strict;

sub new {
	my ($class,$name,$schema,$comment) = @_;
	my $this = {
		name => $name,
		schema => $schema,
		comment => $comment
	};
 	bless($this,$class);      
 	return $this;            
}

sub getName {
	my ($this) = @_;
	return $this->{name};
}

sub getComment {
	my ($this) = @_;
	return $this->{comment};
}

sub getSchema {
	my ($this) = @_;
	return $this->{schema};
}

1;