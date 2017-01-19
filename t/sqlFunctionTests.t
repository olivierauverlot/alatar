#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use Alatar::Model::SqlDatabase;
use Alatar::Model::SqlFunction;

my $sql = <<'SCHEMA';
CREATE FUNCTION fooWithOneParameter(integer value)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN 42;
END;$$;

CREATE FUNCTION fooWithParameters(integer value,real realvalue) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN 42;
END;$$;

CREATE FUNCTION fooTrigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $trigger$
BEGIN
	RETURN OLD;
END;$trigger$;

CREATE FUNCTION fooSql(integer,real,bigint) RETURNS integer
    LANGUAGE sql
    AS $_$
  INSERT INTO interwiki (iw_prefix, iw_url, iw_local) VALUES ($1,$2,$3);
  SELECT 1;
$_$;
SCHEMA

my @args;

my $model = Alatar::Model::SqlDatabase->new('test',$sql);
my @functions = $model->getSqlFunctions();
is(scalar(@functions),4,"4 functions found");

my $fooWithOneParameter = $model->getFirstObjectWithName('fooWithOneParameter',@functions);
is($fooWithOneParameter->getName(),'fooWithOneParameter','fooWithOneParameter() found');
is($fooWithOneParameter->getLanguage(),'plpgsql','PL/pgSQL function');
is($fooWithOneParameter->getReturnType(),undef,'No Return type');
@args = $fooWithOneParameter->getArgs();
is($fooWithOneParameter->getArgumentsNumber(),1,'One argument found');
is($args[0]->getName(),'value','value is the argument name of fooWithOneParameter');
is($args[0]->getDataType()->getName(),'integer','value is an integer argument');

my $fooWithParameters = $model->getFirstObjectWithName('fooWithParameters',@functions);
is($fooWithParameters->getName(),'fooWithParameters','fooWithParameters() found');
is($fooWithParameters->getLanguage(),'plpgsql','PL/pgSQL function');
is($fooWithParameters->getReturnType()->getName(),'integer','Return type: integer');
@args = $fooWithParameters->getArgs();
is($fooWithParameters->getArgumentsNumber(),2,'Two arguments found');
is($args[0]->getName(),'value','value is the first argument name of fooWithParameters');
is($args[0]->getDataType()->getName(),'integer','value is an integer argument');
is($args[1]->getName(),'realvalue','realvalue is second the argument name of fooWithParameters');
is($args[1]->getDataType()->getName(),'real','value is an integer argument');

my $fooTrigger = $model->getFirstObjectWithName('fooTrigger',@functions);
is($fooTrigger->getName(),'fooTrigger','fooTrigger() found');
is($fooTrigger->getLanguage(),'plpgsql','PL/pgSQL function');
is($fooTrigger->getReturnType()->getName(),'trigger','Return type: trigger');
@args = $fooTrigger->getArgs();
is($fooTrigger->getArgumentsNumber(),0,'No argument found');

my $fooSql = $model->getFirstObjectWithName('fooSql',@functions);
is($fooSql->getName(),'fooSql','fooSql() found');
is($fooSql->getLanguage(),'sql','SQL function');
is($fooSql->getReturnType()->getName(),'integer','Return type: integer');
@args = $fooSql->getArgs();
is($fooSql->getArgumentsNumber(),3,'Three arguments found');
is($args[0]->getName(),'$1','$1 is the first argument name of fooSql');
is($args[0]->getDataType()->getName(),'integer','value is an integer argument');
is($args[1]->getName(),'$2','$2 is the second argument name of fooSql');
is($args[1]->getDataType()->getName(),'real','value is an integer argument');
is($args[2]->getName(),'$3','$3 is the third argument name of fooSql');
is($args[2]->getDataType()->getName(),'bigint','value is an integer argument');


