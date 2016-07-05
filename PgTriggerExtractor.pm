package PgTriggerExtractor;

use strict;

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
	
	my @items = $code =~ /(.+?)\s(BEFORE|AFTER|INSTEAD\sOF)\s(INSERT|UPDATE|DELETE|TRUNCATE)\sON\s(.+?)\sFOR\sEACH\s(ROW|STATEMENT)\sEXECUTE\sPROCEDURE\s(.+)\(/gi;
	$this->{entity}->setName($items[0]);
	$this->{entity}->setFire($items[1]);
	$this->{entity}->setEvent($items[2]);
	$this->{entity}->setTable($items[3]);
	$this->{entity}->setLevel($items[4]);
	# pour le moment, on passe 0 arguments (il faudra vérifiquer le nombre d'arguments)
	$this->{entity}->setInvokedFunction(SqlFunctionInvocation->new($this,$items[5],0));
}

1;