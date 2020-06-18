#!/bin/sh

#  script.sh
#  tester BC pipeline
#  Marion Patxot Bertran
#  created on 19.03.19.

#download files and untar with
tar -zxvf BC_PIPELINE.tar


## IMPORTANT ##
#we need blast and executables to perform the alignment: https://blast.ncbi.nlm.nih.gov/Blast.cgi
#the pipeline uses an old version of blast = blast-2.2.26: http://mirrors.vbi.vt.edu/mirrors/ftp.ncbi.nih.gov/blast/executables/legacy.NOTSUPPORTED/2.2.26/
#download the link according to your operating system

#here on MacOS:
#(1) copy the link to the file: ncbi-blast-2.2.26+-universal-macosx.tar.gz (right click and copy)
#(2) download the file in BC_PIPELINE using wget (wget can be installed with homebrew https://brew.sh : brew install wget)
#(3) untar
#(4) export path to be able to call the executable files from the command line

cd ~/
wget http://mirrors.vbi.vt.edu/mirrors/ftp.ncbi.nih.gov/blast/executables/legacy.NOTSUPPORTED/2.2.26/blast-2.2.26-universal-macosx.tar.gz
tar -zxvf blast-2.2.26-universal-macosx.tar.gz

#the two executables megablast and formatdb (allblast package) are no longer in the latest version of blast = blast+
#the new version should be investigated and the pipeline updated to use blast+ instead of the old package allblast


#go to the BC_PIPELINE directory
cd ~/Downloads/BC_PIPELINE


#run pipeline
#./batch.sh INPUT_BC_COLLECTION FASTQ_HEADER QFILTER TRIMPOS TRIMSIZE WORDSIZE
./batch.sh barcodes.txt \@TWEETY 1 40 100 10


# on 20.03.2019
# 1. passed all parameters to arguments in bc_counts.sh - batch.sh and mismatch.sh
# 2. added some information to output when running
# 3. added dependencies in bc_counts (important to download the megablast and formatdb executables as mentioned above)
# 4. upadate how_to_use_the_pipeline.txt



