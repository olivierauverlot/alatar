#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use Alatar::Model::SqlDatabase;
use Alatar::Model::SqlEnumerationType;
use Alatar::Model::SqlCompositeType;

my $sql = <<'SCHEMA';
CREATE TYPE categoryList AS ENUM ('adventure','child','syfy');

CREATE TYPE productDescription AS (
	id integer,
	description text,
	category categoryList
);

CREATE TABLE orders (
	id integer,
	product productDescription,
	cat categoryList
);
SCHEMA
  
my $model = Alatar::Model::SqlDatabase->new('test',$sql);
my @enums = $model->getEnumerations();
my @compositeTypes = $model->getCompositeTypes(); 

is(scalar(@enums),1,"One enumeration found");

is(scalar(@compositeTypes),1,"One composite type found");