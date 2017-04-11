package Alatar::PostgreSQL::PgXMLExporter;

# Produce serialized version of the object representation (XML)

use strict;
use XML::Writer;
use IO::File;
use Alatar::Configuration;

sub new {
	my ($class,$model) = @_;
	my $this = {
		model => $model
	};
	$this->{parseFilePath} = '"' . Alatar::Configuration->getOption('appFolder') . '/postgresql/parse_file' . '"';
	$this->{xmlOutput} = new IO::File(">" . Alatar::Configuration->getOption('xmlFilePath'));
	$this->{xmlWriter} = new XML::Writer(OUTPUT => $this->{xmlOutput}, DATA_MODE => 1, DATA_INDENT=>2);
 	bless($this,$class);
 	$this->{xmlWriter}->doctype('database');
	$this->{xmlWriter}->startTag('database',
		'clientEncoding' => $this->{model}->getClientEncoding()
	);
	# print "--- EXPORTER ---\n";
	$this->_addExtensions();
	$this->_addFunctions();
	$this->_addTables();
	$this->_addViews();
	$this->_addTriggerDefinitions();
	$this->_addSequences();
	$this->_addReferences();
	$this->{xmlWriter}->endTag();	# end of schema definition
	$this->{xmlWriter}->end();
 	return $this;            
}

sub _exportSqlFileToJSOn {
	my ($this,$sqlPath) = @_;
	
	if(Alatar::Configuration->getOption('requestsPath')) {
		$this->{xmlWriter}->startTag('json');
		my $jsonData = qx { $this->{parseFilePath} "$sqlPath"};
		$this->{xmlWriter}->cdata($jsonData);
		$this->{xmlWriter}->endTag();
	}
}

# --------------------------------------------------
# Extensions
# --------------------------------------------------
sub _addExtensions {
	my ($this) = @_;
	
	$this->{xmlWriter}->startTag('extensions');
 	foreach my $e ($this->{model}->getExtensions()) {
	 	$this->{xmlWriter}->startTag('extension', 
	 			'name' => $e->getName(),
	 			'schema' => $e->getSchema()
	 		);
	 	$this->{xmlWriter}->startTag('comment');
		$this->{xmlWriter}->cdata($e->getComment());
		$this->{xmlWriter}->endTag();
	 	$this->{xmlWriter}->endTag();
 	}
 	$this->{xmlWriter}->endTag();	# end of extensions list
}

