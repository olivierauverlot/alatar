package Alatar::PostgreSQL::Extractors::PgColumnExtractor;

use strict;
use Data::Dumper;
use String::Util qw(trim);

use Alatar::Model::SqlColumn;
use Alatar::Model::SqlNotNullConstraint;
use Alatar::Model::SqlColumnReference;

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
	
	$code = trim($code);

	# we ensure that the code is a real column and not a constraint
	unless($code =~ /CONSTRAINT/g) {
		
		my $notNull = undef;
		$this->{entity} = Alatar::Model::SqlColumn->new($this->{owner},undef,undef);
		
		# the column contains a NOT NULL constraint ?
		my @notNullConstraint = $code =~ /NOT\sNULL/g;

		if(@notNullConstraint) {
			$notNull = Alatar::Model::SqlNotNullConstraint->new($this->getOwner(),undef);
			$code =~ s/NOT\sNULL//g;
		}
	
		# the column contains a DEFAULT constraint ?
		# TODO
		my @defaultConstraint = $code =~ /(DEFAULT\s(.*)?)/g;
		if(@defaultConstraint) {
			my $string =  quotemeta($defaultConstraint[0]);
			$code =~s/$string//g;
		}
		
		# read the column name and datatype
		my @items = $code =~ /(.*?)\s(.*?)$/gi;
		# print "$code\n";
		$this->{entity}->setName($items[0]);
		$this->{entity}->setDataType(Alatar::Model::Refs::SqlDataTypeReference->new($this->{entity},$items[1]));
	
		if(defined($notNull)) {
			my $db = $this->getOwner()->getOwner();
			my $columnReference = Alatar::Model::SqlColumnReference->new($db,undef,$this->getOwner(),$this->{entity});
			$notNull->addColumn($columnReference);
			$this->getOwner()->addConstraint($notNull);
		}
	}
}

1;