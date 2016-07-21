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
		
		my $notNull = undef;
		$this->{entity} = SqlColumn->new($this->{owner},undef,undef);
		
		# the columns contains a NOT NULL constraint ?
		my @notNullConstraint = $code =~ /NOT\sNULL/g;

		if(@notNullConstraint) {
			$notNull = SqlNotNullConstraint->new($this->getOwner(),undef);
			$code =~ s/NOT\sNULL//g;
		}
	
		my @items = $code =~ /(.*?)\s(.*?)$/gi;
		$this->{entity}->setName($items[0]);
		$this->{entity}->setDataType(SqlDataType->new($this->{entity},$items[1]));
	
		if(defined($notNull)) {
			my $db = $this->getOwner()->getOwner();
			my $columnReference = SqlColumnReference->new($db,undef,$this->getOwner(),$this->{entity});
			$notNull->addColumn($this->{entity});
			$this->getOwner()->addConstraint($notNull);
		}
		
	}
}

1;