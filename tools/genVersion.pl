#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

my $filename = 'extract.pl';

my $version = '';
my $datetime = '';
my $content = '';

open(VERSION, '<version.txt') or die "Could not open file 'version.txt' $!";
while (my $row = <VERSION>) {
	$version = $version . $row;
}
close(VERSION);

open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";
while (my $row = <$fh>) {
	$content = $content . $row;
}
close($fh);

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$version = sprintf("%02d%02d%02d",($year + 1900),($mon + 1),$mday);
$datetime = sprintf("%02d%02d%02d",$hour, $min, $sec);

$content =~ s/<VERSION>/$version/;
$content =~ s/<DATETIME>/$datetime/;

open(FD,'>',$filename) or die("Can't write '$filename' $!");
print(FD $content);
close(FD);
