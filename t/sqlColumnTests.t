#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;
use SqlColumn;

my $sql = <<'SCHEMA';
CREATE TABLE t (
    id integer,
    name character varying(255),
    category integer DEFAULT 0 NOT NULL,
    foo integer DEFAULT func('arg')
);

ALTER TABLE ONLY t ADD CONSTRAINT t_unique UNIQUE (name, category);
    
ALTER TABLE ONLY t ADD CONSTRAINT foo_unique UNIQUE (foo);
SCHEMA

my $model = SqlDatabase->new('test',$sql);

my @tables = $model->getSqlTables();
is (scalar(@tables),1,'One table found');

my @t = $model->getObjectsWithName('t',@tables);
is( scalar(@t),1,"Table 't' found");
my $table_t = $t[0];

my @columns = $table_t->getColumns();

my $id = $table_t->getColumnWithName('id'); 
my $name = $table_t->getColumnWithName('name'); 
my $category = $table_t->getColumnWithName('category'); 
my $foo = $table_t->getColumnWithName('foo');

isnt($id,undef,"'id' column found");
is( $id->getDataType()->getName(),'integer',"'integer' datatype found");

isnt($name,undef,"'name' column found");
is( $name->getDataType()->getName(),'character varying',"'character varying' datatype found");

isnt($category,undef,"'category' column found");
is( $category->getDataType()->getName(),'integer',"'integer' datatype found");
is( $category->isNotNull(),1,'NOT NULL constraint found');

is ( $id->isUnique(),0,"'id' column is not unique");
is ( $name->isUnique(),1,"'name' column is unique");
is ( $category->isUnique(),1,"'category' column is unique");
is ( $foo->isUnique(),1,"'foo' column is unique");

is ( $name->hasDefaultValue(),0,"'name' column has not a default valeur");
is ( $category->hasDefaultValue(),1,"'category' column has a default valeur");
is ( $foo->hasDefaultValue(),1,"'foo' column has a default valeur");

