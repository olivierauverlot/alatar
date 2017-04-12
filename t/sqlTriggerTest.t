#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use Alatar::Model::SqlDatabase;
use Alatar::Model::SqlTable;
use Alatar::Model::SqlTrigger;

my $sql = <<'SCHEMA';
CREATE TABLE p (
    id integer NOT NULL,
    id_2 integer NOT NULL,
    col integer
);

CREATE FUNCTION foo(integer value) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN 42;
END;$$;

CREATE FUNCTION foo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN OLD;
END;$$;

CREATE TRIGGER trigger1 BEFORE DELETE ON p FOR EACH ROW EXECUTE PROCEDURE foo();
CREATE TRIGGER trigger2 AFTER INSERT OR UPDATE OR TRUNCATE ON p FOR EACH ROW EXECUTE PROCEDURE foo();
SCHEMA

my $model = Alatar::Model::SqlDatabase->new('test',$sql);
my @triggers = $model->getSqlTriggers();
is( scalar(@triggers),2,"2 triggers found");

my $trigger1 = $model->getFirstObjectWithName('trigger1',@triggers);
my $trigger2 = $model->getFirstObjectWithName('trigger2',@triggers);
is($trigger1->getName(),'trigger1','trigger1 is defined');
is($trigger2->getName(),'trigger2','trigger2 is defined');

# events
is(scalar($trigger1->getEvents()),1,'One event found on trigger1');
is(scalar(grep($_ eq 'DELETE', $trigger1->getEvents())),1,'Event DELETE is used on trigger1');

is(scalar($trigger2->getEvents()),3,'Three events found on trigger2');
is(scalar(grep($_ eq 'INSERT', $trigger2->getEvents())),1,'Event INSERT is used on trigger2');
is(scalar(grep($_ eq 'UPDATE', $trigger2->getEvents())),1,'Event UPDATE is used on trigger2');
is(scalar(grep($_ eq 'TRUNCATE', $trigger2->getEvents())),1,'Event TRUNCATE is used on trigger2');

# fire
is($trigger1->getFire(),'BEFORE','trigger1 is activated BEFORE the event');
is($trigger2->getFire(),'AFTER','trigger2 is activated AFTER the event');

# table
is($trigger1->getTable()->getName(),'p','trigger1 is applied on the table p');
is($trigger2->getTable()->getName(),'p','trigger2 is applied on the table p');

# function
is($trigger1->getInvokedFunction()->getName(),'foo','trigger1 calls a function named foo');
is($trigger2->getInvokedFunction()->getName(),'foo','trigger1 calls a function named foo');
is($trigger1->getInvokedFunction()->getArgumentsNumber(),0,'trigger1 calls the foo() function');
is($trigger2->getInvokedFunction()->getArgumentsNumber(),0,'trigger2 calls the foo() function');