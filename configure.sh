#!/bin/bash

RUNDIR=`pwd`
FLDNAME=`basename $RUNDIR`

cp -r $RUNDIR /usr/share || exit 1

RUNDIR='/usr/share/'$FLDNAME

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
apt-get install -y r-base-core libxml2-dev libcurl4-openssl-dev python-setuptools python-pip  python-numpy python-scipy || exit 1
 
## Get R packages
echo 'if (!require("RCurl")){install.packages("RCurl", repos="http://cran.rstudio.com")}' >$RUNDIR/Rconf.R || exit 1
echo 'if (!require("XML")){install.packages("XML", repos="http://cran.rstudio.com")}' >>$RUNDIR/Rconf.R || exit 1
echo 'source("https://bioconductor.org/biocLite.R")' >>$RUNDIR/Rconf.R || exit 1
echo 'if (!require("rtracklayer")){biocLite("rtracklayer")}' >>$RUNDIR/Rconf.R || exit 1
echo 'if (!require("ShortRead")){biocLite("ShortRead")}' >>$RUNDIR/Rconf.R || exit 1

R --vanilla <$RUNDIR/Rconf.R || exit 1

## Get perl modules
cpan File::Temp || exit 1
cpan Getopt::Long || exit 1
cpan Math::Round || exit 1
cpan Statistics::Descriptive || exit 1
cpan List::Util || exit 1

## Add environment vars to .bashrc
echo ' ' >>~/.bashrc || exit 1
echo '## VARIABLES FOR callHotspots SSDS pipeline' >>~/.bashrc || exit 1
echo 'export CHSPATH='$RUNDIR >>~/.bashrc || exit 1
echo 'export CHSNCISPATH='$RUNDIR'/NCIS' >>~/.bashrc || exit 1
echo 'export CHSBEDTOOLSPATH='$RUNDIR'/bedtools' >>~/.bashrc || exit 1
echo 'export CHSTMPPATH=/tmp' >>~/.bashrc || exit 1
echo 'export PERL5LIB=$PERL5LIB:'$RUNDIR >>~/.bashrc || exit 1

## Get MACS
#pip install --root=$RUNDIR"/macs_2.1.0.20150731" -U MACS2==2.1.0.20150731 || exit 1
MACSBINfolder=`find $RUNDIR -name 'macs2'` 
MACSLIBfolder=`find $RUNDIR -name 'dist-packages'` 
echo 'export CHSMACSPATH='$MACSBINfolder >>~/.bashrc || exit 1
echo 'export PYTHONPATH='$MACSLIBfolder':'$PYTHONPATH >>~/.bashrc || exit 1

. ~/.bashrc || exit 1

echo "Configureation complete ... running unit tests ..."

sh $CHSPATH/unitTest/runTest.sh || exit 1

echo "Tests complete ..."
echo "callHotspots pipeline installed to "$CHSPATH
