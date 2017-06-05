mkdir $CHSPATH/unitTest/output 2>/dev/null
rm $CHSPATH/unitTest/output/* 2>/dev/null

$CHSPATH/run_callHotspotsPipeline \
 --t $CHSPATH/unitTest/dmc1SSDS_CHSdemo.chstestgenome.ssDNA_type1.bed \
 --c $CHSPATH/unitTest/IgG_SSDS_CHSdemo.chstestgenome.ssDNA_type1.bed \
 --gSz 30000000 \
 --name callHotspotsTest \
 --out $CHSPATH/unitTest/output


if [ -f $CHSPATH/unitTest/output/callHotspotsTest_peaks.bedgraph ]; then
    echo "Hotspots called successfully !!"  
else
	echo "**** FAIL **** Something went wrong !!"  
	exit
fi
