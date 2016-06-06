package SqlFunction;

use strict;
use Data::Dumper;
use String::Util qw(trim);
use Regexp::Common;
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
 	bless($this,$class);    
 	$this->extractFunctionStructure($code);
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

sub addArg {
	my ($this,$sqlArg) = @_;
	push(@{$this->{args}},$sqlArg);
	$this->{argumentsNumber} = $this->{argumentsNumber} + 1;
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

sub setDeclareSection {
	my ($this,$declareSection) = @_;
	$this->{declareSection} = $declareSection;	
}

sub getBodySection {
	my ($this) = @_;
	return $this->{bodySection};
}

sub setBodySection {
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

sub addNewColumn {
	my ($this,$columnName) = @_;
	push(@{$this->{newColumns}},$columnName);
}

sub getOldColumns {
	my ($this) = @_;
	return @{$this->{oldColumns}};
}

sub addOldColumn {
	my ($this,$columnName) = @_;
	push(@{$this->{oldColumns}},$columnName);
}

# Actions
# ----------------------------------------------------

# Return the number of function's arguments
sub extractArgumentsNumber {
	my ($this,$arguments) = @_;
	return scalar(split(/,/, $arguments));
}

# Return a formated name for cursors and request
sub buildName {
	my ($this,$type,$id) = @_;
	return ($this->getName . '_' . $type . '_' . $id);
}

sub extractCursorDefinitions {
	my ($this) = @_;
	my @cursors = $this->getDeclareSection() =~ /(\w*)\s+CURSOR\s+(.*)FOR\s+(.*\;)/g;
	for(my $i = 0;$i <= ($#cursors - 1);$i+=2) {
		$this->addRequest(SqlCursor->new($this,$cursors[$i],$cursors[$i + 1],$cursors[$i + 2]));
	}
}

sub extractRequests {
	my ($this) = @_;
	my $reqNumber;
	my @requests = $this->getBodySection() =~ /(SELECT|UPDATE|INSERT|DELETE)(.*?)(;)/g;
	$reqNumber = 0;
	for(my $i = 0;$i <= ($#requests - 2);$i+=2) {
		# Effacement de la requête pour que les fonctions contenues ne soient pas référencées
		# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		# --- Code temporaire ---
		my $request = "$requests[$i]$requests[$i + 1];";
		my $reqPattern = quotemeta($request);
		my $body = $this->getBodySection();
		$this->setBodySection($body =~ s/$reqPattern//g);
		# -----------------------
		$reqNumber = $reqNumber + 1;
		$this->addRequest(SqlRequest->new($this,$this->buildName('R',$reqNumber),$request));
	}
}

sub extractInvokedFunctions {
	my ($this,$code) = @_;
	my @funcs = $code =~ /((\w+)$RE{balanced}{-parens=>'( )'})/g;
	for(my $i = 0;$i <= ($#funcs - 2);$i+=3) {
		$this->addInvokedFunction(SqlFunctionInvocation->new($this,$funcs[$i+1],$this->extractArgumentsNumber($funcs[$i+2])));
		$this->extractInvokedFunctions($funcs[$i+2]);
	}
}

sub extractNewOldColumns {
	my ($this,$code) = @_;
	my @news = $code =~ /NEW.([\w\_\$\d]+)/g;
	my @olds = $code =~ /OLD.([\w\_\$\d]+)/g;
	foreach my $new (@news) {
		$this->addNewColumn($new);
	}
	foreach my $old (@olds) {
		$this->addOldColumn($old);
	}
}

sub extractFunctionStructure {
	my ($this,$code) = @_;
	my @items = $code =~ /((\"?(\w+)\"?\(((\w*\s\w*),?)*\))\sRETURNS\s(\w+\s?\w*)\s*LANGUAGE\s*(\w*))/;
	$this->setSignature($items[1]);
	$this->setName($items[2]);
	$this->setReturnType(trim($items[5])); 
	$this->setLanguage($items[6]);
	
	# Extract the declare and the body sections 
	my ($declare) = $code =~ /DECLARE(.*)BEGIN/;
	if($declare) {
		$this->setDeclareSection($declare);
	}
	my ($body) = $code =~ /BEGIN\s(.*)/;
	if($body) {
		$this->setBodySection($body);
	}
	
	# Extract the function arguments
	my @params = $items[1] =~ /(\w+\s\w+\s?\w*)/g;
	foreach my $param (@params) {
		my @p = $param =~ /(\w+)\s(\w+\s?\w*)/g;
		$this->addArg(SqlArgument->new($this,$p[0],$p[1]));
	}
	if(@params != undef) {
		$this->setArgumentsNumber(scalar(@params));
	} else { $this->setArgumentsNumber(0); }
	
	$this->extractCursorDefinitions();
	$this->extractRequests();
	$this->extractInvokedFunctions($this->getBodySection());
	if($this->getReturnType() eq 'trigger') {
		$this->extractNewOldColumns($this->getBodySection());
	}
}

1;
