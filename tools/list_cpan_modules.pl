#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

my $body = <<'BODY';
# This script installs CPAN dependencies
# --------------------------------------------------
/usr/bin/env perl -MCPAN -e 'install App::cpanminus'
cpanm PAR::Packer
cpanm Test::Harness
BODY

my %modules;
my %rejectedModules = map { $_ => 1 } ('strict','warnings','utf8','Configuration');

sub readFile {
	my ($filename) = @_;
	my $data = '';		
	open(DATA,$filename) || die "You must specify a filename";
	while( defined( my $l = <DATA> ) ) {
   		$data = $data . $l;
	}
	close(DATA);
	return $data;
}
	
sub extractModulesFrom {
	my ($program) = @_;
	my @mods = $program =~ /use\s(.*?);/gi;
	for(my $i=0;$i < @mods;$i++) {
		if(!($mods[$i] =~ /Sql(.*?)/ || $mods[$i] =~ /Pg(.*?)/)) {
			my @m = split(/\s/,$mods[$i]);
			if(!exists($rejectedModules{$m[0]})) {
				$modules{$m[0]} = 1;
			}
		}
	}
}

extractModulesFrom(readFile('extract.pl'));

opendir DIR, ".";
my @files = grep { $_ ne '.' && $_ ne '..' && $_ =~ /(.*?).pm/ } readdir DIR;
closedir DIR;
foreach my $file (@files) {
	extractModulesFrom(readFile($file));
}

my @mods = keys(%modules);

foreach my $m (keys(%modules)) {
	$body = $body . 'cpanm ' . $m . "\n";
};

open (FILE, ">/tmp/install_cpan_modules.sh") || die ("Can't write the file");
print FILE $body;
close (FILE);
