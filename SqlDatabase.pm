package SqlDatabase;

use Data::Dumper;
use strict;
use PgExtension;
use PgFunctionExtractor;
use PgTriggerExtractor;
use SqlFunction;
use SqlResolver;
use SqlSequence;
use SqlTable;
use SqlTrigger; 

sub new {
	my ($class,$name,$schema) = @_;
	my $this = {
		name => $name,
		clientEncoding => undef,
		extensions => [ ],
		schema => $schema,
		objects => [ ],
		resolver => undef
	};
 	bless($this,$class); 
 	if(defined($schema)) {
	 	$this->{resolver} = SqlResolver->new($this);
	 	$this->_extractDatabaseSetup();
	 	$this->_extractTables();
	 	$this->_extractSequences();
	 	$this->_extractFunctions();
	 	$this->_extractTriggers();
	 	$this->{resolver}->resolveAllLinks();
 	}
 	return $this;            
}

# Setters and getters
# -------------------------------------------------------------
sub getName {
	my ($this) = @_;
	return $this->{name};
}

sub getSchema {
	my ($this) = @_;
	return $this->{schema};
}

sub getClientEncoding {
	my ($this) = @_;
	return $this->{clientEncoding};
}

sub getExtensions {
	my ($this) = @_;
	return @{$this->{extensions}};
}

sub addExtension {
	my ($this,$extension) = @_;
	push(@{$this->{extensions}},$extension);
	return $extension;
}

sub addObject {
	my ($this,$sqlObject) = @_;
	push(@{$this->{objects}},$sqlObject);
	return $sqlObject;
}

sub addObjects {
	my ($this,$sqlObjects) = @_;
	return $this->addObject($sqlObjects);
}

sub getObjectsWithName {
	my ($this,$name,@objects) = @_;
	return (grep { $_->getName() eq $name} @objects);
}

sub getObjects {
	my ($this) = @_;
	return @{$this->{objects}};
}

sub getSqlTables {
	my ($this) = @_;
	my @tables;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlTable()) {
	 		push(@tables,$obj);
	 	}
	}
	return @tables;
}

sub getSqlFunctions {
	my ($this) = @_;
	my @functions;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlFunction()) {
	 		push(@functions,$obj);
	 	}
	}
	return @functions;
}

sub getSqlTriggers {
	my ($this) = @_;
	my @triggers;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlTrigger()) {
	 		push(@triggers,$obj);
	 	}
	}
	return @triggers;
}

sub getAllRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getAllRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSqlRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getSqlRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSqlCursorRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getSqlCursorRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSequences {
	my ($this) = @_;
	my @sequences;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlSequence()) {
	 		push(@sequences,$obj);
	 	}
	}
	return @sequences;	
}

# Actions
# -------------------------------------------------------------
sub _extractDatabaseSetup {
	my ($this) = @_;
	# client encoding
	my @items = $this->{schema} =~ /SET\sclient_encoding\s=\s\'(.*?)\'\;/g;
	$this->{clientEncoding} = $items[0];
	# List of extensions
	@items = $this->{schema} =~ /CREATE\sEXTENSION\sIF\sNOT\sEXISTS\s(.*?)\sWITH\sSCHEMA\s(.*?)\;/gi;
	for(my $i;$i < @items;$i=$i+2) {
		# get the extension comment
		my @comment = $this->{schema} =~ /COMMENT\sON\sEXTENSION\s$items[$i]\sIS\s\'(.*?)\'\;/gi;
		if(!@comment) {
			$comment[0] = '';	
		}
		$this->addExtension(PgExtension->new($items[$i],$items[$i+1],$comment[$0]));
	}
}

sub _extractTables {
	my ($this) = @_;
	my @tables = $this->{schema} =~ /CREATE\sTABLE\s(.*?);/gi;
	foreach my $table (@tables) {
		my $extractor = PgTableExtractor->new($this,$table);
		$this->addObjects($extractor->getEntity());
	}
}

sub _extractSequences {
	my ($this) = @_;
	my @sequences = $this->{schema} =~ /CREATE\sSEQUENCE\s(.*?)\s/gi;
	foreach my $sequence (@sequences) {
		$this->addObject(SqlSequence->new($this,$sequence));
	}
}

sub _extractFunctions {
	my ($this) = @_;
	my @functions = $this->{schema} =~ /CREATE FUNCTION\s(.*?)END;\$\$;/gi;
	foreach my $fcode (@functions) {
		my $extractor = PgFunctionExtractor->new($this,$fcode);
		my $function = $extractor->getEntity();
		$this->addObject($function);
		
		my $signature =$function->getSignature();
		$signature =~ s/\(/\\\(/;
		$signature =~ s/\)/\\\)/;
		if($this->{schema} =~ /COMMENT\sON\sFUNCTION\s$signature\sIS\s\'(.*?)\';/g) {
			$function->hasComments();
		}
	}
}

sub _extractTriggers {
	my ($this) = @_;
	my @triggers = $this->{schema} =~ /CREATE TRIGGER\s(.*?);/gi;
	foreach my $trigger (@triggers) {
		my $extractor = PgTriggerExtractor->new($this,$trigger);
		$this->addObject($extractor->getEntity());
	}
}



1;