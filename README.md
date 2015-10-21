# Subread_to_DEXSeq
Vivek Bhardwaj  
16.10.2015  

## These functions provide a way to use featurecounts output for DEXSeq

The directory contains three scripts:

1) **dexseq_prepare_annotation2.py** : It's same as the "dexseq_prepare_annotation.py" that comes with DEXSeq, but with an added option to output featureCounts-readable GTF file.

2) **Convert_SubreadOutput.R** : It's an Rscript to format featureCounts output file so that It looks like DEXSeq-counts output (with exon-IDs included).

3) **load_SubreadOutput.R** : Provided a function "DEXSeqDataSetFromFeatureCounts", to load the output of "Convert_SubreadOutput.R" as a dexSeq object.

## Usage example


## Results

On a real dataset from drosophila (mapped to dm6). I compared the output from featurecounts and DEXSeq_Counts.

#### Dispersion Estimates

![](dispESt_combined.png) 
