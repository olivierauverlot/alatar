package PgXMLExporter;

# Produce serialized version of the object representation (XML)

use strict;
use XML::Writer;
use IO::File;
use Configuration;

sub new {
	my ($class,$model) = @_;
	my $this = {
		model => $model
	};
	$this->{xmlOutput} = new IO::File(">" . Configuration->getOption('xmlFilePath'));
	$this->{xmlWriter} = new XML::Writer(OUTPUT => $this->{xmlOutput}, DATA_MODE => 1, DATA_INDENT=>2);
 	bless($this,$class);
 	$this->{xmlWriter}->doctype('database');
	$this->{xmlWriter}->startTag('database',
		'clientEncoding' => $this->{model}->getClientEncoding()
	);
	$this->_addExtensions();
	$this->_addFunctions();
	$this->_addTriggerDefinitions();
	$this->_addSequences();
	$this->{xmlWriter}->endTag();	# end of schema definition
	$this->{xmlWriter}->end();
 	return $this;            
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
 			'language' => $f->getLanguage(),
 			'returnType' => $f->getReturnType(),
 			'comments' => ($f->isCommented() ? 'true' : 'false')
 		);
 		@args = $f->getArgs();
 		if(@args) {
	 		$this->{xmlWriter}->startTag('arguments');
	 		foreach my $a (@args) {
	 			$this->{xmlWriter}->startTag('argument');
	 			$this->{xmlWriter}->startTag('name');
	 			$this->{xmlWriter}->characters($a->getName());
	 			$this->{xmlWriter}->endTag();
	 			$this->{xmlWriter}->startTag('type');
	 			$this->{xmlWriter}->characters($a->getType());
	 			$this->{xmlWriter}->endTag();
	 			$this->{xmlWriter}->endTag();
	 		}
	 		$this->{xmlWriter}->endTag();
 		}
 		if($f->getAllRequests()) {
 			@requests = $f->getSqlRequests();
 			if(@requests) {
		 		$this->{xmlWriter}->startTag('requests');
		 		foreach my $r (@requests) {
					$this->{xmlWriter}->startTag('request',
						'name' => $r->getName()
					);
					$this->{xmlWriter}->startTag('sql');
					$this->{xmlWriter}->cdata($r->getRequest());
		 			$this->{xmlWriter}->endTag();
		 			$this->{xmlWriter}->startTag('json');
		 			my $dest = Configuration->getOption('requestsPath') . Configuration->getOption('requests_folder') . '/' . $r->getName() . '.sql';
		 			my $jsonData = qx { ./bin/parse_file "$dest"};
					$this->{xmlWriter}->cdata($jsonData);
		 			$this->{xmlWriter}->endTag();
		 			$this->{xmlWriter}->endTag();
		 		}
		 		$this->{xmlWriter}->endTag();
 			}
 			@cursors = $f->getSqlCursorRequests();
 			
			if(@cursors) {
				$this->{xmlWriter}->startTag('cursors');
		 		foreach my $r (@cursors) {
					$this->{xmlWriter}->startTag('cursor',
						'name' => $r->getName()
					);
					@args = $r->getArgs();
					if(@args) {
						$this->{xmlWriter}->startTag('arguments');
						foreach $a (@args) {
							$this->{xmlWriter}->startTag('argument');
				 			$this->{xmlWriter}->startTag('name');
				 			$this->{xmlWriter}->characters($a->getName());
				 			$this->{xmlWriter}->endTag();
				 			$this->{xmlWriter}->startTag('type');
				 			$this->{xmlWriter}->characters($a->getType());
				 			$this->{xmlWriter}->endTag();
				 			$this->{xmlWriter}->endTag();
						}
						$this->{xmlWriter}->endTag();
					}
					$this->{xmlWriter}->startTag('code');
					$this->{xmlWriter}->cdata($r->getRequest());
		 			$this->{xmlWriter}->endTag();
		 			$this->{xmlWriter}->startTag('json');
		 			my $dest = Configuration->getOption('requestsPath') . Configuration->getOption('cursors_folder') . '/' . $r->getName() . '.sql';
		 			my $jsonData = qx { ./bin/parse_file "$dest"};
					$this->{xmlWriter}->cdata($jsonData);
		 			$this->{xmlWriter}->endTag();
		 			$this->{xmlWriter}->endTag();
		 		}
		 		$this->{xmlWriter}->endTag();
			}
		}
		@invokedMethods = $f->getInvokedFunctions();
		if(@invokedMethods) {
	 		$this->{xmlWriter}->startTag('invokedFunctions');
	 		foreach my $if (@invokedMethods) {
	 			$this->{xmlWriter}->startTag('invokedFunction',
	 				'argumentsNumber' => $if->getArgumentsNumber(),
	 				'stub' => ($if->isStub() ? 'true' : 'false')
	 			);
	 			$this->{xmlWriter}->characters($if->getName());
	 			$this->{xmlWriter}->endTag();
	 		}
	 		$this->{xmlWriter}->endTag();
		}
		@callers = $f->getCallers();
		if(@callers) {
			$this->{xmlWriter}->startTag('callers');
	 		foreach my $caller (@callers) {
	 			$this->{xmlWriter}->startTag('caller',
	 				'argumentsNumber' => $caller->getArgumentsNumber(),
	 				'stub' => ($caller->isStub() ? 'true' : 'false')
	 			);
	 			$this->{xmlWriter}->characters($caller->getName());
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
# Trigger definitions
# --------------------------------------------------
sub _addTriggerDefinitions {
	my ($this) = @_;

	$this->{xmlWriter}->startTag('triggers');
 	foreach my $t ($this->{model}->getSqlTriggers()) { 
 		$this->{xmlWriter}->startTag('trigger', 
 			'name' => $t->getName(),
 			'event' => $t->getEvent(),
 			'fire' => $t->getFire(),
 			'level' => $t->getLevel()
 		);
 		$this->{xmlWriter}->startTag('table');
	 	$this->{xmlWriter}->characters($t->getTable());
	 	$this->{xmlWriter}->endTag();
	 	$this->{xmlWriter}->startTag('invokedFunction',
	 		'argumentsNumber' => ($t->getInvokedFunction()->getArgumentsNumber()),
	 		'stub' => ($t->getInvokedFunction()->isStub() ? 'true' : 'false')
	 		);
	 	$this->{xmlWriter}->characters($t->getInvokedFunction()->getName());
	 	$this->{xmlWriter}->endTag();
 		$this->{xmlWriter}->endTag();
 	}
	$this->{xmlWriter}->endTag();	# end of trigger definition
}

# --------------------------------------------------
# Sequences
# --------------------------------------------------
sub _addSequences {
	my ($this) = @_;
	$this->{xmlWriter}->startTag('sequences');
 	foreach my $t ($this->{model}->getSequences()) {
 		$this->{xmlWriter}->startTag('sequence', 
 			'name' => $t->getName()
 		);
 		$this->{xmlWriter}->endTag();
 	}
 	$this->{xmlWriter}->endTag();	# end of sequences list
}

1;