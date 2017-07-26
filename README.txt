INSTALLATION:
The easiest way to install the SSDS hotspot calling pipeline is to simply run the configuration script located in the folder downloaded from github: 
>cd callHotspotsSSDS

On debian-based linux systems, the configure script will install the SSDS hotspot calling pipeline to /home/$USER/SSDS_callHotspots_1.0.0. 

To install the pipeline to the default locations:
>sudo ./configure.sh

Alternatively, you can specify the installation folder:
>sudo ./configure.sh -i /share/SSDS_callHotspots_1.0.0 

The configuration script will install all of the required dependencies and test the pipeline. 

If the configuration process successfully completes, the pipeline has been installed. Please skip sections A-D below. 

If the configuration process fails, please follow the manual instructions outlined in sections A-D below. These instructions also serve as a guide for users of other operating systems. 

MANUAL INSTALLATION: 
A.  ------------------------------------------------------------
Copy callHotspotsSSDS folder to desired location:

For the callHotspotsSSDS pipeline to be available for all users on a system, it is recommended to copy the entire contents of the callHotspotsSSDS folder to /usr/share:
>cp -r ./callHotspotsSSDS /usr/share

This is a recommended, but NOT a required step.

B. ------------------------------------------------------------
Install dependencies: 

The following programs are required to run the callHotspots pipeline: 
R (>version 2.10)
MACS (version 2.1.0.20150731)
pip

First, install bash libraries (root privileges required): 
>apt-get install -y r-base-core libxml2-dev libcurl4-openssl-dev python-setuptools python-pip  python-numpy python-scipy

To install R packages, start R from the command line: 
>R

From the R prompt, run:
>install.packages("RCurl", repos="http://cran.rstudio.com")
>install.packages("XML", repos="http://cran.rstudio.com")
>source("https://bioconductor.org/biocLite.R")
>biocLite("rtracklayer", repos="http://cran.rstudio.com")
>biocLite("ShortRead", repos="http://cran.rstudio.com")

MACS can be installed from the command line as follows (root access is required);
>sudo pip install --root=/XXX/YYY/callHotspotsSSDS/macs_2.1.0.20150731 -U MACS2==2.1.0.20150731

The following perl packages are required for the callHotspots pipeline: 

File::Temp
Getopt::Long
List::Util
Math::Round
Statistics::Descriptive

Install perl modules as follows (root privileges required):
>export PERL_MM_USE_DEFAULT=1
>sudo cpan File::Temp
>sudo cpan Getopt::Long
>sudo cpan Math::Round
>sudo cpan Statistics::Descriptive
>sudo cpan List::Util

C. ------------------------------------------------------------
Set environment variables:

CHSPATH : location of pipeline
CHSNCISPATH : path to NCIS R script (recommend: $CHSPATH/NCIS)
CHSBEDTOOLSPATH : path to bedtools binaries (recommend: $CHSPATH/bedtools)
CHSTMPPATH : temporary folder location
PERL5LIB : $CHSPATH must be added to the perl path
CHSMACSPATH : path to macs2 binary 
PYTHONPATH : path to macs2 python libraries must be added 

It is best to define these environment variables in the bash configuration file (~/.bashrc) for each user. /XXX/YYY/ is a placeholder for the installation path of the callHotspotsSSDS folder (i.e. /usr/share/). 

Add the following lines: 
export CHSPATH=/XXX/YYY/callHotspotsSSDS
export CHSNCISPATH=/XXX/YYY/callHotspotsSSDS/NCIS
export CHSBEDTOOLSPATH=/XXX/YYY/callHotspotsSSDS/bedtools
export CHSTMPPATH=/tmp
export PERL5LIB=$PERL5LIB:/XXX/YYY/callHotspotsSSDS
export PATH=$PATH:/XXX/YYY/callHotspotsSSDS
export CHSMACSPATH=/XXX/YYY/callHotspotsSSDS/macs2.1.0.20150731/
                   usr/local/bin
export PYTHONPATH=$PYTHONPATH:/XXX/YYY/callHotspotsSSDS/ 
                              macs2.1.0.20150731/usr/local/lib/
                              python2.7/dist-packages

Initialize these variables from .bashrc:
>source ~/.bashrc

D.  ------------------------------------------------------------
Run the unit tests to ensure that the pipeline works:

This will test the hotspot calling and strength estimation scripts using test data. This test performs peak calling in a 30 Mb region.