# --------------------------------------------------
# Functions
# --------------------------------------------------	
sub _addFunctions {
	my ($this) = @_;
	my (@args,@requests,@cursors,@invokedMethods,@callers,@row);
	
 	$this->{xmlWriter}->startTag('functions');
 	foreach my $f ($this->{model}->getSqlFunctions()) { 
 		$this->{xmlWriter}->startTag('function', 
 			'name' => $f->getName(),
 			'id' => $f->getId(),
 			'language' => $f->getLanguage(),
 			'returnType' => $f->getReturnTypeName(),
 			'comments' => ($f->isCommented() ? 'true' : 'false')
 		);
 		$this->{xmlWriter}->startTag('arguments');
 		@args = $f->getArgs();
 		if(@args) {
	 		foreach my $a (@args) {
	 			$this->{xmlWriter}->startTag('argument',
	 				'id' => $a->getId(),
	 				'name' => $a->getName(),
	 				'type' => $a->getDataTypeReference()->getTarget()->getName()
	 			);
	 			$this->{xmlWriter}->endTag();
	 		}
 		} 
 		$this->{xmlWriter}->endTag(); # end of tag <arguments>
 		
 		$this->{xmlWriter}->startTag('requests');
 		@requests = $f->getSqlRequests();
 		if(@requests) {
		 	foreach my $r (@requests) {
				$this->{xmlWriter}->startTag('request',
					'name' => $r->getName(),
					'id' => $r->getId()
				);
				$this->{xmlWriter}->startTag('sql');
				$this->{xmlWriter}->cdata($r->getRequest());
		 		$this->{xmlWriter}->endTag();
		 			
		 		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('requests_folder') . '/' . $r->getName() . '.sql');

		 		$this->{xmlWriter}->endTag();
		 	}
 		}
 		$this->{xmlWriter}->endTag(); # end of requests
 			
 		@cursors = $f->getSqlCursorRequests();
 		$this->{xmlWriter}->startTag('cursors');
		if(@cursors) {
		 	foreach my $r (@cursors) {
				$this->{xmlWriter}->startTag('cursor',
					'name' => $r->getName(),
					'id' => $r->getId()
				);
				@args = $r->getArguments();
				if(@args) {
					$this->{xmlWriter}->startTag('arguments');
					foreach $a (@args) {
						$this->{xmlWriter}->startTag('argument',
	 						'id' => $a->getId(),
	 						'name' => $a->getName(),
	 						'type' => $a->getDataTypeReference()->getTarget()->getName()
	 					);
						$this->{xmlWriter}->endTag();
					}
					$this->{xmlWriter}->endTag();
				}
				$this->{xmlWriter}->startTag('sql');
				$this->{xmlWriter}->cdata($r->getRequest());
		 		$this->{xmlWriter}->endTag();
		 			
		 		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('cursors_folder') . '/' . $r->getOwnerName() . '_' . $r->getName() . '.sql');
		 				
		 		$this->{xmlWriter}->endTag();
		 	}
		}
		$this->{xmlWriter}->endTag(); # end of tag cursors
			
		@invokedMethods = $f->getInvokedFunctions();
		if(@invokedMethods) {
	 		$this->{xmlWriter}->startTag('invokedFunctions');
	 		foreach my $if (@invokedMethods) {
	 			if(!$if->isStub()) { # Temporary solution. We must produce stub functions in the model to avoid broken references
		 			$this->{xmlWriter}->startTag('invokedFunction',
		 				'argumentsNumber' => $if->getArgumentsNumber(),
		 				'stub' => ($if->isStub() ? 'true' : 'false')
		 			);
	 			} else {
	 				$this->{xmlWriter}->startTag('invokedFunction',
		 				'argumentsNumber' => $if->getArgumentsNumber(),
		 				'stub' => 'true'
		 			);
	 			}
	 			$this->{xmlWriter}->characters($if->getName());
	 			$this->{xmlWriter}->endTag();
	 		}
	 		$this->{xmlWriter}->endTag();
		}

 		if($f->isTriggerFunction()) {
 			@row = $f->getNewColumns();
 			if(@row) {
 				$this->{xmlWriter}->startTag('newRow');
 				foreach my $c (@row) {
 					$this->{xmlWriter}->startTag('new');
 					$this->{xmlWriter}->characters($c);
 					$this->{xmlWriter}->endTag();
 				}
 				$this->{xmlWriter}->endTag();
 			}
 			@row = $f->getOldColumns();
 			if(@row) {
 				$this->{xmlWriter}->startTag('oldRow');
 				foreach my $c (@row) {
 					$this->{xmlWriter}->startTag('old');
 					$this->{xmlWriter}->characters($c);
 					$this->{xmlWriter}->endTag();
 				}
 				$this->{xmlWriter}->endTag();
 			}
 		}
 		$this->{xmlWriter}->endTag();
 	}
 	$this->{xmlWriter}->endTag();	# end of function definition
}

# --------------------------------------------------
# Export the rules in tables and views
# --------------------------------------------------
sub _exportRulesOf {
	my ($this,$table) = @_;
	my @rules;
	foreach my $rule ($this->{model}->getSqlRules()) {
		if($rule->getTable()->getName() eq $table->getName()) {
			push(@rules,$rule);
		}
	}
	if(@rules) {
		$this->{xmlWriter}->startTag('rules');
		foreach my $r (@rules) {
			$this->{xmlWriter}->startTag('rule',
				'name' => $r->getName(),
				'id' => $r->getId(),
				'event' => $r->getEvent(),
				'mode' => ($r->doInstead() ? 'INSTEAD' : 'ALSO')
			);
			$this->{xmlWriter}->startTag('request',
				'name' => ($r->getSqlRequest()->getName()),
				'id' => $r->getId()
			);
			$this->{xmlWriter}->startTag('sql');
			$this->{xmlWriter}->cdata($r->getSqlRequest()->getRequest());
			$this->{xmlWriter}->endTag(); # end of sql definition
			
			$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('rules_folder') . '/' . $r->getName() . '_' . $r->getId() . '.sql');
			
			$this->{xmlWriter}->endTag(); # end of request definition
			$this->{xmlWriter}->endTag(); # end of rule tag
		}
		$this->{xmlWriter}->endTag();	# end of rules definition
	}
}

