#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use Alatar::Model::SqlDataType;

my $datatype;

$datatype = Alatar::Model::SqlDataType->new(undef,'integer');
is( $datatype->getName(),'integer',"'integer' datatype found");

$datatype = Alatar::Model::SqlDataType->new(undef,'character varying');
is( $datatype->getName(),'character varying',"'character varying' datatype found");

$datatype = Alatar::Model::SqlDataType->new(undef,'character varying(255)');
is( $datatype->getName(),'character varying',"'character varying' datatype found");

$datatype = Alatar::Model::SqlDataType->new(undef,'timestamp without time zone');
is( $datatype->getName(),'timestamp without time zone',"'timestamp without time zone");

