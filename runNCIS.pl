#!/usr/bin/perl
use strict;
use File::Temp qw/ tempfile tempdir /;
use List::Util qw/max min/;
use Getopt::Long;
use Statistics::Descriptive;
use Math::Round;
use CHS_pipeline qw/ genPaths sysAndPrint/;

GetOptions ('t=s' 	  => \(my $treat),
            'c=s'  	  => \(my $input),
            'nd+'  	  => \(my $noDuplicates),
			'sname=s' => \(my $NCISscript),
			'out=s'	  => \(my $NCISout));

my ($CHSPATH,$CHSBEDTOOLSPATH,$CHSMACSPATH,$CHSNCISPATH,$tmpDir) = CHS_pipeline::genPaths();

my ($treatFile,$inputFile) = ($treat,$input);

my $tf = "$tmpDir\/NCIS_KB_".(int(rand()*1000000000000000)).".R";

$NCISscript = $tf 				unless 	($NCISscript);
$NCISscript = $NCISscript.'.R'  if 		($NCISscript !~ /\.R/);

open OUT, '>', $NCISscript;

print OUT 'library("NCIS", lib.loc="'.$CHSNCISPATH.'")'."\n";
print OUT 'library(\'rtracklayer\')'."\n";
print OUT 'library("ShortRead")'."\n";
print OUT 'res <- NCIS("'.$treatFile.'","'.$inputFile.'","BED")'."\n";
print OUT 'write(paste(res$est,res$pi0,res$binsize.est,res$r.seq.depth,sep = "\t"), "'.$NCISout.'", sep = "\t")'."\n";

close OUT;

system('module load R');
system('R --vanilla <'.$NCISscript);
system("rm $tf") if (-e $tf);
