# CUT&RUN Analysis Pipeline
This is an automatic pipeline built for UCSF's Wynton HPC to process CUT&RUN data for transcription factors.
The scripts utilize code from CUT&RUNtools (https://bitbucket.org/qzhudfci/cutruntools/src/master/) and the CUT&TAG tutorial (https://www.protocols.io/view/cut-amp-tag-data-processing-and-analysis-tutorial-e6nvw93x7gmk/v1)

# Software
Trimmomatic\
Kseq from CUT&RUNtools. I put in a folder at ~/tools/\
filter_below.awk from CUT&RUNtools. Also in ~/tools/\
Bowtie2\
Picard\
Samtools\
MACS2\
ChipSeeker\
Homer

# Inputs
Input is a .txt file where each line describes a sample to be analyzed. \
Each line contains: Project folder, Sample name, Suffix of FASTQ1, Suffix of FASTQ2, Control sample name (optional)

Project Folder: The folder where you are storing the FASTQs and where the analysis output will be deposited\
Sample Name: The name of your sample, which is also the prefix on the FASTQ file\
Suffix of FASTQ1/2: The rest of the FASTQ filename after the sample name, usually indicating read, lane, etc.\
Control sample name: The control sample you would like to compare your sample to (i.e the IgG control in CUT&RUN experiments). If left blank, sample vs control analysis will not be performed.\
An example file is provided and named example_samples.txt

# Run the pipeline
To run CUT&RUN pipeline, submit jobs with the submit_cutandrun.sh script, providing the path to the example_samples.txt file and the base directory where the project folder can be found.

```qsub submit_cutandrun.sh /path/to/example_sample.txt /base/directory/```

The submission script submits a series of scripts to perform the following functions.\
Trim FASTQs: trim.sh\
Align to genome, mark and remove duplicates, filter reads under 120 bp: align_dup_filter.sh\
Convert BAM files to BigWigs: bamtobigwig_RPGC.sh\
Align to spike-in genome and create calibrated bedgraphs: align_ecoli2.sh, getSpikeIn.sh and calibrate_bedgraph.sh\
Call Peaks: macs2_peaks.sh\
Annotate Peaks: chpskr_v2.sh\
Find Motifs: homer.sh\
Get QC Metrics: sub_metrics.sh