# --------------------------------------------------
# Table definitions
# --------------------------------------------------
sub _addTables {
	my ($this) = @_;
	$this->{xmlWriter}->startTag('tables');
	foreach my $t ($this->{model}->getSqlTables()) {
		$this->{xmlWriter}->startTag('table',
			'name' => $t->getName(),
			'id' => $t->getId()
		);
		$this->{xmlWriter}->startTag('columns');
		foreach my $c ($t->getColumns()) {
			$this->{xmlWriter}->startTag('column',
				'name' => $c->getName(),
				'id' => $c->getId(),
				'type' => $c->getDataType()->getName(),
				'notNull' => ($c->isNotNull() ? 'true' : 'false'),
				'primaryKey' => ($c->isPk() ? 'true' : 'false'),
				'foreignKey' => ($c->isFk() ? 'true' : 'false'),
				'inherited' => ($c->isInherited() ? 'true' : 'false')
			);
			$this->{xmlWriter}->endTag(); # end of column tag
		}
		$this->{xmlWriter}->endTag(); # end of columns tag

		$this->{xmlWriter}->startTag('sql');
		$this->{xmlWriter}->cdata($t->getSqlRequest()->getRequest());
		$this->{xmlWriter}->endTag(); # end of sql definition
		
		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('tables_folder') . '/' . $t->getName() . '.sql');
		
		# the rules are exported
		$this->_exportRulesOf($t);
	
		$this->{xmlWriter}->endTag(); # end of table tag
	}
	$this->{xmlWriter}->endTag();	# end of table definition
}

# --------------------------------------------------
# Views definitions
# --------------------------------------------------
sub _addViews {
	my ($this) = @_;
	$this->{xmlWriter}->startTag('views');
	foreach my $v ($this->{model}->getSqlViews()) {
		$this->{xmlWriter}->startTag('view',
			'name' => $v->getName(),
			'id' => $v->getId()
		);
		$this->{xmlWriter}->startTag('request',
			'name' => ($v->getSqlRequest()->getName()),
			'id' => $v->getId()
		);
		$this->{xmlWriter}->startTag('sql');
		$this->{xmlWriter}->cdata($v->getSqlRequest()->getRequest());
		$this->{xmlWriter}->endTag(); # end of sql definition
		
		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('views_folder') . '/' . $v->getName() . '.sql');
		
		$this->{xmlWriter}->endTag(); # end of request definition
		
		# the rules are exported
		$this->_exportRulesOf($v);
		
		$this->{xmlWriter}->endTag(); # end of view definition
	}
	$this->{xmlWriter}->endTag(); # end of views definition
}

