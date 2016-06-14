#!/usr/bin/env perl

# perl -MCPAN -e 'install XML::Writer'

# http://search.cpan.org/~abigail/Regexp-Common-2016020301/lib/Regexp/Common.pm

# Une fonction peut ne pas avoir de valeur de retour
#CREATE FUNCTION sales_tax(subtotal real, OUT tax real) AS $$
#BEGIN
#    tax := subtotal * 0.06;
#END;
#$$ LANGUAGE plpgsql;

use strict;
use warnings;
use Getopt::Long;
use File::Path;
use Data::Dumper;
use XML::Writer;
use IO::File;
use File::Basename;
use Configuration;
use PgXMLExporter;
use SqlDatabase;
use SqlFunction;

use utf8;

my $VERSION = '0.1';

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

# Gentlemen, start your engines!
sub run {
	my ($schema);

	my @subFolders = (Configuration->getOption('requests_folder') , Configuration->getOption('cursors_folder'));
	
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
		PgXMLExporter->new($model);
	}
}

# Default values
Configuration->setOption('requests_folder','/requests');
Configuration->setOption('cursors_folder','/cursors');
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
