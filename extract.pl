#!/usr/bin/env perl

# perl -MCPAN -e 'install XML::Writer'

# http://search.cpan.org/~abigail/Regexp-Common-2016020301/lib/Regexp/Common.pm

use strict;
use warnings;
use Getopt::Long;
use File::Path;
use Data::Dumper;
use XML::Writer;
use IO::File;
use SqlDatabase;
use SqlFunction;

use utf8;

my $DEST_PATH = '/tmp/sql';
my $REQUESTS_FOLDER = '/requests';
my $CURSORS_FOLDER = '/cursors';

my $CATALOG_NAME = 'catalog.xml';

my $schemaPath = '';
my $destPath = '';

my (@requestFiles,@cursorFiles);

my (@userFunctionsList,%invokedFunctions);

my $model;

sub loadSQLSchema {
	my ($filePath) = @_;
	my $data;
	
	open(DATA,$schemaPath) || die "$!";
	while( defined( my $l = <DATA> ) ) {
   		$data = $data . $l;
	}
	close(DATA);
	
	return $data;
}

sub cleanSchema {
	my ($data) = @_;
	# remove comments with --
	$data =~ s/--//g;
	# replace newlines and tabulations with a blank character
	$data =~ s/[\t\n\r]+/ /g;
	# remove comments with /* .. */
	$data =~ s/\/\*.*?\*\///g;
	return $data;
}

sub saveRequest {
	my ($destFile,$request) = @_;
	open(FD,'>',$destFile) or die("open: $!");
	print(FD $request);
	close(FD);
}

# protege les parentheses et les virgules
# pour obtenir un chemin d'acces utilisable
sub protectPath {
	my ($path) = @_;
	$path =~ s/\(/\\(/;
	$path =~ s/\)/\\)/;
	$path =~ s/,/\\,/;
	
	return $path;
}

# save request on disk
sub saveRequests {
	my $dest;
	foreach my $r ($model->getSqlRequests()) {
		$dest = $DEST_PATH . $REQUESTS_FOLDER . '/' . $r->getName() . '.sql';
		push(@requestFiles,$r->getName());
		saveRequest($dest,$r->getRequest());
	}
	foreach my $r ($model->getSqlCursorRequests()) {
		$dest = $DEST_PATH . $CURSORS_FOLDER . '/' . $r->getName() . '.sql';
		push(@cursorFiles,$r->getName());
		saveRequest($dest,$r->getRequest());
	}
}

sub formatWithCRLF {
	my (@data) = @_;
	my $result = '';
	foreach my $item (@data) {
		$result = $result . $item . "\n\n";
	}
	return $result;
}

# add an element in the compact schema file
sub addToCompactSchema {
	my ($fd,@data) = @_;
	foreach my $item (@data) {
		print($fd ($item . "\n\n"));
	}
}

