#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;
use SqlColumn;

my $sql = <<'SCHEMA';
CREATE TABLE p (
    id integer NOT NULL,
    id_2 integer NOT NULL,
    col integer
);

CREATE TABLE i (
	id integer NOT NULL,
	id_fk integer NOT NULL
);

ALTER TABLE ONLY p ADD CONSTRAINT p_pkey PRIMARY KEY (id, id_2);
ALTER TABLE ONLY i ADD CONSTRAINT i_pkey PRIMARY KEY (id);

ALTER TABLE ONLY i ADD CONSTRAINT fk_id_fk FOREIGN KEY (id_fk) REFERENCES p(id) ON DELETE RESTRICT;
SCHEMA

my $model = SqlDatabase->new('test',$sql);

my @tables = $model->getSqlTables();
is (scalar(@tables),2,'Two tables found');

my @p = $model->getObjectsWithName('p',@tables);
is( scalar(@p),1,"Table 'p' found");
my $table_p = $p[0];

my @i = $model->getObjectsWithName('i',@tables);
is( scalar(@i),1,"Table 'i' found");
my $table_i = $i[0];

is( $table_p->getColumnWithName('col')->isPk(),0,"'p.col' is not a Primary Key");
is( $table_p->getColumnWithName('col')->isFk(),0,"'p.col' is not a Foreign Key");
is( $table_p->getColumnWithName('id')->isPk(),1,"'p.id' is a Primary Key");
is( $table_p->getColumnWithName('id_2')->isPk(),1,"'p.id_2' is a Primary Key");
is( $table_i->getColumnWithName('id')->isPk(),1,"'i.id' is a Primary Key");
is( $table_i->getColumnWithName('id_fk')->isFk(),1,"'i.id_fk' is a Foreign Key");
