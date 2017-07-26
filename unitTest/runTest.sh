#!/bin/bash

initDir=`pwd`

echo '## SSDS CALL HOTSPOTS PIPELINE PATHS ... '
echo $CHSPATH' ... OK CHS PIPELINE PATH?'
echo $CHSNCISPATH' ... OK CHS NCIS PATH?'
echo $CHSBEDTOOLSPATH' ... OK CHS BEDTOOLS PATH?'
echo $CHSTMPPATH' ... OK CHS TMP PATH?'
echo $CHSMACSPATH' ... OK CHS MACS PATH?'
echo $PERL5LIB' ... OK PERL PATH?'
echo $PYTHONPATH' ... OK PYTHON PATH?'

cd $CHSPATH/unitTest

mkdir $CHSPATH/unitTest/output 2>/dev/null
rm $CHSPATH/unitTest/output/* 2>/dev/null

$CHSPATH/run_callHotspotsPipeline \
 --t $CHSPATH/unitTest/dmc1SSDS_CHSdemo.chstestgenome.ssDNA_type1.bed \
 --c $CHSPATH/unitTest/IgG_SSDS_CHSdemo.chstestgenome.ssDNA_type1.bed \
 --gSz 30000000 \
 --name callHotspotsTest \
 --out $CHSPATH/unitTest/output

if [ `wc -l <$CHSPATH/unitTest/output/callHotspotsTest_peaks.bedgraph` -ge 100 ]; then
    echo "Hotspots called successfully !!"  
else
	echo "**** FAIL **** Something went wrong !!"  
	cat runTest.e
	cd $initDir
	exit 99
fi

cd $initDir