# Produce a compacted schema
sub createCompactSchema {
	my ($filename,$schema) = @_;
	my $fd;
	
	my @items;
	$filename =~ s/\./_compact\./g;
	my $dest = $DEST_PATH . '/' . $filename;
	
	open($fd,'>',$dest) || die "$!";
	
	addToCompactSchema($fd,$schema =~ /(CREATE\s+TABLE\s.*?\);)/gs);
	addToCompactSchema($fd,$schema =~ /(CREATE\s+VIEW.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(CREATE FUNCTION\s(.*?)END;\$\$;)/gs);
	addToCompactSchema($fd,$schema =~ /(CREATE\s+TRIGGER\s.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(ALTER\sTABLE[^;]*FOREIGN\sKEY.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(ALTER\sTABLE[^;]*PRIMARY\sKEY.*?;)/gs);
	close($fd);
}

# Gentlemen, start your engines!
sub run {
	my ($schema,$xmlFileName,@args,@requests,@cursors,@invokedMethods,@callers,@row);
	my ($xmlOutput,$xmlWriter);
	my @subFolders = ($REQUESTS_FOLDER , $CURSORS_FOLDER);
	
	$schema = loadSQLSchema();
	$model = SqlDatabase->new($schemaPath,cleanSchema($schema));

	rmtree($destPath);
	mkpath($destPath);
	foreach my $subFolder (@subFolders) {
		mkpath($destPath . $subFolder);
	}
	# Create a compact version of the schema
	createCompactSchema($schemaPath,$schema);

	# Save request in folders
	saveRequests();
	
	# Produce serialized version of the object representation (XML)
	$xmlFileName = $DEST_PATH . '/' . $model->getName();
	$xmlFileName =~ s/\.\w+/.xml/g;
	$xmlOutput = new IO::File(">$xmlFileName");
	$xmlWriter = new XML::Writer(OUTPUT => $xmlOutput, DATA_MODE => 1, DATA_INDENT=>2);
	$xmlWriter->xmlDecl('UTF-8');
	$xmlWriter->doctype('schema');
	$xmlWriter->startTag('schema');
 	$xmlWriter->startTag('functions');
 	foreach my $f ($model->getSqlFunctions()) { 
 		$xmlWriter->startTag('function', 
 			'name' => $f->getName(),
 			'language' => $f->getLanguage(),
 			'returnType' => $f->getReturnType()
 		);
 		@args = $f->getArgs();
 		if(@args) {
	 		$xmlWriter->startTag('arguments');
	 		foreach my $a (@args) {
	 			$xmlWriter->startTag('argument');
	 			$xmlWriter->startTag('name');
	 			$xmlWriter->characters($a->getName());
	 			$xmlWriter->endTag();
	 			$xmlWriter->startTag('type');
	 			$xmlWriter->characters($a->getType());
	 			$xmlWriter->endTag();
	 			$xmlWriter->endTag();
	 		}
	 		$xmlWriter->endTag();
 		}
 		if($f->getAllRequests()) {
 			@requests = $f->getSqlRequests();
 			if(@requests) {
		 		$xmlWriter->startTag('requests');
		 		foreach my $r (@requests) {
					$xmlWriter->startTag('request',
						'name' => $r->getName()
					);
					$xmlWriter->startTag('sql');
					$xmlWriter->cdata($r->getRequest());
		 			$xmlWriter->endTag();
		 			$xmlWriter->startTag('json');
		 			my $dest = $destPath . $REQUESTS_FOLDER . '/' . $r->getName() . '.sql';
		 			my $jsonData = qx { ./bin/parse_file "$dest"};
					$xmlWriter->cdata($jsonData);
		 			$xmlWriter->endTag();
		 			$xmlWriter->endTag();
		 		}
		 		$xmlWriter->endTag();
 			}
 			@cursors = $f->getSqlCursorRequests();
 			
			if(@cursors) {
				$xmlWriter->startTag('cursors');
		 		foreach my $r (@cursors) {
					$xmlWriter->startTag('cursor',
						'name' => $r->getName()
					);
					@args = $r->getArgs();
					if(@args) {
						$xmlWriter->startTag('arguments');
						foreach $a (@args) {
							$xmlWriter->startTag('argument');
				 			$xmlWriter->startTag('name');
				 			$xmlWriter->characters($a->getName());
				 			$xmlWriter->endTag();
				 			$xmlWriter->startTag('type');
				 			$xmlWriter->characters($a->getType());
				 			$xmlWriter->endTag();
				 			$xmlWriter->endTag();
						}
						$xmlWriter->endTag();
					}
					$xmlWriter->startTag('code');
					$xmlWriter->cdata($r->getRequest());
		 			$xmlWriter->endTag();
		 			$xmlWriter->startTag('json');
		 			my $dest = $destPath . $CURSORS_FOLDER . '/' . $r->getName() . '.sql';
		 			my $jsonData = qx { ./bin/parse_file "$dest"};
					$xmlWriter->cdata($jsonData);
		 			$xmlWriter->endTag();
		 			$xmlWriter->endTag();
		 		}
		 		$xmlWriter->endTag();
			}
		}
		@invokedMethods = $f->getInvokedFunctions();
		if(@invokedMethods) {
	 		$xmlWriter->startTag('invokedFunctions');
	 		foreach my $if (@invokedMethods) {
	 			$xmlWriter->startTag('invokedFunction',
	 				'argumentsNumber' => $if->getArgumentsNumber(),
	 				'stub' => ($if->isStub() ? 'true' : 'false')
	 			);
	 			$xmlWriter->characters($if->getName());
	 			$xmlWriter->endTag();
	 		}
	 		$xmlWriter->endTag();
		}
		@callers = $f->getCallers();
		if(@callers) {
			$xmlWriter->startTag('callers');
	 		foreach my $caller (@callers) {
	 			$xmlWriter->startTag('caller',
	 				'argumentsNumber' => $caller->getArgumentsNumber(),
	 				'stub' => ($caller->isStub() ? 'true' : 'false')
	 			);
	 			$xmlWriter->characters($caller->getName());
	 			$xmlWriter->endTag();
	 		}
	 		$xmlWriter->endTag();
		}

 		if($f->isTriggerFunction()) {
 			@row = $f->getNewColumns();
 			if(@row) {
 				$xmlWriter->startTag('newRow');
 				foreach my $c (@row) {
 					$xmlWriter->startTag('new');
 					$xmlWriter->characters($c);
 					$xmlWriter->endTag();
 				}
 				$xmlWriter->endTag();
 			}
 			@row = $f->getOldColumns();
 			if(@row) {
 				$xmlWriter->startTag('oldRow');
 				foreach my $c (@row) {
 					$xmlWriter->startTag('old');
 					$xmlWriter->characters($c);
 					$xmlWriter->endTag();
 				}
 				$xmlWriter->endTag();
 			}
 		}
 		$xmlWriter->endTag();
 	}
 	$xmlWriter->endTag();	# end of function definition
	
	# --------------------------------------------------
	# Trigger definitions
	# --------------------------------------------------
	$xmlWriter->startTag('triggers');
 	foreach my $t ($model->getSqlTriggers()) { 
 		$xmlWriter->startTag('trigger', 
 			'name' => $t->getName(),
 			'event' => $t->getEvent(),
 			'fire' => $t->getFire(),
 			'level' => $t->getLevel()
 		);
 		$xmlWriter->startTag('table');
	 	$xmlWriter->characters($t->getTable());
	 	$xmlWriter->endTag();
	 	$xmlWriter->startTag('invokedFunction',
	 		'argumentsNumber' => ($t->getInvokedFunction()->getArgumentsNumber()),
	 		'stub' => ($t->getInvokedFunction()->isStub() ? 'true' : 'false')
	 		);
	 	$xmlWriter->characters($t->getInvokedFunction()->getName());
	 	$xmlWriter->endTag();
 		$xmlWriter->endTag();
 	}
	$xmlWriter->endTag();	# end of trigger definition
	
	
	
	
	$xmlWriter->endTag();	# end of schema definition
	$xmlWriter->end();
}


# Command line parameters
sub setSchemaPath { $schemaPath = $_[1]; }

sub setDestPath { $destPath = $_[1]; }

GetOptions ("-/",               #compatible with the dos style
	"f=s" => \&setSchemaPath,
	"d=s" => \&setDestPath,
) or die("Error in command line arguments\n");

if($destPath eq '') {
	$destPath = $DEST_PATH;
}

run();
print Dumper($model);
