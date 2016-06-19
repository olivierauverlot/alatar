#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use LWP::Simple;

use SqlDatabase;
use SqlTable;

my $sql = qq!
site (key integer DEFAULT nextval('seq_key'::regclass) NOT NULL, name character varying NOT NULL, start date, end date, CONSTRAINT c_dates CHECK ((end > fin)) )'
!;

my $model = SqlDatabase->new('test',undef);
my $table = SqlTable->new($model,'table');
