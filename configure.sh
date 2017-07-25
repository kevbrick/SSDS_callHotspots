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

## Get MACS
pip install --root=$RUNDIR"/macs_2.1.0.20150731" -U MACS2==2.1.0.20150731 || exit 1
MACSBINfolder=`find $RUNDIR -name 'macs2' |perl -pi -e 's/\/macs2//'` 
MACSLIBfolder=`find $RUNDIR -name 'dist-packages'` 

## Add environment vars to .bashrc
for thisBASHRC in `find /home -maxdepth 2 -name '.bashrc'` '/root/.bashrc'; do
	echo ' ' >>$thisBASHRC || exit 1
	echo '## VARIABLES FOR callHotspots SSDS pipeline' >>$thisBASHRC || exit 1
	echo 'export CHSPATH='$RUNDIR >>$thisBASHRC || exit 1
	echo 'export CHSNCISPATH='$RUNDIR'/NCIS' >>$thisBASHRC || exit 1
	echo 'export CHSBEDTOOLSPATH='$RUNDIR'/bedtools' >>$thisBASHRC || exit 1
	echo 'export CHSTMPPATH=/tmp' >>$thisBASHRC || exit 1
	echo 'export PERL5LIB=$PERL5LIB:'$RUNDIR >>$thisBASHRC || exit 1
	echo 'export PATH=$PATH:'$RUNDIR >>$thisBASHRC || exit 1
	echo 'export CHSMACSPATH='$MACSBINfolder >>$thisBASHRC || exit 1
	echo 'export PYTHONPATH='$MACSLIBfolder':'$PYTHONPATH >>$thisBASHRC || exit 1	
done

export CHSPATH=$RUNDIR  || exit 1
export CHSNCISPATH=$RUNDIR'/NCIS' || exit 1
export CHSBEDTOOLSPATH=$RUNDIR'/bedtools' || exit 1
export CHSTMPPATH='/tmp' || exit 1
export PERL5LIB=$PERL5LIB':'$RUNDIR  || exit 1
export PATH=$PATH':'$RUNDIR || exit 1
export CHSMACSPATH=$MACSBINfolder || exit 1
export PYTHONPATH=$MACSLIBfolder':'$PYTHONPATH || exit 1

#sh $RUNDIR/.callSSDSPeaksPaths.sh
#. ~/.bashrc || exit 1

echo ''
echo $PYTHONPATH' ... OK?'
echo $CHSMACSPATH' ... OK?'
echo $CHSPATH' ... OK?'
echo ''
echo '-------------------------------------------------'
echo "Configuration complete ... running unit tests ..."
echo '-------------------------------------------------'

sh $RUNDIR\/unitTest/runTest.sh || exit 1

echo "Tests complete ..."
echo "callHotspots pipeline installed to "$CHSPATH
echo 'Restart computer or logout/login to use ..'
