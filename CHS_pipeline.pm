package CHS_pipeline;

use strict;
use warnings;

use File::Temp qw/ tempfile tempdir /;
use Getopt::Long;

require Exporter;

our @ISA = qw(Exporter);

# EXPORTING FUNCTION NAMES ##
our %EXPORT_TAGS = ( 'all' => [ qw() ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    genTempFile
    genPaths
    sysAndPrint
    getPWD
    fnDateTime
    csSort
    chromosomeSortFunction
);

our $VERSION = '0.01';

################################################################################
######################## START OF MODULE METHODS ###############################
################################################################################


#####################################################################################################
# genTempFile.pl - make a temp file 
sub genTempFile{
	my ($t,$tmpdir) = @_;

	$tmpdir = $tmpdir?$tmpdir:$ENV{SSDSTMPPATH}.'/CHSpl_r'.(int(rand()*1000000000000));

	system("mkdir $tmpdir");

	my $template = (($tmpdir eq '.')?'':$tmpdir.'/').(defined($t)?$t:'tmp_CHSpl_XXXXXXXXX');
	my ($fh, $clNm) = tempfile($template);

	return ($clNm,$tmpdir,$fh);
}

#####################################################################################################
# genPaths.pl - generate data file paths for ssDNA pipeline
sub genPaths{
	
	my $randomName      = 'SSDSpl_tmp_'.int(rand()*100000000000);
	my $chsPath  		= $ENV{'CHSPATH'};			$chsPath 		=~ s/^(.+[^\/])$/$1\//;
	my $bedtoolsPath  	= $ENV{'CHSBEDTOOLSPATH'};	$bedtoolsPath  	=~ s/^(.+[^\/])$/$1\//;
	my $macsPath 		= $ENV{'CHSMACSPATH'};		$macsPath 		=~ s/^(.+[^\/])$/$1\//;
	my $ncisPath    	= $ENV{'CHSNCISPATH'};		$ncisPath   	=~ s/^(.+[^\/])$/$1\//; 
	my $tmpPath     	= $ENV{'CHSTMPPATH'}.'/'.$randomName;
	
	sysAndPrint('mkdir '.$tmpPath,1,0);
	
	die ("\n## ERROR ##\nCHSPATH environment variable NOT set. \n") if (not ($chsPath));
	die ("\n## ERROR ##\nInvalid CHSPATH environment variable ($chsPath) \n") if (not (-e ($chsPath.'/CHS_pipeline.pm')));
	
	die ("\n## ERROR ##\nCHSBEDTOOLSPATH environment variable NOT set. \n") if (not ($bedtoolsPath));
	die ("\n## ERROR ##\nInvalid CHSBEDTOOLSPATH environment variable ($bedtoolsPath) \n") if (not (-e ($bedtoolsPath.'/bedtools')));

	die ("\n## ERROR ##\nCHSMACSPATH environment variable NOT set. \n") if (not ($macsPath));
	die ("\n## ERROR ##\nInvalid CHSMACSPATH environment variable ($macsPath) \n") if (not (-e ($macsPath.'/macs2')));
	
	die ("\n## ERROR ##\nCHSNCISPATH environment variable NOT set. \n") if (not ($ncisPath));
	die ("\n## ERROR ##\nInvalid CHSNCISPATH environment variable ($ncisPath) \n") if (not (-e ($ncisPath.'/1471-2105-13-199-s2.pdf')));
	
	die ("\n## ERROR ##\nCHSTMPPATH environment variable NOT set. \n") if (not ($tmpPath));
	die ("\n## ERROR ##\nInvalid CHSTMPPATH environment variable ($tmpPath) \n") if (not (-d ($tmpPath)));
	
	die ("\n## ERROR ##\nCHSTMPPATH folder not created ($tmpPath) \n") if (not (-d ($tmpPath)));
		
	return ($chsPath,$bedtoolsPath,$macsPath,$ncisPath,$tmpPath);
}

################################################################################
sub sysAndPrint {
	my ($cmd,$printMe,$noRun) = @_;
	print STDERR "$cmd\n" if ($printMe);
	system($cmd) unless ($noRun);
}

################################################################################
sub getPWD {
	my $PWD = `pwd`;
	chomp $PWD;
	$PWD =~ s/\s//g;
	return $PWD;
}

################################################################################
sub fnDateTime{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year += 1900;
	$year =~ s/\d\d(\d\d)/$1/;
	$mon+=1;
	$mon = "0$mon" if (length($mon) == 1);
	$mday = "0$mday" if (length($mday) == 1);

	return ($year.$mon.$mday.'_'.$hour.$min.$sec);
}

####################################################################
sub csSort {
    my @toSort = @_;

    my @noRandSort;
    for my $tsC(@toSort){
        next unless ($tsC =~ /^chr(\d+|X|Y)$/);
        push @noRandSort, $tsC;
    }

    my @aSorted = sort chromosomeSortFunction @noRandSort;

    return @aSorted;
}

####################################################################
sub chromosomeSortFunction {
  # sort chromosomes

  my ($valA,$valB) = ($a,$b);

  $valA =~ s/chrX/chr200/;
  $valA =~ s/chrY/chr201/;
  $valA =~ s/chrM/chr202/;
  $valA =~ s/chr(\d+)_random/"chr".($1+300)/e;

  $valB =~ s/chrX/chr200/;
  $valB =~ s/chrY/chr201/;
  $valB =~ s/chrM/chr202/;
  $valB =~ s/chr(\d+)_random/"chr".($1+300)/e;

  # Extract the digits following the first comma
  $valA =~ s/chr(\d+)/$1/;
  $valB =~ s/chr(\d+)/$1/;

  # Extract the letter following those digits
  #$valA =~ s/chr(A-Z)/$1/e unless ($valA);
  #$valB =~ s/chr(A-Z)/$1/e unless ($valB);

  # Compare and return
  return $valA <=> $valB;
}
