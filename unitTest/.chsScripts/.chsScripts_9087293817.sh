#!/bin/bash
sort -k1,1 -k2n,2n -k3n,3n -k4,4 -k5,5 -k6,6 -T /tmp/ /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/treatment/dmc1SSDS_CHSdemo.testgenome.ssDNA_type1.bed |uniq >/tmp/dmc1SSDS_CHSdemo.testgenome.ssDNA_type1.uniq.bed
sort -k1,1 -k2n,2n -k3n,3n -k4,4 -k5,5 -k6,6 -T /tmp/ /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/control/IgG_SSDS_CHSdemo.testgenome.ssDNA_type1.bed |uniq >/tmp/IgG_SSDS_CHSdemo.testgenome.ssDNA_type1.uniq.bed
R --vanilla </tmp//SSDSpl_tmp_16406680324/CHS_NCIS_547412655121785.R
ratio=`perl /home/kevbrick/data/SSDS_Pipeline/callPeaks/git//getNCISratio.pl /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/treatment/dmc1SSDS_CHSdemo.testgenome.ssDNA_type1.NCISout`
python /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/macs2.1.0.20150420/bin//macs2 callpeak --ratio $ratio -g .02 -t /tmp/dmc1SSDS_CHSdemo.testgenome.ssDNA_type1.uniq.bed -c /tmp/IgG_SSDS_CHSdemo.testgenome.ssDNA_type1.uniq.bed --bw 1000 --keep-dup all --slocal 5000 --name /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/hotspots/callHotspotsTest >/home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/hotspots/callHotspotsTest.macs2callpeak.170602_183144.OUT 2>/home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/hotspots/callHotspotsTest.macs2callpeak.170602_183144.ERR
cut -f1-3 /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/hotspots/callHotspotsTest_peaks.narrowPeak |grep -v ^M |grep -v chrM |sort -k1,1 -k2n,2n >/home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/hotspots/callHotspotsTest_peaks.bed
perl /home/kevbrick/data/SSDS_Pipeline/callPeaks/git//calcStrengthAndRecenterHotspots.pl --hs /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/hotspots/callHotspotsTest_peaks.bed --frag /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/treatment/dmc1SSDS_CHSdemo.testgenome.ssDNA_type1.bed --v --out /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/hotspots/callHotspotsTest_peaks.bedgraph 
