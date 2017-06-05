#!/usr/bin/perl
use strict; 

## Input NCIS file name
my $nIn = $ARGV[0]; 
	
my $ncisR = `cat $nIn`;
$ncisR =~ s/^((\d|\.)+)\s.+$/$1/;
chomp $ncisR; 

## Output ratio
print $ncisR;

