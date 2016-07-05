package PgTableExtractor;

use strict;
use String::Util qw(trim);
use Data::Dumper;
use PgColumnExtractor;

our @ISA = qw(PgExtractor);

sub new {
	my ($class,$owner,$code) = @_;
	my $this = $class->SUPER::new($owner,$code);
 	bless($this,$class);
 	return $this;            
}

# actions
# --------------------------------------------------
sub _extractObject {
	my ($this,$table) = @_;
	my ($name,$code) = $table =~ /(.*?)\s\((.*)\)$/gi;
	my $columnExtractor;

	$this->{entity} = SqlTable->new($this->{owner},$name);
	
	my @items =  split(/,/, $code);
	foreach my $item (@items) {
		$columnExtractor = PgColumnExtractor->new($table,$item);
		if(defined($columnExtractor->getEntity())) {
			$this->{entity}->addColumn($columnExtractor->getEntity());
		}
	}
}

1;