# --------------------------------------------------
# Trigger definitions
# --------------------------------------------------
sub _addTriggerDefinitions {
	my ($this) = @_;

	$this->{xmlWriter}->startTag('triggers');
 	foreach my $t ($this->{model}->getSqlTriggers()) { 
 		$this->{xmlWriter}->startTag('trigger', 
 			'name' => $t->getName(),
			'id' => $t->getId(),
 			'fire' => $t->getFire(),
 			'level' => $t->getLevel()
 		);
 		$this->{xmlWriter}->startTag('table',
 			'name' => $t->getTableReference()->getTarget()->getName(),
 			'id' => $t->getTableReference()->getTarget()->getId()
 		);
	 	$this->{xmlWriter}->endTag();
	 	$this->{xmlWriter}->startTag('events');
	 	foreach my $event ($t->getEvents()) {
	 		$this->{xmlWriter}->startTag('event');
	 		$this->{xmlWriter}->characters($event);
	 		$this->{xmlWriter}->endTag();
	 	}
	 	$this->{xmlWriter}->endTag();	 	
	 	$this->{xmlWriter}->startTag('invokedFunction',
	 		'id' => ($t->getInvokedFunctionReference()->getTarget()->getId()),
	 		'argumentsNumber' => ($t->getInvokedFunctionReference()->getTarget()->getArgumentsNumber()),
	 		'stub' => ($t->getInvokedFunctionReference()->isStub() ? 'true' : 'false')
	 	);
	 	$this->{xmlWriter}->characters($t->getInvokedFunctionReference()->getTarget()->getName());
	 	$this->{xmlWriter}->endTag();

 		$this->{xmlWriter}->startTag('sql');
		$this->{xmlWriter}->cdata($t->getSqlRequest()->getRequest());
		$this->{xmlWriter}->endTag(); # end of sql definition
		
		$this->_exportSqlFileToJSOn(Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('triggers_folder') . '/' . $t->getName() . '.sql');

 		$this->{xmlWriter}->endTag(); # end of trigger definition		
 	}
	$this->{xmlWriter}->endTag();	# end of triggers definition
}

# --------------------------------------------------
# Sequences
# --------------------------------------------------
sub _addSequences {
	my ($this) = @_;
	$this->{xmlWriter}->startTag('sequences');
 	foreach my $s ($this->{model}->getSequences()) {
 		$this->{xmlWriter}->startTag('sequence', 
 			'name' => $s->getName(),
 			'id' => $s->getId()
 		);
 		$this->{xmlWriter}->endTag();
 	}
 	$this->{xmlWriter}->endTag();	# end of sequences list
}

# --------------------------------------------------
# References
# --------------------------------------------------

sub _addReference {
	my ($this,$from,$to) = @_;
	$this->{xmlWriter}->startTag('reference',
		'source' => $from->getObjectType(),
		'target' => $to->getObjectType(),
		'from' => $from->getId(),
		'to' => $to->getId()
		);
	$this->{xmlWriter}->endTag(); # end of the reference
}

sub _addReferences {
	my ($this) = @_;
	
	$this->{xmlWriter}->startTag('references');
	$this->{xmlWriter}->startTag('foreignKeys');
	foreach my $t ($this->{model}->getSqlTables()) {
		my @fks = grep {
			$_->isSqlForeignKeyConstraint()
		} $t->getConstraints();
		foreach my $fk (@fks) {
			$this->_addReference($fk->getOneColumn(),$fk->getReference());
		}
	}
	$this->{xmlWriter}->endTag();	# end of foreignKeys
	
	$this->{xmlWriter}->startTag('inheritances');
	foreach my $t ($this->{model}->getSqlTables()) {
		if($t->isChild()) {
			foreach my $parentTable ($t->getParentTables()) {
				$this->_addReference($t,$parentTable->getTarget());
			}
		}
	}
	$this->{xmlWriter}->endTag();	# end of inheritances

	$this->{xmlWriter}->startTag('invokedFunctions');
	foreach my $f ($this->{model}->getSqlFunctions()) { 
		my @invokedMethods = $f->getInvokedFunctions();
		foreach my $if (@invokedMethods) {
			if(!$if->isStub()) {
				$this->_addReference($f,$if->getTarget());
		 	}
		}	
	}
	$this->{xmlWriter}->endTag();	# end of invoked functions

	$this->{xmlWriter}->startTag('triggers');
	foreach my $t ($this->{model}->getSqlTriggers()) {
		$this->{xmlWriter}->startTag('trigger');
			$this->_addReference($t,$t->getTableReference()->getTarget());
			$this->_addReference($t,$t->getInvokedFunctionReference()->getTarget());
		$this->{xmlWriter}->endTag();	# end of trigger
	}
	$this->{xmlWriter}->endTag();	# end of triggers
	
	$this->{xmlWriter}->endTag();	# end of references
}

1;