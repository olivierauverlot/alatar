package Alatar::PostgreSQL::Extractors::PgTriggerExtractor;

use strict;
use String::Util qw(trim);

our @ISA = qw(Alatar::PostgreSQL::Extractors::PgExtractor);

sub new {
	my ($class,$owner,$code) = @_;
	my $this = $class->SUPER::new($owner,$code);
 	bless($this,$class);
 	return $this;            
}

# actions
# --------------------------------------------------
sub _extractObject {
	my ($this,$code) = @_;

	$this->{entity} = Alatar::Model::SqlTrigger->new($this->{owner});

	my @items = $code =~ /(.+?)\s(BEFORE|AFTER|INSTEAD\sOF)\s(.*?)\sON\s(.+?)\sFOR\sEACH\s(ROW|STATEMENT)\sEXECUTE\sPROCEDURE\s(.+)\(/gi;
	$this->{entity}->setName($items[0]);
	$this->{entity}->setFire($items[1]);
	my @events = split(/OR/, $items[2]);
	foreach my $event (@events) {
		$this->{entity}->addEvent(trim($event));
	}
	$this->{entity}->setTableReference(Alatar::Model::Refs::SqlTableReference->new($this,$items[3]));
	
	$this->{entity}->setLevel($items[4]);
	# pour le moment, on passe 0 arguments (il faudra vérifiquer le nombre d'arguments)
	$this->{entity}->setInvokedFunctionReference(Alatar::Model::Refs::SqlFunctionReference->new($this,$items[5],0));
}

1;