package Alatar::Model::SqlRequest;

use strict;
use Data::Dumper;
# use SQL::Statement;
use Alatar::Model::SqlObject;

our @ISA = qw(Alatar::Model::SqlObject);

sub new {
	my ($class,$owner,$name,$request) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{_request} = $request;
	
	# Enable this line to activate the SQL Parser
	# $this->parseSqlRequest();
 	
 	bless($this,$class);      
 	return $this;            
}

sub isSqlRequest {
	my ($this) = @_;
	return 1;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlRequest';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name};
}

# setters and getters
sub getRequest {
	my ($this) = @_;
	return $this->{_request};
}

# action
=pod
sub parseSqlRequest {
	my ($this) = @_;
	my $sqlParser = SQL::Parser->new();

	print "=START======================================================\n";
	print $this->{request};
	$sqlParser->parse($this->{_request});
	
	$sqlParser->{RaiseError}=0;
    $sqlParser->{PrintError}=1;
	my $stmt = SQL::Statement->new($this->{_request},$sqlParser);
    printf "Command             %s\n",$stmt->command;
    printf "Num of Placeholders %s\n",scalar $stmt->params;
    printf "Columns             %s\n",join( ',', map {$_->name} $stmt->column_defs() );
    printf "Tables              %s\n",join( ',', map {$_->name} $stmt->tables() );
    printf "Where operator      %s\n",join( ',', $stmt->where->op() );
    printf "Limit               %s\n",$stmt->limit();
    printf "Offset              %s\n",$stmt->offset();
	print Dumper $sqlParser->structure;
	print "=END=======================================================\n";
}
=cut
1;