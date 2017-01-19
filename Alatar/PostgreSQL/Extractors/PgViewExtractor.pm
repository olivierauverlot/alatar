package Alatar::PostgreSQL::Extractors::PgViewExtractor;

use strict;
use String::Util qw(trim);
use Data::Dumper;
use Alatar::Model::SqlView;
use Alatar::Model::SqlRequest;
use Alatar::PostgreSQL::Extractors::PgExtractor;

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
	my ($this,$view) = @_;
	my ($name,$code) = $view =~ /\"?(.*?)\"?\sAS\s(.*)/gi;
	my $reqSql;
	
	$this->{entity} = Alatar::Model::SqlView->new($this->{owner},$name);
	$reqSql = Alatar::Model::SqlRequest->new($this->{entity},($name . '_R',(trim($code) . ';')));
	$this->{entity}->setSqlRequest($reqSql);
}