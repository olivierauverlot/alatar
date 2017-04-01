package Alatar::Model::SqlFunction;

use strict;
use Data::Dumper;
use Alatar::Model::SqlObject;
use Alatar::Model::SqlRequest;
use Alatar::Model::SqlCursor;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name) = @_;
 	my $this = $class->SUPER::new($owner,$name);
 	$this->{args} = [ ];
  	$this->{argumentsNumber} = 0;
  	$this->{bodySection} = '';
   	$this->{comments} = 0;
    $this->{cursors} = [ ];
 	$this->{declareSection} = '';
  	$this->{invokedFunctions} = [ ];
 	$this->{language} = '';
  	$this->{newColumns} = [ ];
   	$this->{oldColumns} = [ ];
  	$this->{requests} = [ ];
 	$this->{returnType} = undef;
 	$this->{signature} = '';
 	bless($this,$class);    
 	return $this;            
}

sub isSqlFunction {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlFunction';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' with ' . $this->getArgumentsNumber();
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

sub getReturnTypeName {
	my ($this) = @_;
	return $this->{returnType}->getTarget()->getName();
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

# raw section
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
	return $invocation;
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

sub addNewColumn {
	my ($this,$columnName) = @_;
	push(@{$this->{newColumns}},$columnName);
	return $columnName;
}

sub getOldColumns {
	my ($this) = @_;
	return @{$this->{oldColumns}};
}

sub addOldColumn {
	my ($this,$columnName) = @_;
	push(@{$this->{oldColumns}},$columnName);
}


=begin
CREATE TYPE dup_result AS (f1 int, f2 text);

CREATE FUNCTION dup(int) RETURNS dup_result
    AS $$ SELECT $1, CAST($1 AS text) || ' is text' $$
    LANGUAGE SQL;
=cut



1;
