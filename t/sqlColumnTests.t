#!/usr/bin/env perl

use strict;
use Test::More 'no_plan';
use Data::Dumper;

use SqlDatabase;
use SqlTable;
use SqlColumn;

my $sql = qq!support (     cle integer DEFAULT nextval('seq_support_cle'::regclass) NOT NULL,     cle_personne integer NOT NULL,     debut date NOT NULL,     fin date,     cle_categorie integer NOT NULL,     cle_typesupport integer NOT NULL,     cle_typefinancement integer NOT NULL,     financement character varying(255),     cle_employeur integer NOT NULL,     cle_grade integer NOT NULL,     situation character varying(255),     datecreation timestamp without time zone,     datemodification timestamp without time zone,     cle_cmu integer,     cle_section integer,     cle_enseignement integer,     code_financement_univ character varying,     cle_labo integer,     cle_cotutelle integer,     invite boolean DEFAULT false,     CONSTRAINT c_dates_support CHECK ((fin > debut)) )!;

my ($extractor,$column);

my $model = SqlDatabase->new('test',undef);
my $table = SqlTable->new($model,'table');
$model->addObject($table);

$extractor = PgColumnExtractor->new($model,'id integer');
$column = $extractor->getEntity();
is( $column->getName(),'id',"'id' column found");
is( $column->getDataType()->getName(),'integer',"'integer' datatype found");

$extractor = PgColumnExtractor->new($model,'name character varying(255)');
$column = $extractor->getEntity();
is( $column->getName(),'name',"'name' column found");
is( $column->getDataType()->getName(),'character varying',"'character varying' datatype found");

$extractor = PgColumnExtractor->new($model,'category integer NOT NULL');
$column = $extractor->getEntity();
is( $column->getName(),'category',"'category' column found");
is( $column->getDataType()->getName(),'integer',"'integer' datatype found");
is( $column->isNotNull(),1,'NOT NULL constraint found');