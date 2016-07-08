#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;

my $sql = qq!support (     cle integer DEFAULT nextval('seq_support_cle'::regclass) NOT NULL,     cle_personne integer NOT NULL,     debut date NOT NULL,     fin date,     cle_categorie integer NOT NULL,     cle_typesupport integer NOT NULL,     cle_typefinancement integer NOT NULL,     financement character varying(255),     cle_employeur integer NOT NULL,     cle_grade integer NOT NULL,     situation character varying(255),     datecreation timestamp without time zone,     datemodification timestamp without time zone,     cle_cmu integer,     cle_section integer,     cle_enseignement integer,     code_financement_univ character varying,     cle_labo integer,     cle_cotutelle integer,     invite boolean DEFAULT false,     CONSTRAINT c_dates_support CHECK ((fin > debut)) )!;
my $model = SqlDatabase->new('test',undef);
my $extractor = PgTableExtractor->new($model,$sql);
$model->addObject($extractor->getEntity());

my @tables = $model->getSqlTables();
is( scalar(@tables), 1,  "One table found" );

my @tableSupport = $model->getObjectsWithName('support',@tables);
is( $tableSupport[0]->getName(), 'support' ,  "The table is named 'support'" );

my @columns = $tableSupport[0]->getColumns();
is( scalar(@columns), 20,  "20 colums found" );


# 8 tables sont NOT NULL