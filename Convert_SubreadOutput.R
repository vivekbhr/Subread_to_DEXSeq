## Read FeatureCount output and load into DEXSeq or convert to DEXSeq acceptable format
## Copyright 2015 Vivek Bhardwaj (bhardwaj@ie-freiburg.mpg.de). Licence: GPLv3.

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
p <- add_argument(p,"--threads",help = "Number of cores to use (leave empty for one)")

## Parse the arguments
argv <- parse_args(p)
fcout <- argv$fcout
samplenames <- argv$names # samplenames seperated by comma ,
outfile <- argv$outfile
out <- argv$out
threads <-argv$threads

print("branch faster")

system.time({
  # read the sorted Fcount output (excluding header and comment line)
  read.table(fcout,skip = 2) %>% dplyr::arrange(V1,V3,V4) %>% dplyr::select(-(V2:V6)) -> df
  colnames(df) <- paste0("V",1:ncol(df))
  
  # add a count for exon number and create new df
  genes <- as.character(unique(df[,1]))
  getdata <- function(name,df){ # for each unique gene id in the file
          filter(df,V1 == name) %>% mutate(V1 = paste0(V1,":",sprintf("%03.0f",1:nrow(.)))) %>% 
                  return()
  }
  if(is.null(threads)){
          plyr::ldply(genes, getdata,df = df) -> outdf
  } else {
          cl <- parallel::makeCluster(threads,type = "FORK")
          parallel::mclapply(genes, getdata,df = df) %>% plyr::ldply(data.frame) -> outdf
  }
  


  # write back the output
  sink(outfile)
  if(!(is.null(samplenames))){
          unlist(strsplit(samplenames,",")) -> samplenames
          cat("Geneid",samplenames,sep="\t")
          cat("\n")
  }
  sink()
  write.table(outdf,outfile,quote = F,sep = "\t",row.names = F,col.names = F,append = TRUE)
})
