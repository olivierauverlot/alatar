package PgViewExtractor;

use strict;
use String::Util qw(trim);
use Data::Dumper;
use SqlView;
use SqlRequest;
use PgExtractor;

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
	my ($this,$view) = @_;
	my ($name,$code) = $view =~ /\"?(.*?)\"?\sAS\s(.*)/gi;
	my $reqSql;
	
	$this->{entity} = SqlView->new($this->{owner},$name);
	$reqSql = SqlRequest->new($this->{entity},($name . '_R',$code));
	$this->{entity}->setSqlRequest($reqSql);
}