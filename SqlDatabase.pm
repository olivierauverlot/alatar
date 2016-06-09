package SqlDatabase;

use Data::Dumper;
use strict;
use SqlFunction;
use SqlTrigger; 
use SqlResolver;

sub new {
	my ($class,$name,$schema) = @_;
	my $this = {
		name => $name,
		schema => $schema,
		objects => [ ],
		resolver => undef
	};
 	bless($this,$class); 
 	$this->{resolver} = SqlResolver->new($this);
 	$this->_extractFunctions();
 	$this->_extractTriggers();
 	$this->{resolver}->resolveAllLinks();
 	return $this;            
}

# Setters and getters
# -------------------------------------------------------------
sub getName {
	my ($this) = @_;
	return $this->{name};
}

sub getSchema {
	my ($this) = @_;
	return $this->{schema};
}

sub addObject {
	my ($this,$sqlObject) = @_;
	push(@{$this->{objects}},$sqlObject);
	return $sqlObject;
}

sub getObjects {
	my ($this) = @_;
	return @{$this->{objects}};
}

sub getSqlFunctions {
	my ($this) = @_;
	my @functions;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlFunction()) {
	 		push(@functions,$obj);
	 	}
	}
	return @functions;
}

sub getSqlTriggers {
	my ($this) = @_;
	my @triggers;
	foreach my $obj ($this->getObjects()) {
	 	if($obj->isSqlTrigger()) {
	 		push(@triggers,$obj);
	 	}
	}
	return @triggers;
}

sub getAllRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getAllRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSqlRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getSqlRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

sub getSqlCursorRequests {
	my ($this) = @_;
	my @requests;
	foreach my $f ($this->getSqlFunctions()) {
		foreach my $r ($f->getSqlCursorRequests()) {
			push(@requests,$r);
		}
	}
	return @requests;
}

# Actions
# -------------------------------------------------------------

sub _extractFunctions {
	my ($this) = @_;
	my $function;
	my @functions = $this->{schema} =~ /CREATE FUNCTION\s(.*?)END;\$\$;/gi;
	foreach my $fcode (@functions) {
		$function = $this->addObject(SqlFunction->new($this,$fcode));
		# RECHERCHE DES COMMENTAIRES
		# COMMENT ON FUNCTION affiche_etage(etage integer) IS 'Retourne l''étage ou rez-de-chaussée';
		print $function->getName();
	}
}

sub _extractTriggers {
	my ($this) = @_;
	my @triggers = $this->{schema} =~ /CREATE TRIGGER\s(.*?);/gi;
	foreach my $trigger (@triggers) {
		$this->addObject(SqlTrigger->new($this,$trigger));
	}
}

1;