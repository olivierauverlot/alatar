#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use LWP::Simple;

use SqlDatabase;
use SqlTable;
use SqlColumn;

my $model = SqlDatabase->new('test',undef);
my $table = SqlTable->new($model,'table');
my $column = SqlColumn->new($table,'column','INTEGER',[]);