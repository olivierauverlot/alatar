package PgKeywords;

use Data::Dumper;
use strict;

my @keywords = ('IF','WHILE');

# return TRUE if the word is not a PostgreSQL keyword
sub isNotKeyword {
	my ($this,$word) = @_;
	return !(grep {$_ eq $word} @keywords)
}

1;