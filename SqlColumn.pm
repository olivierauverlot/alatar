package SqlColumn;

use Data::Dumper;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$dataType) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{dataType} = $dataType;
	$this->{_fk} = 0;
	$this->{_unique} = 0;
	$this->{invokedFunctions} = [ ];
   	$this->{callers} = [ ];
 	bless($this,$class);   
 	return $this;             
}

sub isSqlColumn {
	my ($this) = @_;
	return 0;
}

sub getObjectType {
	my ($this) = @_;
	return 'SqlColumn';
}

sub printString {
	my ($this) = @_;
	return $this->getObjectType() . ' : ' . $this->{name} . ' = ' . $this->{type};
}

# Setters and getters
# -----------------------------------------------------------------------------

sub setDataType {
	my ($this,$dataType) = @_;
	$this->{dataType} = $dataType;
}

sub getDataType {
	my ($this) = @_;
	return $this->{dataType};
}

sub isNotNull {
	my ($this) = @_;

	return grep { 
		$_->isSqlNotNullConstraint() && grep { $_ == $this } $_->getColumns() 
	} $this->getOwner()->getConstraints();
}

sub isPk {
	my ($this) = @_;

	return grep { 
		$_->isSqlPrimaryKeyConstraint() && grep { $_ == $this } $_->getColumns()
	} $this->getOwner()->getConstraints();
}

sub isFk {
	my ($this) = @_;
	return $this->{_fk};
}


# actions
# -----------------------------------------------------------------------------



=begin

CREATE TABLE dernierdiplome (
    cle integer DEFAULT nextval('seq_dernier_diplome_cle'::regclass) NOT NULL,
    cle_personne integer NOT NULL,
    cle_diplome integer NOT NULL,
    etablissement character varying(255) NOT NULL,
    cle_pays integer NOT NULL,
    annee integer NOT NULL
);

ALTER TABLE ONLY these ALTER COLUMN cle SET DEFAULT nextval('seq_diplome_cle'::regclass);

ALTER TABLE ONLY accesbatiment
    ADD CONSTRAINT accesbatiment_pkey PRIMARY KEY (cle_personne, cle_batiment);
    
where column_constraint is:

[ CONSTRAINT constraint_name ]
{ NOT NULL |
  NULL |
  CHECK ( expression ) |
  DEFAULT default_expr |
  UNIQUE index_parameters |
  PRIMARY KEY index_parameters |
  REFERENCES reftable [ ( refcolumn ) ] [ MATCH FULL | MATCH PARTIAL | MATCH SIMPLE ]
    [ ON DELETE action ] [ ON UPDATE action ] }
[ DEFERRABLE | NOT DEFERRABLE ] [ INITIALLY DEFERRED | INITIALLY IMMEDIATE ]
=cut

1;