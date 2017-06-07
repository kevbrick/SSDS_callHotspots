#!/bin/bash

RUNDIR=`pwd`

TSTFILE=$RUNDIR'/run_callHotspotsPipeline'

if [ -f $TSTFILE ]; then
   echo "OK ... configuring SSDS call hotspots pipleine ..."
else
   echo "** ERROR **"
   echo "Cannot execute config script from $RUNDIR"
   echo "Please run configure.sh from the call hotspots pipeline folder."
   echo "This folder contains the run_callHotspotsPipeline script."
   exit
fi

## Get packages
apt-get install -y r-base-core libxml2-dev libcurl4-openssl-dev python-setuptools python-pip
 
## Get R packages
echo 'install.packages(“RCurl”)' >Rconf.R
echo 'install.packages(“XML”)' >>Rconf.R
echo 'source("https://bioconductor.org/biocLite.R")' >>Rconf.R
echo 'biocLite("rtracklayer")' >>Rconf.R
echo 'biocLite("ShortRead")' >>Rconf.R

R --vanilla <Rconf.R 

## Get perl modules
cpan File::Temp
cpan Getopt::Long
cpan Math::Round
cpan Statistics::Descriptive
cpan List::Util

## Add environment vars to .bashrc
echo ' ' >>~/.bashrc
echo '## VARIABLES FOR callHotspots SSDS pipeline' >>~/.bashrc
echo 'export CHSPATH=$RUNDIR' >>~/.bashrc
echo 'export CHSNCISPATH=$CHSPATH/NCIS' >>~/.bashrc
echo 'export CHSBEDTOOLSPATH=$CHSPATH/bedtools' >>~/.bashrc
echo 'export CHSTMPPATH=/tmp' >>~/.bashrc
echo 'export PERL5LIB=$PERL5LIB:$CHSPATH' >>~/.bashrc

## Get MACS
pip install --root="--prefix="$RUNDIR"/macs2" -U MACS2==2.1.0.20150731
MACSfolder=`find -name 'site-packages' |perl -pi -e 's/^./$ENV{CHSPATH}/e'`
echo 'export CHSMACSPATH='$MACSfolder >>~/.bashrc 

source ~/.bashrc
