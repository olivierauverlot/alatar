package Alatar::PostgreSQL::Extractors::PgSequenceExtractor;

use strict;
use String::Util qw(trim);
use Data::Dumper;

use Alatar::Model::SqlSequence;

use constant NAME => 0;

our @ISA = qw(Alatar::PostgreSQL::Extractors::PgExtractor);

sub new {
	my ($class,$owner,$code) = @_;
	my $this = $class->SUPER::new($owner,$code);
 	bless($this,$class);
 	return $this;            
}

sub _extractObject {
	my ($this,$code) = @_;

	my @items = $code =~ /(.*?)\s/gi;
	$this->{entity} = Alatar::Model::SqlSequence->new($this->{owner},$items[NAME]);
}
	
1;