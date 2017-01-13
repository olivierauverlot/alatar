package PgRuleExtractor;

use strict;
use String::Util qw(trim);
use Data::Dumper;

use SqlRule;
use SqlTableReference;
use SqlRequest;

use constant NAME => 0;
use constant EVENT => 1;
use constant TABLE => 2;
use constant MODE => 3;
use constant REQUEST => 4;

our @ISA = qw(PgExtractor);

sub new {
	my ($class,$owner,$code) = @_;
	my $this = $class->SUPER::new($owner,$code);
 	bless($this,$class);
 	return $this;            
}

#CREATE RULE "_RETURN" AS ON SELECT TO web_equipes_cristal DO INSTEAD SELECT DISTINCT equipeexterne.nom,

# actions
# --------------------------------------------------

# Return a formated name for request
sub _buildName {
	my ($this,$table) = @_;
	return ($table . '_' . $this->{entity}->getName() . '_' . $this->{entity}->getEvent());
}

sub _extractObject {
	my ($this,$code) = @_;

	my @items = $code =~ /"?(.*?)"?\sAS\sON\s(.*?)\sTO\s(.*?)\sDO\s(.*?)\s(.*)/gi;
	
	$this->{entity} = SqlRule->new($this->{owner},$items[NAME]);
	$this->{entity}->setEvent($items[EVENT]);
	$this->{entity}->setTable(SqlTableReference->new($this->getOwner(),$items[NAME],$items[TABLE]));
	if($items[MODE] eq 'INSTEAD') {
		$this->{entity}->setInsteadMode();
	} else {
		$this->{entity}->setAlsoMode();
	}
	# $owner,$name,$request
	$this->{entity}->setSqlRequest(SqlRequest->new($this,$this->_buildName($items[TABLE]),($items[REQUEST] . ';')));
}
	
1;