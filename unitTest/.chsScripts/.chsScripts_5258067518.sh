#!/bin/bash
sort -k1,1 -k2n,2n -k3n,3n -k4,4 -k5,5 -k6,6 -T /tmp/ /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/treatment/dmc1SSDS_CHSdemo.testgenome.ssDNA_type1.bed |uniq >/tmp/dmc1SSDS_CHSdemo.testgenome.ssDNA_type1.uniq.bed
sort -k1,1 -k2n,2n -k3n,3n -k4,4 -k5,5 -k6,6 -T /tmp/ /home/kevbrick/data/SSDS_Pipeline/callPeaks/git/unitTest/output/control/IgG_SSDS_CHSdemo.testgenome.ssDNA_type1.bed |uniq >/tmp/IgG_SSDS_CHSdemo.testgenome.ssDNA_type1.uniq.bed
R --vanilla </tmp//SSDSpl_tmp_66652758939/CHS_NCIS_845642097099823.R
