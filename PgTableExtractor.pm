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
	my ($name,$code) = $table =~ /\"?(.*?)\"?\s\((.*)\)$/gi;
	my $columnExtractor;

	$this->{entity} = SqlTable->new($this->{owner},$name);
	
	my @items =  split(/,/, $code);
	foreach my $item (@items) {
		$columnExtractor = PgColumnExtractor->new($this->{entity},$item);
		my $column = $columnExtractor->getEntity();
		if(defined($column)) {
			$this->{entity}->addColumn($column);
		}
	}

	# we must fix constraints names for unamed constraints
	foreach my $constraint ($this->{entity}->getConstraints()) {
		if(!defined($constraint->getName())) {
			$constraint->setName($constraint->buildName($this->{entity}->getName()));
		}
	}

	# Listing pour debuggage
=pod
	print "TABLE " . $this->{entity}->getName() . "\n;"
	foreach my $constraint ($this->{entity}->getConstraints()) {
		if($constraint->isSqlNotNullConstraint()) {
			foreach my $c ($constraint->getColumns()) {
				print $c->getName() . "\n";
			}
		}
	}	
=cut
}

1;