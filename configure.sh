#!/bin/bash

## Ensure that sudo is used, not su
if [ "`whoami`" = "root" ] && [ -z "$SUDO_USER" ]
then
	echo '##########################################'
	echo "## ERROR ##"
	echo "Please run configure.sh using sudo, not su"
	echo '##########################################'
	exit 1
fi

if [ "`whoami`" != "root" ]
then
	echo '##################################'
	echo "## ERROR ##"
	echo "Please run configure.sh using sudo"
	echo '##################################'
	exit 1
fi

## Define default path	
INSTALLPATH='/home/'$SUDO_USER'/SSDS_callHotspots_1.0.0/'

## Check args
while [[ $# -gt 1 ]]
	do
	key="$1"

	case $key in
		-i|--install_dir)
		INSTALLPATH="$2"
		shift # past argument
		;;
		*)
		# unknown option
		;;
	esac
	
	shift # past argument or value
	
done

echo INSTALL PATH    = "${INSTALLPATH}"

installParentDir="$(dirname "$INSTALLPATH")"
iOwner=`ls -ld $installParentDir |awk '{print $3}'`

if [ "$iOwner" = "root" ]
then
	echo "##### WARNING ##### : Installation folder ["$INSTALLPATH"] is only writable by root user"
	sleep 3
fi	

mkdir -p $INSTALLPATH || exit 1
chmod a+rw $INSTALLPATH || exit 1

######################## DONE ARGS ######################

## Copy git folder to install location
RUNDIR=`pwd`
FLDNAME=`basename $RUNDIR`

# Check start dir
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

cp -r $RUNDIR/* $INSTALLPATH || exit 1

if [ "$iOwner" != "root" ]
then
	chown -R $SUDO_USER $INSTALLPATH || exit 1
fi


# Check install dir 
RUNDIR=$INSTALLPATH
TSTFILE=$RUNDIR'/run_callHotspotsPipeline'

if [ -f $TSTFILE ]; then
   echo "OK ... configuring SSDS call hotspots pipeline ..."
else
   echo "** ERROR **"
   echo "Cannot execute config script from $RUNDIR"
   echo "Please ensure that the installation folder ["$INSTALLPATH"]can be created."
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
	cp $thisBASHRC $thisBASHRC\.SSDSCHSpipeline.bak || exit 1
	
	grep -vP '##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' $thisBASHRC\.SSDSCHSpipeline.bak >$thisBASHRC ||exit 1
	
	echo '##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export CHSPATH='$RUNDIR' ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export CHSNCISPATH='$RUNDIR'/NCIS ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export CHSBEDTOOLSPATH='$RUNDIR'/bedtools ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export CHSTMPPATH=/tmp ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export PERL5LIB=$PERL5LIB:'$RUNDIR' ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export PATH=$PATH:'$RUNDIR' ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export CHSMACSPATH='$MACSBINfolder' ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1
	echo 'export PYTHONPATH='$MACSLIBfolder':'$PYTHONPATH' ##SSDS_CHS_PIPELINE_ENVIRONMENT_VARS' >>$thisBASHRC || exit 1	
done

export CHSPATH=$RUNDIR  || exit 1
export CHSNCISPATH=$RUNDIR'/NCIS' || exit 1
export CHSBEDTOOLSPATH=$RUNDIR'/bedtools' || exit 1
export CHSTMPPATH='/tmp' || exit 1
export PERL5LIB=$PERL5LIB':'$RUNDIR  || exit 1
export PATH=$PATH':'$RUNDIR || exit 1
export CHSMACSPATH=$MACSBINfolder || exit 1
export PYTHONPATH=$MACSLIBfolder':'$PYTHONPATH || exit 1

echo ''
echo $PYTHONPATH' ... OK?'
echo $CHSMACSPATH' ... OK?'
echo $CHSPATH' ... OK?'
echo ''
echo '-------------------------------------------------'
echo "Configuration complete ... running unit tests ..."
echo '-------------------------------------------------'

resetOwnership () {
	# Reset all ownership to current user
	# unless installed to admin location
	if [ "$1" != "root" ]
	then
		chown -R $SUDO_USER $2 || exit 1
		chgrp -R $SUDO_GID $2 || exit 1
	fi
}

resetOwnership $iOwner $INSTALLPATH 

## Run tests
su $SUDO_USER -c 'sh $CHSPATH/unitTest/runTest.sh  ' || exit 1

## Give the ALL OK !!
echo "Tests complete ..."
echo "callHotspots pipeline installed to "$CHSPATH
echo 'Restart computer or logout/login to use ..'
