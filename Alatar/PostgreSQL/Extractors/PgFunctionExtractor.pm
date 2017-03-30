package Alatar::PostgreSQL::Extractors::PgFunctionExtractor;

use Data::Dumper;
use strict;
use String::Util qw(trim);
use Regexp::Common;
use Alatar::Configuration;
use Alatar::PostgreSQL::Extractors::PgExtractor;
use Alatar::PostgreSQL::Extractors::PgTableExtractor;
use Alatar::PostgreSQL::PgKeywords;
use Alatar::Model::SqlFunction;
use Alatar::Model::SqlArgument;
use Alatar::Model::SqlCursor;
use Alatar::Model::SqlRequest;
use Alatar::Model::Refs::SqlFunctionReference;
use Alatar::Model::Refs::SqlDataTypeReference;

our @ISA = qw(Alatar::PostgreSQL::Extractors::PgExtractor);

sub new {
	my ($class,$owner,$code) = @_;
	my $this = $class->SUPER::new($owner,$code);
 	bless($this,$class);
 	return $this;            
}

# actions
# --------------------------------------------------

# Return the number of function's arguments
sub _extractArgumentsNumber {
	my ($this,$arguments) = @_;
	
	my @args = $arguments =~ /^\((.*?)\)$/g;
	if($args[0] eq '') {
		return 0;
	} else {
		my @commas = $args[0] =~ /(\,)/g;
		my $numberOfCommas = scalar(@commas);
		if($numberOfCommas >= 1) {
			return $numberOfCommas + 1;
		} else {
			return 1;
		}
	}
}

# Create cursor definitions contained in a function
sub _extractCursorDefinitions {
	my ($this) = @_;
	my @cursors = $this->{entity}->getDeclareSection() =~ /(\w*)\s+CURSOR\s+(.*)FOR\s+(.*\;)/gi;
	for(my $i = 0;$i <= ($#cursors - 1);$i+=2) {
		$this->{entity}->addRequest(Alatar::Model::SqlCursor->new($this->{entity},$cursors[$i],$cursors[$i + 1],$cursors[$i + 2]));
		push(@{$this->{entity}->{cursors}},$cursors[$i]);
	}
}

# Return a formated name for cursors and request
sub _buildName {
	my ($this,$type,$id) = @_;
	return ($this->{entity}->getName() . '_' . $this->{entity}->getArgumentsNumber() . '_' . $type . '_' . $id);
}

sub _extractRequests {
	my ($this) = @_;
	my $reqNumber;
	my @requests = $this->{entity}->getBodySection() =~ /(SELECT|UPDATE|INSERT|DELETE)\s(.*?)(;)/gi;
	$reqNumber = 0;
	for(my $i = 0;$i <= ($#requests - 2);$i+=3) {
		my $request = "$requests[$i] $requests[$i + 1];";
		# If the exclude option is true, the SQL request is deleted to avoid the referencement of the invoked functions	
		if(Alatar::Configuration->getOption('exclude')) {
			my $reqPattern = quotemeta($request);
			my $body = $this->{entity}->getBodySection();
			$this->{entity}->setBodySection($body =~ s/$reqPattern//gi);
		}
		$reqNumber = $reqNumber + 1;
		$this->{entity}->addRequest(Alatar::Model::SqlRequest->new($this->{entity},$this->_buildName('R',$reqNumber),$request));
	}
}

# validate that the function name is not a cursor name
sub _isNotCursorName {
	my ($this,$cursorName) = @_;
	return !(grep {$_ eq $cursorName} @{$this->{entity}->{cursors}})
}

sub _extractInvokedFunctions {
	my ($this,$code) = @_;
	my @funcs = $code =~ /(\w+)$RE{balanced}{-parens=>'( )'}/g;
	for(my $i = 0;$i <= ($#funcs - 1);$i+=2) {
		# Before to add it at the invoked functions list, we must validate that it's not a cursor and it's not a PostgreSQL keyword
		if($this->_isNotCursorName($funcs[$i]) && Alatar::PostgreSQL::PgKeywords->isNotKeyword($funcs[$i])) {
			$this->{entity}->addInvokedFunction(Alatar::Model::Refs::SqlFunctionReference->new($this->{entity},$funcs[$i],$this->_extractArgumentsNumber($funcs[$i+1])));
			$this->_extractInvokedFunctions($funcs[$i+1]);
		}
	}
}

sub _extractNewOldColumns {
	my ($this,$code) = @_;
	my @news = $code =~ /NEW.([\w\_\$\d]+)/gi;
	my @olds = $code =~ /OLD.([\w\_\$\d]+)/gi;
	foreach my $new (@news) {
		$this->{entity}->addNewColumn($new);
	}
	foreach my $old (@olds) {
		$this->{entity}->addOldColumn($old);
	}
}

sub _extractObject {
	my ($this,$code) = @_;
	my @items = $code =~ /(\"?(\w+)\"?\(((\w*\s\w*),?)*\))/i;
	
	$this->{entity} = Alatar::Model::SqlFunction->new($this->{owner},$items[1]);
	$this->{entity}->setSignature($items[0]);
	@items = $code =~ /RETURNS\s(\w+\s?\w*)/i;
	if(@items) {
		$this->{entity}->setReturnType(Alatar::Model::Refs::SqlDataTypeReference->new($this->{entity},$items[0])); 
	}	
	@items = $code =~ /LANGUAGE\s*(\w*)/i;
	if(@items) {
		$this->{entity}->setLanguage($items[0]);
	}
	# Extract the declare and the body sections 
	# only for pg/plsql functions
	my ($declare) = $code =~ /DECLARE(.*)BEGIN/i;
	if($declare) {
		$this->{entity}->setDeclareSection($declare);
	}
	my ($body) = $code =~ /BEGIN\s(.*)/i;
	if($body) {
		$this->{entity}->setBodySection($body);
	}
	
	# Extract the function arguments
	my @params = $this->{entity}->getSignature() =~ /(\w+\s\w+\s?\w*)/g;
	foreach my $param (@params) {
		my @p = $param =~ /(\w+)\s(\w+\s?\w*)/g;
		$this->{entity}->addArg(Alatar::Model::SqlArgument->new($this->{entity},$p[0],Alatar::Model::Refs::SqlDataTypeReference->new($this->{entity},$p[1])));
	}
	if(@params) {
		$this->{entity}->setArgumentsNumber(scalar(@params));
	} else { $this->{entity}->setArgumentsNumber(0); }
	
	$this->_extractCursorDefinitions();
	$this->_extractRequests();
	$this->_extractInvokedFunctions($this->{entity}->getBodySection());
	
	if($this->{entity}->getReturnType()->getName() eq 'trigger') {
		$this->_extractNewOldColumns($this->{entity}->getBodySection());
	}
}

1;