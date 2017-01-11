#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;

my $sql = <<'SCHEMA';
CREATE TABLE aTable (
    id integer NOT NULL
);

CREATE RULE "_RETURN" AS ON SELECT TO aTable DO INSTEAD SELECT aTable.id FROM aTable;
SCHEMA

my $model = SqlDatabase->new('test',$sql);

my @tables = $model->getAllTables();
is(scalar(@tables),1,"one table found");

my @rules = $model->getSqlRules();
is( scalar(@rules),1,"One rule found");

my $rule = $rules[0];
is ($rule->getName(),'_RETURN','_RETURN rule found');

is ($rule->isSelectEvent(),1,'Select Event found');
is ($rule->getTable()->getTableName(),'aTable','aTable found');
is ($rule->getTable()->getTableReference(),$model->getFirstObjectWithName('aTable',$model->getAllTables()),'Found reference of aTable');
is ($rule->doInstead(),1,'INSTEAD indicates that the commands should be executed instead of the original command');
is ($rule->getSqlRequest()->getRequest(),'SELECT aTable.id FROM aTable','Request found');
