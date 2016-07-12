#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;
use SqlColumn;

my ($extractor,$column);

my $model = SqlDatabase->new('test',undef);
my $table = SqlTable->new($model,'table');
$model->addObject($table);

$extractor = PgColumnExtractor->new($table,'id integer');
$column = $extractor->getEntity();
is( $column->getName(),'id',"'id' column found");
is( $column->getDataType()->getName(),'integer',"'integer' datatype found");

$extractor = PgColumnExtractor->new($table,'name character varying(255)');
$column = $extractor->getEntity();
is( $column->getName(),'name',"'name' column found");
is( $column->getDataType()->getName(),'character varying',"'character varying' datatype found");

$extractor = PgColumnExtractor->new($table,'category integer NOT NULL');
$column = $extractor->getEntity();
is( $column->getName(),'category',"'category' column found");
is( $column->getDataType()->getName(),'integer',"'integer' datatype found");
is( $column->isNotNull(),1,'NOT NULL constraint found');