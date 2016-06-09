package SqlResolver;

use Data::Dumper;

use SqlFunction;
use SqlFunctionInvocation;
use strict;

sub new {
	my ($class,$owner) = @_;
	my $this = {
		owner => $owner
	};
 	bless($this,$class);      
 	return $this;            
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

sub resolveAllLinks {
	my ($this) = @_;
	$this->_resolveInvokedFunctions();
	$this->_resolveInvokedFunctionsByTriggers();
}

1;