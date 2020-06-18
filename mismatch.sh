
#!/bin/bash

##################################################################################
## Marion Patxot Bertran - MSc in Molecular Life Science (UNIL)			##
##										##
## Aim: check for auto-alignment of barcodes					##
##										##
## USAGE : ./mismatch.sh INPUT_BC_COLLECTION WORDSIZE > summary_mismatch.txt	##
##										##
## Version 1									##
##################################################################################

#DEPENDENCIES
export PATH=$PATH:~/blast-2.2.26/bin

# USER ARGUMENT
INPUT_BC_COLLECTION=$1
WORDSIZE=$2

# EXAMPLE OF PARAMETER TO BE SET BY USER
# INPUT_BC_COLLECTION = barcode.txt
# WORDSIZE = 14 - megablast looks for 25 consecutive bases [allow 15 mismatches over 40 bases for example]
# ./mismatch.sh barcode.txt 14 > summary_mismatch.txt


###### CONVERTING FILE MAC/WINDOWS TO UNIX ######


echo -n "Convert MacOS text file to Unix text file..."

BC_UNIX_FILE="unix_bc.txt"

tr '\r' '\n' < $INPUT_BC_COLLECTION > $BC_UNIX_FILE


echo "DONE"


echo



######  CONVERTING BC TEXT FILE TO FASTA FILE  ######


echo -n "Formatting BC file..."


OUTPUT_BC_FILE="index_barcode.fa"

cut -f 1,2 $BC_UNIX_FILE | perl -ne '/(\w+)\s+(\w+)/ and print ">$1\n$2\n"' > $OUTPUT_BC_FILE

formatdb -i $OUTPUT_BC_FILE -p F


echo "DONE"

echo



######  PERFORMING THE MEGABLAST ALIGNMENT ######


megablast -i index_barcode.fa -d index_barcode.fa -F F -W $WORDSIZE -o $OUTPUT_BC_FILE.out


echo -n "number of alignment found: "

grep -c ">" $OUTPUT_BC_FILE.out



###### REMOVING UNECESSARY FILES ###### 


rm formatdb.log
rm $OUTPUT_BC_FILE
rm $OUTPUT_BC_FILE.nhr
rm $OUTPUT_BC_FILE.nin
rm $OUTPUT_BC_FILE.nsq
rm $BC_UNIX_FILE
rm $OUTPUT_BC_FILE.out


echo



