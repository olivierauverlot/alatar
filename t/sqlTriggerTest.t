#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;
use SqlTrigger;

my $sql = <<'SCHEMA';
CREATE TABLE p (
    id integer NOT NULL,
    id_2 integer NOT NULL,
    col integer
);

CREATE FUNCTION t_p_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN OLD;
END;$$;

CREATE TRIGGER trigger1 BEFORE DELETE ON p FOR EACH ROW EXECUTE PROCEDURE t_p_func();
SCHEMA

my $model = SqlDatabase->new('test',$sql);