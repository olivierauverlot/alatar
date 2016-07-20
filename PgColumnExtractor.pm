package PgColumnExtractor;

use strict;
use Data::Dumper;
use String::Util qw(trim);

use SqlColumn;
use SqlDataType;

use SqlNotNullConstraint;

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
	
	$code = trim($code);

	# we ensure that the code is a real column and not a constraint
	unless($code =~ /CONSTRAINT/g) {
		$this->{entity} = SqlColumn->new($this->{owner},undef,undef);
		# the columns contains a NOT NULL constraint ?
		my @notNullConstraint = $code =~ /NOT\sNULL/g;
		if(@notNullConstraint) {
			$this->getOwner()->addConstraint(SqlNotNullConstraint->new($this->{entity},undef));
			$code =~ s/NOT\sNULL//g;
		}
	
		my @items = $code =~ /(.*?)\s(.*?)$/gi;
		$this->{entity}->setName($items[0]);
		$this->{entity}->setDataType(SqlDataType->new($this->{entity},$items[1]));
		
		# we must fix constraints names for unamed constraints
		foreach my $constraint ($this->getOwner()->getConstraints()) {
			if(!defined($constraint->getName())) {
				$constraint->setName($constraint->buildName($items[0]));
			}
		}
	}
}

1;