package PgColumnExtractor;

use strict;
use String::Util qw(trim);
use Data::Dumper;
use SqlColumn;

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
			$this->{entity}->setNotNull();
			$code =~ s/NOT\sNULL//g;
		}
	
		my @items = $code =~ /(.*?)\s(.*?)$/gi;
		$this->{entity}->setName($items[0]);
		$this->{entity}->setDataType(trim($items[1]));
	}
}

1;