#!/bin/bash

##################################################################################################################################
## Marion Patxot Bertran - MSc in Molecular Life Science (UNIL)									##
##																##
## Aim: count the occurence of each known barcode in fastq file 								##
##																##
## USAGE : ./bc_count.sh INPUT_FQ_FILENAME INPUT_BC_COLLECTION FASTQ_HEADER QFILTER TRIMPOS TRIMSIZE WORDSIZE > summary.txt	##
##																##
## Version 6															##
##################################################################################################################################


#DEPENDENCIES
export PATH=$PATH:~/blast-2.2.26/bin


#USER ARGUMENTS
INPUT_FQ_FILENAME=$1  	# fastq file to process i.e. 211_L1_R1_001_RqTpNmGOyueX.fastq
INPUT_BC_COLLECTION=$2 	# file with list of barcodes i.e. barcodes.txt
FASTQ_HEADER=$3		#depends on sequencing machine used
QFILTER=$4              #1=passed quality filter only / 0=all reads
export TRIMPOS=$5       #extract bases from position TRIMPOS for TRIMSIZE bases
export TRIMSIZE=$6
WORDSIZE=$7		#look for WORDSIZE consecutive bases 


#EXAMPLE OF PARAMETERS TO BE SET BY USER
## INPUT_FQ_FILENAME=211_L1_R1_001_RqTpNmGOyueX.fastq	
## INPUT_BC_COLLECTION=barcodes.txt
## FASTQ_HEADER="\@TWEETY" - header of our fastq file
## QFILTER="1" - select reads that passed the standard quality filter
## export TRIMPOS=40 - extract bases from position 40 for 100 bases
## export TRIMSIZE=100			
## WORDSIZE=25 - look for 25 consecutive bases [allow 15 mismatches over 40 bases for example]

## COMMAND LINE: ./bc_counts 211_L1_R1_001_RqTpNmGOyueX.fastq barcodes.txt \@TWEETY 1 40 100 25 > summary.txt 


###### START OF PIPELINE


###### FASTQ SUMMARY (displays counts from the fastq file i.e. number of passed quality filter reads) ######


echo -n "number of total reads in fastq file: "
grep -c $FASTQ_HEADER $INPUT_FQ_FILENAME


echo

echo -n "number of passed filter reads in fastq file: "
grep $FASTQ_HEADER $INPUT_FQ_FILENAME | grep -c "1:N:"

echo


echo -n "number of filtered out reads in fastq file: "
grep $FASTQ_HEADER $INPUT_FQ_FILENAME | grep -c "1:Y:"


echo



###### CONVERTING FILE MAC/WINDOWS TO UNIX ######


echo -n "Convert MacOS text file to Unix text file..."

BC_UNIX_FILE="unix_bc.txt"

tr '\r' '\n' < $INPUT_BC_COLLECTION > $BC_UNIX_FILE


echo "DONE"


echo



###### CONVERTING BARCODE TEXT FILE AND FASTQ FILE TO FASTA FORMAT ######


echo -n "Formatting BC file..."


OUTPUT_BC_FILE="index_barcode.fa"
cut -f 1,2 $BC_UNIX_FILE | perl -ne '/(\w+)\s+(\w+)/ and print ">$1\n$2\n"' > $OUTPUT_BC_FILE 
formatdb -i $OUTPUT_BC_FILE -p F


echo "DONE"

echo



echo -n "Trimm and format fastq file to fasta... "


if [ $QFILTER == "1" ]; then

	perl -ne 'if(/(^\@.+\s\d:N:\d:\w+)/){$_=<>;print ">$1\n",substr($_,$ENV {'TRIMPOS'},$ENV{'TRIMSIZE'}),"\n"}' $INPUT_FQ_FILENAME > $INPUT_FQ_FILENAME.fasta 

fi


if [ $QFILTER == "0" ]; then

perl -ne 'if(/(^\@.+\s\d:\w:\d:\w+)/){$_=<>;print ">$1\n",substr($_,$ENV {'TRIMPOS'},$ENV{'TRIMSIZE'}),"\n"}' $INPUT_FQ_FILENAME > $INPUT_FQ_FILENAME.fasta

fi


echo "DONE"

echo



###### PERFORMING NCBI MEGABLAST ALIGNEMENT - searches each known barcode in fasta file ######


echo -n "Looking for BC sequence in each read, using megablast..."

megablast -i $INPUT_FQ_FILENAME.fasta -d $OUTPUT_BC_FILE -F F -W $WORDSIZE -v 1 -b 1 -o $INPUT_FQ_FILENAME.trimmed$TRIMPOS-$TRIMSIZE.WS$WORDSIZE.megablast.out


MEGABLAST_OUTPUT=$INPUT_FQ_FILENAME.trimmed$TRIMPOS-$TRIMSIZE.WS$WORDSIZE.megablast.out


echo "DONE"


echo



###### OUTPUT BARCODE COUNTS ######


echo "creating bc_frequency file..."
 

FILENAME=$(echo "$INPUT_FQ_FILENAME" | cut -f1 -d'.')


grep ">" $MEGABLAST_OUTPUT | sort | uniq -c | sort -nr | perl -ne '/(\d+) >(\w+)/ and print "$2\t$1\n"' > $FILENAME.txt

echo



###### OUTPUT MEGABLAST SUMMARY (displays results from the megablast i.e. number of barcodes found) ######


echo -n "number of BC found: "
grep -c ">" $MEGABLAST_OUTPUT

echo

echo -n "number of BC found in forward: "
grep -c "Strand = Plus / Plus" $MEGABLAST_OUTPUT

echo

echo -n "number of BC found in reversed: "
grep -c "Strand = Plus / Minus" $MEGABLAST_OUTPUT

echo

echo -n "alignment identity: "
grep Identities $MEGABLAST_OUTPUT | sort |uniq -c | sort -n

echo  



###### REMOVING UNECESSARY FILES ######


echo -n "Organizing files..."

rm formatdb.log
rm $INPUT_FQ_FILENAME.fasta
rm $OUTPUT_BC_FILE
rm $OUTPUT_BC_FILE.nhr
rm $OUTPUT_BC_FILE.nin
rm $OUTPUT_BC_FILE.nsq
rm $BC_UNIX_FILE



###### MOVING FILES TO NEW FOLDER ######


mkdir $FILENAME

mv $INPUT_FQ_FILENAME $FILENAME
mv $FILENAME.txt $FILENAME
mv $MEGABLAST_OUTPUT $FILENAME
mv summary.txt $FILENAME


echo "DONE"


###### END OF PIPELINE

echo



