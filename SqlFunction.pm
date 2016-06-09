package SqlFunction;

use strict;
use Data::Dumper;
use String::Util qw(trim);
use Regexp::Common;
use Configuration;
use PgKeywords;
use SqlObject;
use SqlArgument;
use SqlFunctionInvocation;
use SqlRequest;
use SqlCursor;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$code) = @_;
 	my $this = $class->SUPER::new($owner);
 	$this->{args} = [ ];
 	$this->{returnType} = '';
 	$this->{language} = '';
 	$this->{signature} = '';
 	$this->{argumentsNumber} = 0;
 	$this->{comments} = 0;
 	$this->{declareSection} = '';
 	$this->{bodySection} = '';
 	$this->{invokedFunctions} = [ ];
 	$this->{callers} = [ ];
 	$this->{requests} = [ ];
 	$this->{newColumns} = [ ];
 	$this->{oldColumns} = [ ];
 	$this->{_cursors} = [ ];
 	bless($this,$class);    
 	$this->_extractFunctionStructure($code);
 	return $this;            
}

sub isSqlFunction {
	my ($this) = @_;
	return 1;
}

# Function arguments
# ----------------------------------------------------
sub getArgs {
	my ($this) = @_;
	return @{$this->{args}};
}

sub _addArg {
	my ($this,$sqlArg) = @_;
	push(@{$this->{args}},$sqlArg);
	$this->{argumentsNumber} = $this->{argumentsNumber} + 1;
	return $sqlArg;
}

sub printArgs {
	my ($this) = @_;
	return '(' . join(',',@{$this->{args}}) . ')';
}

# Return type
# ----------------------------------------------------
sub getReturnType {
	my ($this) = @_;
	return $this->{returnType};
}

sub setReturnType {
	my ($this,$returnType) = @_;
	$this->{returnType} = $returnType;
}

# Language
# ----------------------------------------------------
sub getLanguage {
	my ($this) = @_;
	return $this->{language};
}

sub setLanguage {
	my ($this,$language) = @_;
	$this->{language} = $language;
}

# Function signature
# ----------------------------------------------------
sub getSignature {
	my ($this) = @_;
	return $this->{signature};
}

sub setSignature {
	my ($this,$signature) = @_;
	$this->{signature} = $signature;
}

# arguments number
# ----------------------------------------------------
sub getArgumentsNumber {
	my ($this) = @_;
	return $this->{argumentsNumber};
}

sub setArgumentsNumber {
	my ($this,$argumentsNumber) = @_;
	$this->{argumentsNumber} = $argumentsNumber;
}

# Raw code sections
# ----------------------------------------------------
sub getDeclareSection {
	my ($this) = @_;
	return $this->{declareSection};
}

sub _setDeclareSection {
	my ($this,$declareSection) = @_;
	$this->{declareSection} = $declareSection;	
}

sub getBodySection {
	my ($this) = @_;
	return $this->{bodySection};
}

sub _setBodySection {
	my ($this,$bodySection) = @_;
	$this->{bodySection} = $bodySection;	
}

# Invoked functions
# ----------------------------------------------------
sub getInvokedFunctions {
	my ($this) = @_;
	return @{$this->{invokedFunctions}};
}

sub addInvokedFunction {
	my ($this,$invocation) = @_;
	push(@{$this->{invokedFunctions}},$invocation);
	return $invocation;
}

# Called By
# The functions that call this function
# ----------------------------------------------------
sub getCallers {
	my ($this) = @_;
	return @{$this->{callers}};
}

sub addCaller {
	my ($this,$caller) = @_;
	push(@{$this->{callers}},$caller);
	return $caller;
}

# Used Requests
# ----------------------------------------------------
sub getAllRequests {
	my ($this) = @_;
	return @{$this->{requests}};
}

