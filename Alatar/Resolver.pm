package Alatar::Resolver;

use Data::Dumper;

use Alatar::Model::SqlFunction;
use Alatar::Model::Refs::SqlFunctionReference;
use Alatar::Model::SqlTable;
use Alatar::Model::SqlColumn;
use strict;

sub new {
	my ($class,$owner) = @_;
	my $this = {
		owner => $owner
	};
 	bless($this,$class);      
 	return $this;            
}

# Resolve the inherited tables
sub _resolveInheritedTables {
	my ($this) = @_;
	my @inheritedTables = $this->{owner}->getInheritedTables();
	my @tables = $this->{owner}->getSqlTables();
	foreach my $i (@inheritedTables) {
		foreach my $t (@tables) {
			foreach my $r ($i->getParentTables()) {
				if($r->getName() eq $t->getName()) {
					$r->setTarget($t);
				}
			}
		}
	}
}

# copy the inherited columns
sub _copyColumnsInInheritedTables {
	my ($this) = @_;
	my @inheritedTables = $this->{owner}->getInheritedTables();
	foreach my $t (@inheritedTables) {
		foreach my $r ($t->getParentTables()) {
			my @inheritedColumns = $r->getTarget()->getColumns();
			foreach my $c (@inheritedColumns) {
				my $ic = Alatar::Model::SqlColumn->new($t,$c->getName());
				$ic->hasBeenInherited();
				$ic->setDataType(Alatar::Model::Refs::SqlDataTypeReference->new($ic,$c->getDataType()->getName()));
				$t->addColumn($ic);
			}
		}
	}
}

# copy the inheritable constraints (NOT NULL, DEFAULT, CHECK)
# in the inherited tables
sub _copyConstraintsInInheritedTables {
	my ($this) = @_;
	my @inheritedTables = $this->{owner}->getInheritedTables();
	foreach my $t (@inheritedTables) {
		foreach my $r ($t->getParentTables()) {
			my @constraints = grep { $_->isInheritable() } $r->getTarget()->getConstraints();
			foreach my $c (@constraints) {
				# the inherited constraint is added and affected 
				# to the inherited column into the inherited table 
				my $cc = $c->clone($t);
				$t->addConstraint($cc);
			}
		}
	}
}

# Resolve the invoked functions in a function
sub _resolveInvokedFunctions {
	my ($this) = @_;
	my @functions = $this->{owner}->getSqlFunctions();
	
	# Resolve references for invoked functions
	foreach my $obj (@functions) {
	 	foreach my $invokedFunction ($obj->getInvokedFunctions()) {
	 		foreach my $f (@functions) {
	 			if($invokedFunction->isInvocationOf($f)) {
	 				$invokedFunction->setTarget($f);
	 			} 
	 		}
	 	}
	}
}

# Resolve the invoked function in a trigger definition
sub _resolveInvokedFunctionsByTriggers {
	my ($this) = @_;
	my @triggers = $this->{owner}->getSqlTriggers();
	my @functions = $this->{owner}->getSqlFunctions();
	foreach my $t (@triggers) {
		foreach my $f (@functions) {
			if($t->getInvokedFunctionReference()->isInvocationOf($f)) {
				$t->getInvokedFunctionReference()->setTarget($f);
			}
		}
	}
}

# Resolve the used tables (and views) in a rule definition
sub _resolveUsedTablesByRules {
	my ($this) = @_;
	my @rules = $this->{owner}->getSqlRules();
	my @tables = $this->{owner}->getAllTables();
	foreach my $rule (@rules) {
		foreach my $table (@tables) {
			if($rule->getTable()->getName() eq $table->getName()) {
				$rule->getTable()->setTarget($table);
			}
		}
	}	
}

# Resolve the used table (or view) in a trigger definition
sub _resolveUsedTablesByTriggers {
	my ($this) = @_;
	my @triggers = $this->{owner}->getSqlTriggers();
	my @tables = $this->{owner}->getAllTables();
	foreach my $trigger (@triggers) {
		my $tref = $trigger->getTableReference();
		foreach my $table (@tables) {
			if($tref->getName() eq $table->getName()) {
				$tref->setTarget($table);
			}
		}
	}
}
# resolve a column reference and returns an valid SqlColumn instance
sub _resolveColumnReference {
	my ($this,$columnReference) = @_;
	foreach my $column ($this->{owner}->getSqlColumns()) {
		if(($columnReference->getTableName() eq $column->getOwner()->getName()) && ($columnReference->getName() eq $column->getName())) {
			$columnReference->setTarget($column);
			last;
		}
	}
	return $columnReference;
}

# Resolve the column references in constraints
sub _resolveConstraints {
	my ($this) = @_;
	for my $table ($this->{owner}->getSqlTables()) {
		for my $constraint ($table->getConstraints()) {
			my (@columns,$reference);		
			foreach my $constraintColumn ($constraint->getColumns()) {
				push(@columns,$this->_resolveColumnReference($constraintColumn)->getTarget());
			}	
			# replace the list of SqlColumnReference with a list of SqlColumn
			$constraint->setColumns(@columns);
			
			# we resolve the reference in SqlColumnReference (SqlForeignKeyConstraint instances only)
			if($constraint->isSqlForeignKeyConstraint()) {
				$constraint->setReference($this->_resolveColumnReference($constraint->getReference())->getTarget());
			}
		}
	}
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# for constraint debugging only
sub _dumpAllConstraintReferences {
	my ($this) = @_;
	foreach my $t ($this->{owner}->getSqlTables()) {
		print 'table: ' . $t->getName() . "\n";
		print "------------------------------------\n";
		foreach my $col ($t->getColumns()) {
			print $col->getName() . '    ' . $col . "\n";
		}
		print "\n";
		foreach my $c ($t->getConstraints()) {
			print $c->printString() . "\n";
			foreach my $col ($c->getColumns()) {
				print $col->getName() . '   ' . $col ."\n";
			}
		}
		print "\n\n";
	}
}

sub resolveAllLinks {
	my ($this) = @_;
	# print "--- RESOLVER ---\n";
	$this->_resolveInheritedTables();
	$this->_copyColumnsInInheritedTables();
	$this->_copyConstraintsInInheritedTables();
	$this->_resolveInvokedFunctions();
	$this->_resolveInvokedFunctionsByTriggers();
	$this->_resolveUsedTablesByRules();
	$this->_resolveUsedTablesByTriggers();
	$this->_resolveConstraints();
	
	# for constraint debugging only
	# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	# $this->_dumpAllConstraintReferences();
}

1;