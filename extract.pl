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
use File::Basename;
use Data::Dumper;
use XML::Writer;
use IO::File;
use Alatar::Configuration;
use Alatar::PostgreSQL::PgXMLExporter;
use Alatar::Model::SqlDatabase;
use Alatar::Model::SqlFunction;

use utf8;

my $VERSION = '0.1 Build 20161008-1';

my $model;

sub version {
	print "Alatar version $VERSION\n\n";
	exit 1;
}

# return the folder that contains the application
sub defineAppFolder {
	return dirname $0;
}

sub loadSQLSchema {
	my ($filePath) = @_;
	my $data;
	
	open(DATA,$filePath) || die "You must specify a SQL schema";
	while( defined( my $l = <DATA> ) ) {
   		$data = $data . $l;
	}
	close(DATA);
	
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
	foreach my $t ($model->getSqlTables()) {
		$dest = Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('tables_folder') . '/' . $t->getName() . '.sql';
		saveRequest($dest,$t->getSqlRequest()->getRequest());
	}
	
	foreach my $f ($model->getSqlFunctions()) {
		foreach my $r ($f->getSqlRequests()) {
			$dest = Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('requests_folder') . '/' . $r->getName() . '.sql';
			saveRequest($dest,$r->getRequest());
		}
	}

	foreach my $f ($model->getSqlFunctions()) {
		foreach my $r ($f->getSqlCursorRequests()) {
			$dest = Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('cursors_folder') . '/' . $r->{owner}->getName() . '_' . $r->getName() . '.sql';
			saveRequest($dest,$r->getRequest());
		}
	}

	foreach my $v ($model->getSqlViews()) {
		$dest = Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('views_folder') . '/' . $v->getName() . '.sql';
		saveRequest($dest,$v->getSqlRequest()->getRequest());
	}
	
	foreach my $r ($model->getSqlRules()) {
		$dest = Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('rules_folder') . '/' . $r->getName() . '_' . $r->getId() . '.sql';
		saveRequest($dest,$r->getSqlRequest()->getRequest());
	}

	foreach my $r ($model->getSqlTriggers()) {
		$dest = Alatar::Configuration->getOption('requestsPath') . Alatar::Configuration->getOption('triggers_folder') . '/' . $r->getName() . '.sql';
		saveRequest($dest,$r->getSqlRequest()->getRequest());
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
	addToCompactSchema($fd,$schema =~ /(CREATE\sFUNCTION\s.*?\$\$;)/gs);
	addToCompactSchema($fd,$schema =~ /(CREATE\s+TRIGGER\s.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(ALTER\sTABLE[^;]*FOREIGN\sKEY.*?;)/gs);
	addToCompactSchema($fd,$schema =~ /(ALTER\sTABLE[^;]*PRIMARY\sKEY.*?;)/gs);
	close($fd);
}

# Gentlemen, start your engines!
sub run {
	my ($schema);

	my @subFolders = (
		Alatar::Configuration->getOption('tables_folder') ,
		Alatar::Configuration->getOption('triggers_folder') ,
		Alatar::Configuration->getOption('requests_folder') , 
		Alatar::Configuration->getOption('cursors_folder'),
		Alatar::Configuration->getOption('views_folder'),
		Alatar::Configuration->getOption('rules_folder'),
	);
	
	$schema = loadSQLSchema(Alatar::Configuration->getOption('schemaPath'));

	$model = Alatar::Model::SqlDatabase->new(Alatar::Configuration->getOption('schemaPath'),$schema);

	if(Alatar::Configuration->getOption('requestsPath')) {
		rmtree(Alatar::Configuration->getOption('requestsPath'));
		mkpath(Alatar::Configuration->getOption('requestsPath'));
		foreach my $subFolder (@subFolders) {
			mkpath(Alatar::Configuration->getOption('requestsPath') . $subFolder);
		}
		# Save request in folders
		saveRequests();
	}
	
	# Produce serialized version of the object representation (XML)
	if(Alatar::Configuration->getOption('xmlFilePath')) {
		Alatar::PostgreSQL::PgXMLExporter->new($model);
	}
	
	# Create a compact version of the schema
	if(Alatar::Configuration->getOption('simplifiedSchemaPath')) {
		createCompactSchema(Alatar::Configuration->getOption('simplifiedSchemaPath'),$schema);
	}
}

# Default values
Alatar::Configuration->setOption('appFolder',defineAppFolder());
Alatar::Configuration->setOption('tables_folder','/tables');
Alatar::Configuration->setOption('triggers_folder','/triggers');
Alatar::Configuration->setOption('requests_folder','/requests');
Alatar::Configuration->setOption('cursors_folder','/cursors');
Alatar::Configuration->setOption('views_folder','/views');
Alatar::Configuration->setOption('rules_folder','/rules');
Alatar::Configuration->setOption('exclude',0);
Alatar::Configuration->setOption('schemaPath',undef);
Alatar::Configuration->setOption('simplifiedSchemaPath',undef);
Alatar::Configuration->setOption('xmlFilePath',undef);
Alatar::Configuration->setOption('RequestsPath',undef);

# Command line parameters
sub setSchemaPath { 
	Alatar::Configuration->setOption('schemaPath',$_[1]);
}

sub setSimplifiedSchemaPath { 
	Alatar::Configuration->setOption('simplifiedSchemaPath',$_[1]);
}

sub setXmlFilePath {
	Alatar::Configuration->setOption('xmlFilePath',$_[1]);
}

sub setRequestsPath { 
	Alatar::Configuration->setOption('requestsPath',$_[1]); 
}

sub setExcludeOn {
	Alatar::Configuration->setOption('exclude',1);
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
