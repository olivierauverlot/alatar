package SqlDatabase;

use Data::Dumper;
use strict;
use String::Util qw(trim);
use PgExtension;
use PgViewExtractor;
use PgFunctionExtractor;
use PgTriggerExtractor;
use SqlFunction;
use PgResolver;
use SqlSequence;
use SqlEnumerationType;
use SqlCompositeType;
use SqlTable;
use SqlTrigger;
use SqlColumnReference;
use SqlPrimaryKeyConstraint;
use SqlForeignKeyConstraint;
use SqlUniqueConstraint;

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
 		$this->{schema} = $this->_clean($schema);
	 	$this->{resolver} = PgResolver->new($this);
	 	$this->_extractDatabaseSetup();
	 	$this->_extractEnumerationTypes();
	 	$this->_extractCompositeTypes();
	 	$this->_extractTables();
	 	$this->_extractViews();
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

sub getObjectsWithName {
	my ($this,$name,@objects) = @_;
	return (grep { $_->getName() eq $name} @objects);
}

sub getFirstObjectWithName {
	my ($this,$name,@objects) = @_;
	my @arrayOfObjects;
	@arrayOfObjects = (grep { $_->getName() eq $name} @objects);
	if(scalar(@arrayOfObjects) > 0) {
		return $arrayOfObjects[0];
	} else {
		return undef;
	}
}

sub getObjects {
	my ($this) = @_;
	return @{$this->{objects}};
}

sub getSqlDataTypes {
	my ($this) = @_;
	my @datatypes;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlDataType()) {
	 		push(@datatypes,$obj);
	 	}
	}
	return @datatypes;
}

sub getSqlTables {
	my ($this) = @_;
	my @tables;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlTable() && !$obj->isSqlView()) {
	 		push(@tables,$obj);
	 	}
	}
	return @tables;
}

sub getSqlViews {
	my ($this) = @_;
	my @views;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlView()) {
	 		push(@views,$obj);
	 	}
	}
	return @views;
}

sub getAllTables {
	my ($this) = @_;
	my @tables;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlTable()) {
	 		push(@tables,$obj);
	 	}
	}
	return @tables;
}

sub getInheritedTables {
	my ($this) = @_;
	return grep { $_->isChildren() } $this->getSqlTables();
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
sub _clean {
	my ($this,$data) = @_;
	# remove comments with --
	$data =~ s/--//g;
	# replace newlines and tabulations with a blank character
	$data =~ s/[\t\n\r]+/ /g;
	# remove comments with /* .. */
	$data =~ s/\/\*.*?\*\///g;
	return $data;
}

sub _extractDatabaseSetup {
	my ($this) = @_;
	# client encoding
	my @items = $this->{schema} =~ /SET\sclient_encoding\s=\s\'(.*?)\'\;/g;
	$this->{clientEncoding} = $items[0];
	# List of extensions
	@items = $this->{schema} =~ /CREATE\sEXTENSION\sIF\sNOT\sEXISTS\s(.*?)\sWITH\sSCHEMA\s(.*?)\;/gi;
	for(my $i=0;$i < @items;$i=$i+2) {
		# get the extension comment
		my @comment = $this->{schema} =~ /COMMENT\sON\sEXTENSION\s$items[$i]\sIS\s\'(.*?)\'\;/gi;
		if(!@comment) {
			$comment[0] = '';	
		}
		$this->addExtension(PgExtension->new($items[$i],$items[$i+1],$comment[$0]));
	}
}

sub _extractEnumerationTypes {
	my ($this) = @_;
}

sub _extractCompositeTypes {
	my ($this) = @_;
}
	 	
sub _extractTables {
	my ($this) = @_;
	my ($table,$tableName);
	my @tables = $this->{schema} =~ /CREATE\sTABLE\s(.*?);/gi;
	foreach my $table (@tables) {
		my $extractor = PgTableExtractor->new($this,$table);
		$table = $extractor->getEntity();
		$this->addObject($table);
		$tableName = $table->getName();
		
		# extract PK constraint if exists
		my @pkConstraint = $this->{schema} =~ /ALTER\sTABLE\sONLY\s\"?$tableName\"?\s+ADD\sCONSTRAINT\s([^\s]*?)\sPRIMARY\sKEY\s\((.*?)\);/gi;
		if(scalar(@pkConstraint) == 2) {
			my $constraint = SqlPrimaryKeyConstraint->new($table,$pkConstraint[0]);
			# list of columns
			foreach my $columnName (split(/,/ , $pkConstraint[1])) {
				$constraint->addColumn(SqlColumnReference->new($this,undef,$table,trim($columnName)));
			}
			# we have only the column(s) name(s). It will be resolved later by the PgResolver
			$table->addConstraint($constraint);
		}
		
		# extract FK constraint if exists
		# nom_contrainte,colonneFK, table_pointée,colonne pointée
		my @fkConstraint = $this->{schema} =~ /ALTER\sTABLE\sONLY\s\"?$tableName\"?\s+ADD\sCONSTRAINT\s([^\s]*?)\sFOREIGN\sKEY\s\((.*?)\)\sREFERENCES\s\"?(.*?)\"?\((.*?)\).*?;/;

		if(scalar(@fkConstraint) == 4) {
			# Define the source column 
			my $constraint = SqlForeignKeyConstraint->new($table,$fkConstraint[0]);
			$constraint->addColumn(SqlColumnReference->new($this,undef,$table,trim($fkConstraint[1])));
			
			# define the target column
			$constraint->setReference(SqlColumnReference->new($this,undef,trim($fkConstraint[2]),trim($fkConstraint[3])));
			
			# the constraint is added to the table definition
			$table->addConstraint($constraint);
		}
		
		# extract UNIQUE constraint if exists
		# ALTER TABLE ONLY t ADD CONSTRAINT t_unique UNIQUE (name, category);
		# nom_contrainte,liste_colonnes
		# my @uniqueConstraint = $this->{schema} =~ /ALTER\sTABLE\sONLY\s$tableName\s+ADD\sCONSTRAINT\s([^\s]*?)\sUNIQUE\s\((.*?)\);/g;
		while ($this->{schema} =~ /ALTER\sTABLE\sONLY\s\"?$tableName\"?\s+ADD\sCONSTRAINT\s([^\s]*?)\sUNIQUE\s\((.*?)\);/g) {
        	my $constraint = SqlUniqueConstraint->new($table,$1);
			# list of columns
			foreach my $columnName (split(/,/ , $2)) {
				$constraint->addColumn(SqlColumnReference->new($this,undef,$table,trim($columnName)));
			}
			# we have only the column(s) name(s). It will be resolved later by the PgResolver
			$table->addConstraint($constraint);
    	}
	}
}

sub _extractViews {
	my ($this) = @_;
	my @views = $this->{schema} =~ /CREATE\sVIEW\s(.*?);/gi;
	foreach my $view (@views) {
		my $extractor = PgViewExtractor->new($this,$view);
		$this->addObject($extractor->getEntity());
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
	my $code;
	my @functions = $this->{schema} =~ /CREATE\sFUNCTION\s(.*?\sAS\s*(?<separator>\$.*?\$)\s*.*?)(?P=separator);/gi;
	for(my $i=0;$i<scalar(@functions);$i+=2) {
		$code = $functions[$i];
		my $extractor = PgFunctionExtractor->new($this,$code);
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