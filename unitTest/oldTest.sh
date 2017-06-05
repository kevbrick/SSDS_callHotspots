## Ensure that we've cleaned up first
rm -rf $SSDSGENOMESPATH/CHStestGenome/
rm $CHSPATH/unitTest/output/treatment/*
rm $CHSPATH/unitTest/output/control/*
rm $CHSPATH/unitTest/output/hotspots/*

## Add the test genome
perl $SSDSPIPELINEPATH/addGenome.pl \
 --fa $CHSPATH/unitTest/CHSdemoRegion.fasta \
 --name CHStestGenome \
 --g ctg \
 --s MusMusculusChr19_3000001_33000000 \
 >$CHSPATH/unitTest/runTest.o \
 2>$CHSPATH/unitTest/runTest.e

if [ -f $SSDSGENOMESPATH/testGenome/BWAIndex/version0.7.10/genome.fa.bwt ]; then
    echo "Test genome was added and indexed successfully !!"
else
	echo "**** FAIL **** Test genome was NOT added correctly !!" 
	exit
fi

## TEST 1: Align Treatment reads
$SSDSPIPELINEPATH/run_ssDNAPipeline \
 --g CHStestGenome \
 --n 1 \
 --fq1 $CHSPATH/unitTest/dmc1SSDS_CHSdemo.R1.fastq.gz \
 --fq2 $CHSPATH/unitTest/dmc1SSDS_CHSdemo.R2.fastq.gz \
 --sample treatment \
 --splitSz 10000 \
 --lane 99 \
 --date 311215 \
 --outdir $CHSPATH/unitTest/output/treatment \
 >>$CHSPATH/unitTest/runTest.o \
 2>>$CHSPATH/unitTest/runTest.e

if [ -f $CHSPATH/unitTest/output/treatment/dmc1SSDS_CHSdemo.chstestgenome.ssPipeline.done ]; then
    echo "SSDS pipeline for Treatment data successful !!"
else
	echo "**** FAIL **** SSDS pipeline for treatment did not run correctly !!" 
	exit
fi

## TEST 2: Align Control reads
$SSDSPIPELINEPATH/run_ssDNAPipeline \
 --g CHStestGenome \
 --n 1 \
 --fq1 $CHSPATH/unitTest/IgG_SSDS_CHSdemo.R1.fastq.gz \
 --fq2 $CHSPATH/unitTest/IgG_SSDS_CHSdemo.R2.fastq.gz \
 --sample control \
 --splitSz 10000 \
 --lane 99 \
 --date 311215 \
 --outdir $CHSPATH/unitTest/output/treatment \
 >>$CHSPATH/unitTest/runTest.o \
 2>>$CHSPATH/unitTest/runTest.e

if [ -f $CHSPATH/unitTest/output/control/IgG_SSDS_CHSdemo.chstestgenome.ssPipeline.done ]; then
    echo "SSDS pipeline for Control data successful !!"
else
	echo "**** FAIL **** SSDS pipeline for control did not run correctly !!" 
	exit
fi

$CHSPATH/run_callHotspotsPipeline \
 --t $CHSPATH/unitTest/output/treatment/dmc1SSDS_CHSdemo.chstestgenome.ssDNA_type1.bed \
 --c $CHSPATH/unitTest/output/control/IgG_SSDS_CHSdemo.chstestgenome.ssDNA_type1.bed \
 --gSz 3e6 \
 --name callHotspotsTest \
 --out $CHSPATH/unitTest/output/hotspots
