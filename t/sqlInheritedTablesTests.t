#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;

my $sql = <<'SCHEMA';
CREATE TABLE mother (
    id integer NOT NULL
);

CREATE TABLE child (
	ref integer
) INHERITS (mother);

CREATE TABLE subChild (
	value integer
) INHERITS (child);
SCHEMA

my @columns;
my $idColumn;
my $refColumn;

my $model = SqlDatabase->new('test',$sql);
my @tables = $model->getSqlTables();
is( scalar(@tables),3,"3 tables found");

my @inheritedTables = $model->getInheritedTables();
is(scalar(@inheritedTables),2,"2 inherited tables found");

my $tableMother = $model->getFirstObjectWithName('mother',$model->getSqlTables());
my $tableChild = $model->getFirstObjectWithName('child',@inheritedTables);
isnt($tableChild,undef,'child table found');
is($tableChild->isChild(),1,'child inherit from another table');
is($tableChild->inheritsFrom($tableMother),1,'child inherits from mother');
is(scalar($tableChild->getColumns()),2,'2 columns found in the child table');

@columns = $tableChild->getColumns();
$idColumn = $model->getFirstObjectWithName('id',@columns);
$refColumn = $model->getFirstObjectWithName('ref',@columns);
isnt($idColumn,undef,'id column is defined in child table');
isnt($refColumn,undef,'ref column is defined in child table');
is($idColumn->isInherited(),1,'id column has been inherited');
is($refColumn->isInherited(),0,'ref column has not been inherited');

my $tableSubChild = $model->getFirstObjectWithName('subChild',@inheritedTables);
isnt($tableSubChild,undef,'subChild table found');
is($tableSubChild->isChild(),1,'subChild inherit from another table');
is($tableSubChild->inheritsFrom($tableChild),1,'subChild inherits from child');
is(scalar($tableSubChild->getColumns()),3,'3 columns found in the subChild table');

@columns = $tableSubChild->getColumns();
$idColumn = $model->getFirstObjectWithName('id',@columns);
isnt($idColumn,undef,'id column is defined in subChild table');
is($idColumn->isInherited(),1,'id column has been inherited');

$refColumn = $model->getFirstObjectWithName('ref',@columns);
isnt($refColumn,undef,'ref column is defined in subChild table');
is($refColumn->isInherited(),1,'ref column has been inherited');

my $valueColumn = $model->getFirstObjectWithName('value',@columns);
isnt($valueColumn,undef,'value column is defined in subChild table');
is($valueColumn->isInherited(),0,'value column has not been inherited');

