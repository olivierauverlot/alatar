package PgFunctionExtractor;

use Data::Dumper;
use strict;
use String::Util qw(trim);
use Regexp::Common;
use Configuration;
use PgExtractor;
use PgKeywords;
use SqlFunction;
use SqlArgument;
use SqlCursor;
use SqlRequest;
use SqlFunctionInvocation;

our @ISA = qw(PgExtractor);

sub new {
	my ($class,$owner,$objects,$code) = @_;
	my $this = $class->SUPER::new($owner,$objects,$code,['func']);
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

sub _extractCursorDefinitions {
	my ($this) = @_;
	my @cursors = $this->{func}->getDeclareSection() =~ /(\w*)\s+CURSOR\s+(.*)FOR\s+(.*\;)/gi;
	for(my $i = 0;$i <= ($#cursors - 1);$i+=2) {
		$this->{func}->addRequest(SqlCursor->new($this->{func},$cursors[$i],$cursors[$i + 1],$cursors[$i + 2]));
		push(@{$this->{func}->{cursors}},$cursors[$i]);
	}
}

# Return a formated name for cursors and request
sub _buildName {
	my ($this,$type,$id) = @_;
	return ($this->{func}->getName() . '_' . $this->{func}->getArgumentsNumber() . '_' . $type . '_' . $id);
}

sub _extractRequests {
	my ($this) = @_;
	my $reqNumber;
	my @requests = $this->{func}->getBodySection() =~ /(SELECT|UPDATE|INSERT|DELETE)(.*?)(;)/gi;
	$reqNumber = 0;
	for(my $i = 0;$i <= ($#requests - 2);$i+=3) {
		my $request = "$requests[$i]$requests[$i + 1];";
		# If the exclude option is true, the SQL request is deleted to avoid the referencement of the invoked functions	
		if(Configuration->getOption('exclude')) {
			my $reqPattern = quotemeta($request);
			my $body = $this->{func}->getBodySection();
			$this->{func}->setBodySection($body =~ s/$reqPattern//gi);
		}
		$reqNumber = $reqNumber + 1;
		$this->{func}->addRequest(SqlRequest->new($this->{func},$this->_buildName('R',$reqNumber),$request));
	}
}

# validate that the function name is not a cursor name
sub _isNotCursorName {
	my ($this,$cursorName) = @_;
	return !(grep {$_ eq $cursorName} @{$this->{func}->{cursors}})
}

sub _extractInvokedFunctions {
	my ($this,$code) = @_;
	my @funcs = $code =~ /(\w+)$RE{balanced}{-parens=>'( )'}/g;
	for(my $i = 0;$i <= ($#funcs - 1);$i+=2) {
		# Before to add it at the invoked functions list, we must validate that it's not a cursor and it's not a PostgreSQL keyword
		if($this->_isNotCursorName($funcs[$i]) && PgKeywords->isNotKeyword($funcs[$i])) {
			$this->{func}->addInvokedFunction(SqlFunctionInvocation->new($this->{func},$funcs[$i],$this->_extractArgumentsNumber($funcs[$i+1])));
			$this->_extractInvokedFunctions($funcs[$i+1]);
		}
	}
}

sub _extractNewOldColumns {
	my ($this,$code) = @_;
	my @news = $code =~ /NEW.([\w\_\$\d]+)/gi;
	my @olds = $code =~ /OLD.([\w\_\$\d]+)/gi;
	foreach my $new (@news) {
		$this->{func}->addNewColumn($new);
	}
	foreach my $old (@olds) {
		$this->{func}->addOldColumn($old);
	}
}

sub _extractObject {
	my ($this,$code) = @_;
	my @items = $code =~ /(\"?(\w+)\"?\(((\w*\s\w*),?)*\))/i;
	
	$this->{func} = SqlFunction->new($this->{owner},$items[1]);
	$this->{func}->setSignature($items[0]);
	
	@items = $code =~ /RETURNS\s(\w+\s?\w*)/i;
	if(@items) {
		$this->{func}->setReturnType(trim($items[0])); 
	}	
	@items = $code =~ /LANGUAGE\s*(\w*)/i;
	if(@items) {
		$this->{func}->setLanguage($items[0]);
	}
	# Extract the declare and the body sections 
	# only for pg/plsql functions
	my ($declare) = $code =~ /DECLARE(.*)BEGIN/i;
	if($declare) {
		$this->{func}->setDeclareSection($declare);
	}
	my ($body) = $code =~ /BEGIN\s(.*)/i;
	if($body) {
		$this->{func}->setBodySection($body);
	}
	
	# Extract the function arguments
	my @params = $this->{func}->getSignature() =~ /(\w+\s\w+\s?\w*)/g;
	foreach my $param (@params) {
		my @p = $param =~ /(\w+)\s(\w+\s?\w*)/g;
		$this->{func}->addArg(SqlArgument->new($this->{func},$p[0],$p[1]));
	}
	if(@params != undef) {
		$this->{func}->setArgumentsNumber(scalar(@params));
	} else { $this->{func}->setArgumentsNumber(0); }
	
	$this->_extractCursorDefinitions();
	$this->_extractRequests();
	$this->_extractInvokedFunctions($this->{func}->getBodySection());

	if($this->{func}->getReturnType() eq 'trigger') {
		$this->_extractNewOldColumns($this->{func}->getBodySection());
	}
	$this->addObject($this->{func});
}


1;