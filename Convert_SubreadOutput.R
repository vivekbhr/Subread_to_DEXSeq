## Read FeatureCount output and load into DEXSeq or convert to DEXSeq acceptable format
## Author : Vivek Bhardwaj (bhardwaj@ie-freiburg.mpg.de). Feel free to use as GPLv3.

options(warn = -1)
suppressPackageStartupMessages({
require(dplyr)
require(argparser)
})

## Add arguments
p <- arg_parser("Read FeatureCount output and convert to DEXSeq acceptable format")
p <- add_argument(p,"--fcout",help = "Featurecounts output file (using DEXSeq-flattened GTF file)")
p <- add_argument(p,"--names",help = "Sample names (In same order as column names in output file)")
p <- add_argument(p,"--outfile",help = "HTSeq-like output file to write back.")

## Parse the arguments
argv <- parse_args(p)
fcout <- argv$fcout
samplenames <- argv$names # samplenames seperated by comma ,
outfile <- argv$outfile
out <- argv$out
print("branch faster")
## Read and count exons
count_exons <- function(fcout,samplenames){
  # read the sorted Fcount output (excluding header and comment line)
  read.table(fcout,skip = 2) %>% dplyr::arrange(V1,V3,V4) %>% dplyr::select(-(V2:V6)) -> df
  colnames(df) <- paste0("V",1:ncol(df))
  # add a count for exon number and create new df
  genes <- unique(df[,1])
  num <- length(genes)
  oldDF <- vector("list",num)
  for(i in 1:num){ # for each unique gene id in the file
        filter(df,V1 == genes[i]) %>% mutate(V1 = paste0(V1,":",sprintf("%03.0f",1:nrow(.)))) -> oldDF[[i]]
    # add exon number
  }
  oldDF <- do.call(rbind,oldDF)
  # remove 1st empty line and print out
  if(!(is.null(samplenames))){
    unlist(strsplit(samplenames,",")) -> samplenames
    colnames(oldDF) <- c("Geneid",samplenames)
  }
  #return(oldDF[2:nrow(oldDF),])
  return(oldDF)
}

#suppressWarnings({
#  suppressMessages({
  #compiler::cmpfun(count_exons) -> count_exons # compile the function
  #}) 
#})

## writeback the output
system.time({
if(!(is.null(outfile))){
  count_exons(fcout = fcout, samplenames = samplenames) %>%
    write.table(outfile,quote = FALSE,sep = "\t",row.names = F) # test_like-dex.out
  print("Done!")
  } else {
  stop("please provide output filename")
  }
})