#!/bin/bash

##################################################################################################
## Marion Patxot Bertran - MSc in Molecular Life Science (UNIL)					##
##												##
## Aim: loop bc_count.sh through all fastq files in BC folder				 	##
##												##
## USAGE: ./batch.sh INPUT_BC_COLLECTION FASTQ_HEADER QFILTER TRIMPOS TRIMSIZE WORDSIZE		##
##												##
## Version 2											##	
##################################################################################################

#USER ARGUMENTS

INPUT_BC_COLLECTION=$1  # file with list of barcodes i.e. barcodes.txt
FASTQ_HEADER=$2         #depends on sequencing machine used
QFILTER=$3              #1=passed quality filter only / 0=all reads
export TRIMPOS=$4       #extract bases from position TRIMPOS for TRIMSIZE bases
export TRIMSIZE=$5
WORDSIZE=$6             #look for WORDSIZE consecutive bases


###### EXCUTING SCRIPT BC_COUNT.SH FOR ALL FASTQ FILES ######

echo 'executing script for all fastq files'
echo 'IMPORTANT: fastq file must be in the directory where you are running the script'
echo 'INPUT_BC_COLLECTION:' $INPUT_BC_COLLECTION
echo 'FASTQ_HEADER:' $FASTQ_HEADER
echo 'QFILTER:' $QFILTER
echo 'TRIMPOS:' $TRIMPOS 'and TRIMSIZE:' $TRIMSIZE
echo 'WORDSIZE:' $WORDSIZE


for d in *.fastq;

do

echo 'processing:' $d

cp $d $d.copy

./bc_count.sh $d $INPUT_BC_COLLECTION $FASTQ_HEADER $QFILTER $TRIMPOS $TRIMSIZE $WORDSIZE > summary.txt

rm $d.copy

done

echo 'done'



