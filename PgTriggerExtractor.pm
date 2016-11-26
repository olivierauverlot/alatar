package PgTriggerExtractor;

use strict;
use String::Util qw(trim);

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
	my ($this,$code) = @_;

	$this->{entity} = SqlTrigger->new($this->{owner});

	my @items = $code =~ /(.+?)\s(BEFORE|AFTER|INSTEAD\sOF)\s(.*?)\sON\s(.+?)\sFOR\sEACH\s(ROW|STATEMENT)\sEXECUTE\sPROCEDURE\s(.+)\(/gi;
	$this->{entity}->setName($items[0]);
	$this->{entity}->setFire($items[1]);
	my @events = split(/OR/, $items[2]);
	foreach my $event (@events) {
		$this->{entity}->addEvent(trim($event));
	}
	$this->{entity}->setTableName($items[3]);
	$this->{entity}->setLevel($items[4]);
	# pour le moment, on passe 0 arguments (il faudra vérifiquer le nombre d'arguments)
	$this->{entity}->setInvokedFunction(SqlFunctionInvocation->new($this,$items[5],0));
}

1;