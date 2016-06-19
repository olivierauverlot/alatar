package SqlColumn;

use strict;
use SqlObject;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$name,$dataType,$constraints) = @_;
	my $this = $class->SUPER::new($owner,$name);
	$this->{dataType} = $dataType;
	$this->{pk} = 0;
	$this->{fk} = 0;
	$this->{constraints} = [ ];
 	bless($this,$class);   
 	$this->_extractColumnConstraints($constraints);
 	return $this;            
}

# Setters and getters
# -----------------------------------------------------------------------------

sub getDataType {
	my ($this) = @_;
	return $this->{dataType};
}

sub isPK {
	my ($this) = @_;
	return $this->{pk};
}

sub isFK {
	my ($this) = @_;
	return $this->{fk};
}

sub getConstraints {
	my ($this) = @_;
	return $this->{constraints};
}

sub isSqlColumn {
	my ($this) = @_;
	return 0;
}

# actions
# -----------------------------------------------------------------------------
sub _extractColumnConstraints {
	my ($this,$constraints) = @_;
}


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