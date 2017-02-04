#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use Alatar::Model::SqlDatabase;
use Alatar::Model::SqlTable;

my $sql = <<'SCHEMA';
CREATE TABLE t1 (
    id integer NOT NULL
);

CREATE TABLE t2 (
	ref integer
);

CREATE TABLE child (
	value integer
) INHERITS (t1,t2);
SCHEMA

my @columns;
my $idColumn;
my $refColumn;
my $valueColumn;

my $model = Alatar::Model::SqlDatabase->new('test',$sql);
my @tables = $model->getSqlTables();
is( scalar(@tables),3,"3 tables found");

my @inheritedTables = $model->getInheritedTables();
is(scalar(@inheritedTables),1,"1 inherited tables found");

my $child = $model->getFirstObjectWithName('child',@inheritedTables);
isnt($child,undef,'child table found');
is($child->isChild(),1,'child inherit from another table');
is(scalar($child->getParentTables()),2,'child inherits from 2 tables');
is(scalar($child->getColumns()),3,'3 columns found in the child table');

@columns = $child->getColumns();
$idColumn = $model->getFirstObjectWithName('id',@columns);
$refColumn = $model->getFirstObjectWithName('ref',@columns);
$valueColumn = $model->getFirstObjectWithName('value',@columns);
isnt($idColumn,undef,'id column is defined in child table');
is($idColumn->isInherited(),1,'id column has been inherited');
isnt($refColumn,undef,'ref column is defined in child table');
is($refColumn->isInherited(),1,'ref column has been inherited');
isnt($valueColumn,undef,'value column is defined in child table');
is($valueColumn->isInherited(),0,'value column has not been inherited');



