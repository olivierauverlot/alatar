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
use File::Basename;
use Configuration;
use SqlDatabase;
use SqlFunction;

use utf8;

my $VERSION = '0.1';
my $REQUESTS_FOLDER = '/requests';
my $CURSORS_FOLDER = '/cursors';

my (@requestFiles,@cursorFiles);

my (@userFunctionsList,%invokedFunctions);

my ($model,$conf);

sub version {
	print "Alatar version $VERSION\n\n";
	exit 1;
}

sub loadSQLSchema {
	my ($filePath) = @_;
	my $data;
	
	open(DATA,Configuration->getOption('schemaPath')) || die "You must specify a SQL schema";
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
	open(FD,'>',$destFile) or die("The SQL request can't be exported");
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
		$dest = Configuration->getOption('requestsPath') . $REQUESTS_FOLDER . '/' . $r->getName() . '.sql';
		push(@requestFiles,$r->getName());
		saveRequest($dest,$r->getRequest());
	}
	foreach my $r ($model->getSqlCursorRequests()) {
		$dest = Configuration->getOption('requestsPath') . $CURSORS_FOLDER . '/' . $r->getName() . '.sql';
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
	my ($destPath,$schema) = @_;
	my $fd;
	my @items;
	
	open($fd,'>',$destPath) || die "Cannot create the compact schema";
	addToCompactSchema($fd,$schema =~ /(CREATE\s+TABLE\s.*?\);)/gs);
	addToCompactSchema($fd,$schema =~ /(CREATE\s+VIEW.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(CREATE FUNCTION\s(.*?)END;\$\$;)/gs);
	addToCompactSchema($fd,$schema =~ /(CREATE\s+TRIGGER\s.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(ALTER\sTABLE[^;]*FOREIGN\sKEY.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(ALTER\sTABLE[^;]*PRIMARY\sKEY.*?;)/gs);
	close($fd);
}

# Produce serialized version of the object representation (XML)
sub buildXmlFile {
	my ($xmlFileName,$xmlOutput,$xmlWriter);
	my (@args,@requests,@cursors,@invokedMethods,@callers,@row);
	$xmlFileName = Configuration->getOption('xmlFilePath');
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
		 			my $dest = Configuration->getOption('requestsPath') . $REQUESTS_FOLDER . '/' . $r->getName() . '.sql';
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
		 			my $dest = Configuration->getOption('requestsPath') . $CURSORS_FOLDER . '/' . $r->getName() . '.sql';
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

# Gentlemen, start your engines!
sub run {
	my ($schema);

	my @subFolders = ($REQUESTS_FOLDER , $CURSORS_FOLDER);
	
	$schema = loadSQLSchema();
	$model = SqlDatabase->new(Configuration->getOption('schemaPath'),cleanSchema($schema));

	if(Configuration->getOption('requestsPath')) {
		rmtree(Configuration->getOption('requestsPath'));
		mkpath(Configuration->getOption('requestsPath'));
		foreach my $subFolder (@subFolders) {
			mkpath(Configuration->getOption('requestsPath') . $subFolder);
		}
		# Save request in folders
		saveRequests();
	}
	
	# Create a compact version of the schema
	if(Configuration->getOption('simplifiedSchemaPath')) {
		createCompactSchema(Configuration->getOption('simplifiedSchemaPath'),$schema);
	}
	
	# Produce serialized version of the object representation (XML)
	if(Configuration->getOption('xmlFilePath')) {
		buildXmlFile();
	}
}

# Default values
Configuration->setOption('exclude',0);
Configuration->setOption('schemaPath',undef);
Configuration->setOption('simplifiedSchemaPath',undef);
Configuration->setOption('xmlFilePath',undef);
Configuration->setOption('RequestsPath','/tmp');

# Command line parameters
sub setSchemaPath { 
	Configuration->setOption('schemaPath',$_[1]);
}

sub setSimplifiedSchemaPath { 
	Configuration->setOption('simplifiedSchemaPath',$_[1]);
}

sub setXmlFilePath {
	Configuration->setOption('xmlFilePath',$_[1]);
}

sub setRequestsPath { 
	Configuration->setOption('requestsPath',$_[1]); 
}

sub setExcludeOn {
	Configuration->setOption('exclude',1);
}

sub help {
}

GetOptions ("-/",               #compatible with the dos style
	"f=s" => \&setSchemaPath,
	"s=s" => \&setSimplifiedSchemaPath,
	"r=s" => \&setRequestsPath,
	"o=s" => \&setXmlFilePath,
	"x" => \&setExcludeOn,
	"v" => \&version,
	"h" => \&help
) or die("Error in command line arguments\n");

run();
#print Dumper($model);