>cd $CHSPATH/unitTest/
>sh runTest.sh

Successful completion of the tests will result in the following output: 

Success !! Hotspot calling complete. 

The CHS pipeline has been installed successfully and can be run.

INSTALLATION NOTES:
Specific versions of MACS, bedtools and NCIS are included in the callHotspots pipeline repository. We recommend using these versions as other versions may not be compatible. Expert users can tweak the pipeline scripts to use different versions of these programs if desired.

========================================================================================================================
RUNNING THE SSDS CALL HOTSPOTS PIPELINE:
Calling hotspots:

To identify the locations of DSB hotspots from a DMC1-SSDS experiment, we compare a treatment and control experiment. This requires: 

ssDNA_type_1 fragments BED file from DMC1-SSDS experiment
ssDNA_type_1 fragments BED file from an input/IgG-SSDS experiment

The peak calling pipeline is run using the following syntax:

>$CHSPATH/run_callHotspotsPipeline \
 --t {BED file : type 1 ssDNA from dmc1 experiment} \
 --c {BED file : type 1 ssDNA from input/IgG experiment} \
 --gSz {estimated size of mappable genome} \
 --name {prefix for output file names} \
 --out {output folder}

The arguments for the hotspot calling pipeline can be accessed from the command line:

>$CHSPATH/run_callHotspotsPipeline -h

Alternatively, they are listed below. 

ARG          Synopsis (* = required)                           Detail
--t          *Treatment BED file                               Type 1 ssDNA BED file
--c          *Control BED file                                 Type 1 ssDNA BED file
--gSz        *Effective genome size                            Estimated size of mappable genome
--gName      (can be used instead of --gSz)                    *Genome/species name
                                                               Use pre-computed effective genome size
                                                               For human : hg19  | hg38 | hg | hs | human
                                                               For mouse : mm9 | mm10 | mm | mouse
                                                               For rat : rn | rat
--name       *Name prefix for output files
--out        Output folder                                     Default = current folder
--blist      Blacklist file                                    BED file of genomic regions with sequencing biases that result in spurious peak calls
                                                               i.e. for mouse (mm10 genome): 
                                                                    $CHSPATH/mm10_hotspot_blacklist.bed
--tuniq      Treatment BED file with ONLY unique fragments     Optional, but not recommended
--cuniq      Control BED file with ONLY unique fragments       Optional, but not recommended
--debug      DEBUG mode                                        Builds scripts but does not execute. 
                                                               This is a logical argument, so does not take any value (pass as --debug)
--q30        Q30 mode                                          Use only fragments where both reads have a q-score >= 30. This is useful for removing reads that map with low confidence (i.e. to high copy repeats). 
                                                               This is a logical argument, so does not take any value (pass as --q30)
--nc         Do not call peaks                                 Do not run peak calling.
                                                               This is a logical argument, so does not take any value (pass as --debug)
--h/help     Show help                                         

OUTPUT FILES: 
The hotspot calling pipeline generates output files of DSB hotspot locations. 

filename                                 detail
$name_peaks.bedgraph                     Recentered hotspots with strength estimate (BEDGRAPH file)
                                          Column 1: chromosome
                                          Column 2: hotspot start
                                          Column 3: hotspot end
                                          Column 4: hotspot strength
$name_peaks.tab                          Recentered hotspots table:
                                          Column 1: chromosome
                                          Column 2: hotspot start
                                          Column 3: hotspot end
                                          Column 4: hotspot strength
                                          Column 5: strength as percentage of total
                                          Column 6: strength as rank
                                          Column 7: signal fragments 
                                          Column 8: noise fragments

The pipeline will also output other files that should only be used for debugging purposes:

filename                                 detail
$name.NCISout                            NCIS output: Treatment:Control ratios
$name_model.r                            MACS output: R script to visualize MACS peak model for these data
$name_peaks.xls                          MACS output: raw peak calls (Excel file)
$name_summits.bed                        MACS output: raw peak summits (BED file)
$name_peaks.narrowPeak                   MACS output: raw peak calls (BED file)
$name_peaks.bed                          MACS output: raw peak calls (BED file)
$name.macs2callpeak.YYMMDD_NNNNN.OUT     STDOUT from MACS peak calling 
$name.macs2callpeak.YYMMDD_NNNNN.ERR     STDERR from MACS peak calling



