package Alatar::PostgreSQL::PgKeywords;

use Data::Dumper;
use strict;

my @keywords = (
	'ARRAY' , 'ASSERT' , 
	'BY' , 
	'CASE' , 'CONTINUE' , 
	'ELSE', 'ELSEIF' , 'END' , 'EXCEPTION' , 'EXIT' , 
	'FOR' , 'FOREACH' , 'FOUND', 
	'IF', 'IN' , 
	'LOOP' , 
	'NEXT' , 'NOT' , 'NOTICE' , 'NULL' , 
	'QUERY' , 
	'RAISE' , 'RETURN', 'REVERSE' , 
	'SLICE' , 
	'THEN' , 
	'WHEN','WHILE'
);

# return TRUE if the word is not a PostgreSQL keyword
sub isNotKeyword {
	my ($this,$word) = @_;
	return !(grep {$_ eq $word} @keywords)
}

1;

