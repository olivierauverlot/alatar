package PgResolver;

use Data::Dumper;

use SqlFunction;
use SqlFunctionInvocation;
use SqlTable;
use SqlColumn;
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
			if($i->getParentTableName() eq $t->getName()) {
				$i->setParentTableReference($t);
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
	 				$invokedFunction->setFunctionReference($f);
	 				my $caller = $invokedFunction->getOwner();
	 				my $invocation = SqlFunctionInvocation->new($caller,$caller->getName(),$caller->getArgumentsNumber());
	 				$invocation->setFunctionReference($caller);
	 				$f->addCaller($invocation);
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
			if($t->getInvokedFunction()->isInvocationOf($f)) {
				$t->getInvokedFunction()->setFunctionReference($f);
			}
		}
	}
}

# Resolve the used table (or view) in a trigger definition
sub _resolveUsedTablesByTriggers() {
	my ($this) = @_;
	my @triggers = $this->{owner}->getSqlTriggers();
	my @tables = $this->{owner}->getAllTables();
	foreach my $trigger (@triggers) {
		foreach my $table (@tables) {
			if($trigger->getTableName() eq $table->getName()) {
				$trigger->setTableReference($table);
			}
		}
	}
}

# resolve a column reference and returns an valid SqlColumn instance
# recoit p et id
sub _resolveColumnReference {
	my ($this,$columnReference) = @_;	
	
	my ($tableRef,$columnRef);
	# print $columnReference->getTable()->getName();
	if(ref($columnReference->getColumn()) eq '') {
		# the column reference is undefined
		if(ref($columnReference->getTable()) eq '') {
			# we must resolve the table reference
			foreach my $table ($columnReference->getOwner()->getSqlTables()) {
				if($table->getName() eq $columnReference->getTable()) {
					$tableRef = $table;
				}
			}
		} else {
			$tableRef = $columnReference->getTable();
		}
		# and find the column reference
		foreach my $column ($tableRef->getColumns()) {
			if($column->getName() eq $columnReference->getColumn()) {
				$columnRef = $column;
			}
		}				
	} else {
		$columnRef = $columnReference->getColumn();
	}
	return $columnRef;
}

# Resolve the column references in constraints
sub _resolveConstraints {
	my ($this) = @_;
	for my $table ($this->{owner}->getSqlTables) {
		for my $constraint ($table->getConstraints()) {
			# we resolve only if the constraint's columns have no a reference to the owner
			my (@columns,$reference);		
			foreach my $constraintColumn ($constraint->getColumns()) {
				push(@columns,$this->_resolveColumnReference($constraintColumn));
			}
			# replace the list of SqlColumnReference with a list of SqlColumn
			$constraint->setColumns(@columns);
			
			# we resolve the reference in SqlColumnReference (SqlForeignKeyConstraint instances only)
			if($constraint->isSqlForeignKeyConstraint()) {
				$constraint->setReference($this->_resolveColumnReference($constraint->getReference()));
			}
		}
	}
}

sub resolveAllLinks {
	my ($this) = @_;
	$this->_resolveInheritedTables();
	$this->_resolveInvokedFunctions();
	$this->_resolveInvokedFunctionsByTriggers();
	$this->_resolveUsedTablesByTriggers();
	$this->_resolveConstraints();
}

1;