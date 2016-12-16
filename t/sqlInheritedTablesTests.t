#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;

my $sql = <<'SCHEMA';
CREATE TABLE mother (
    id integer
);

CREATE TABLE child (
	ref integer
) INHERITS (mother);

CREATE TABLE subChild (
	value integer
) INHERITS (child);
SCHEMA

my $model = SqlDatabase->new('test',$sql);
my @tables = $model->getSqlTables();
is( scalar(@tables),3,"3 tables found");

my @inheritedTables = $model->getInheritedTables();
is(scalar(@inheritedTables),2,"2 inherited tables found");

my $tableChild = $model->getFirstObjectWithName('child',@inheritedTables);
isnt($tableChild,undef,'Child table found');
is($tableChild->getParentTableName(),'mother','Child inherits from mother');
is(scalar($tableChild->getColumns()),2,'2 columns found in the child table');

my $tableSubChild = $model->getFirstObjectWithName('subChild',@inheritedTables);
isnt($tableSubChild,undef,'subChild table found');
is($tableSubChild->getParentTableName(),'child','subChild inherits from children');
is(scalar($tableSubChild->getColumns()),3,'3 columns found in the subChild table');