sub getSqlRequests {
	my ($this) = @_;
	my @requests;
	foreach my $r ($this->getAllRequests()) {
		if($r->isSqlRequest()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSqlCursorRequests {
	my ($this) = @_;
	my @requests;
	foreach my $r ($this->getAllRequests()) {
		if($r->isSqlCursor()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub addRequest {
	my ($this,$request) = @_;
	push(@{$this->{requests}},$request);
	return $request;
}

# trigger
# ----------------------------------------------------
sub isTriggerFunction {
	my ($this) = @_;
	return ($this->{returnType} eq 'trigger');
}

# Function comments
# ----------------------------------------------------
sub hasComments {
	my ($this) = @_;
	$this->{comments} = 1;
}

sub isCommented {
	my ($this) = @_;
	return $this->{comments};
}

# NEW and OLD columns
# We use the column name but it will better  
# to use a column reference
# ----------------------------------------------------
sub getNewColumns {
	my ($this) = @_;
	return @{$this->{newColumns}};
}

sub _addNewColumn {
	my ($this,$columnName) = @_;
	push(@{$this->{newColumns}},$columnName);
	return $columnName;
}

sub getOldColumns {
	my ($this) = @_;
	return @{$this->{oldColumns}};
}

sub _addOldColumn {
	my ($this,$columnName) = @_;
	push(@{$this->{oldColumns}},$columnName);
}

# Actions
# ----------------------------------------------------

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

# Return a formated name for cursors and request
sub _buildName {
	my ($this,$type,$id) = @_;
	return ($this->getName . '_' . $type . '_' . $id);
}

sub _extractCursorDefinitions {
	my ($this) = @_;
	my @cursors = $this->getDeclareSection() =~ /(\w*)\s+CURSOR\s+(.*)FOR\s+(.*\;)/gi;
	for(my $i = 0;$i <= ($#cursors - 1);$i+=2) {
		$this->addRequest(SqlCursor->new($this,$cursors[$i],$cursors[$i + 1],$cursors[$i + 2]));
		push(@{$this->{_cursors}},$cursors[$i]);
	}
}

sub _extractRequests {
	my ($this) = @_;
	my $reqNumber;
	my @requests = $this->getBodySection() =~ /(SELECT|UPDATE|INSERT|DELETE)(.*?)(;)/gi;
	$reqNumber = 0;
	for(my $i = 0;$i <= ($#requests - 2);$i+=3) {
		my $request = "$requests[$i]$requests[$i + 1];";
		# If the exclude option is true, the SQL request is deleted to avoid the referencement of the invoked functions	
		if(Configuration->getOption('exclude')) {
			my $reqPattern = quotemeta($request);
			my $body = $this->getBodySection();
			$this->_setBodySection($body =~ s/$reqPattern//gi);
		}
		$reqNumber = $reqNumber + 1;
		$this->addRequest(SqlRequest->new($this,$this->_buildName('R',$reqNumber),$request));
	}
}

# validate that the function name is not a cursor name
sub _isNotCursorName {
	my ($this,$cursorName) = @_;
	return !(grep {$_ eq $cursorName} @{$this->{_cursors}})
}

sub _extractInvokedFunctions {
	my ($this,$code) = @_;
	my @funcs = $code =~ /(\w+)$RE{balanced}{-parens=>'( )'}/g;
	for(my $i = 0;$i <= ($#funcs - 1);$i+=2) {
		# Before to add it at the invoked functions list, we must validate that it's not a cursor and it's not a PostgreSQL keyword
		if($this->_isNotCursorName($funcs[$i]) && PgKeywords->isNotKeyword($funcs[$i])) {
			$this->addInvokedFunction(SqlFunctionInvocation->new($this,$funcs[$i],$this->_extractArgumentsNumber($funcs[$i+1])));
			$this->_extractInvokedFunctions($funcs[$i+1]);
		}
	}
}

sub _extractNewOldColumns {
	my ($this,$code) = @_;
	my @news = $code =~ /NEW.([\w\_\$\d]+)/gi;
	my @olds = $code =~ /OLD.([\w\_\$\d]+)/gi;
	foreach my $new (@news) {
		$this->_addNewColumn($new);
	}
	foreach my $old (@olds) {
		$this->_addOldColumn($old);
	}
}

sub _extractFunctionStructure {
	my ($this,$code) = @_;
	my @items = $code =~ /((\"?(\w+)\"?\(((\w*\s\w*),?)*\))\sRETURNS\s(\w+\s?\w*)\s*LANGUAGE\s*(\w*))/i;
	$this->setSignature($items[1]);
	$this->setName($items[2]);
	$this->setReturnType(trim($items[5])); 
	$this->setLanguage($items[6]);
	
	# Extract the declare and the body sections 
	my ($declare) = $code =~ /DECLARE(.*)BEGIN/i;
	if($declare) {
		$this->_setDeclareSection($declare);
	}
	my ($body) = $code =~ /BEGIN\s(.*)/i;
	if($body) {
		$this->_setBodySection($body);
	}
	
	# Extract the function arguments
	my @params = $items[1] =~ /(\w+\s\w+\s?\w*)/g;
	foreach my $param (@params) {
		my @p = $param =~ /(\w+)\s(\w+\s?\w*)/g;
		$this->_addArg(SqlArgument->new($this,$p[0],$p[1]));
	}
	if(@params != undef) {
		$this->setArgumentsNumber(scalar(@params));
	} else { $this->setArgumentsNumber(0); }
	
	$this->_extractCursorDefinitions();
	$this->_extractRequests();
	$this->_extractInvokedFunctions($this->getBodySection());
	if($this->getReturnType() eq 'trigger') {
		$this->_extractNewOldColumns($this->getBodySection());
	}
}

1;
