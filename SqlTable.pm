package SqlTable;

use strict;
use SqlObject;
use SqlColumn;

our @ISA = qw(SqlObject);

sub new {
	my ($class,$owner,$code) = @_;
	my $this = $class->SUPER::new($owner,undef);
	my $this = {
		columns => []
	};
 	bless($this,$class);
 	$this->_extractColumnDefinitions($code);
 	return $this;            
}

# Actions
# ---------------------------------------------------------------
sub _extractColumnDefinitions {
	my ($this,$code) = @_;
}

1;
