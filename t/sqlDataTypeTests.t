#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDataType;

my $datatype;

$datatype = SqlDataType->new(undef,'integer');
is( $datatype->getName(),'integer',"'integer' datatype found");

$datatype = SqlDataType->new(undef,'character varying');
is( $datatype->getName(),'character varying',"'character varying' datatype found");

$datatype = SqlDataType->new(undef,'character varying(255)');
is( $datatype->getName(),'character varying',"'character varying' datatype found");

$datatype = SqlDataType->new(undef,'timestamp without time zone');
is( $datatype->getName(),'timestamp without time zone',"'timestamp without time zone");

