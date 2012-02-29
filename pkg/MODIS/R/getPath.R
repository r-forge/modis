# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Version 0.1
# Licence GPL v3


getPath <- function(deep=FALSE,quiet=FALSE){

fsep <- .Platform$file.sep

if (Sys.getenv("MRT_HOME")!=""){
	MRTpath <- Sys.getenv("MRT_HOME")
	MRTpath <- normalizePath(MRTpath,winslash=fsep)
	MRTpath <- file.path(MRTpath,"bin",fsep=fsep)
}else{  
  if (!quiet) {
      if (deep) {
          cat("No path variable found for MRT, trying to look for MRT/bin in deep modus (this can take a while, consider aborting it!)\n")
          }else{
          cat("No path variable found for MRT, trying to look for MRT/bin (this can take a while)\n")
          }   
      }
      
MRTpath <- list.files(path = if(deep){"/"}else{"~"}, pattern = "mrtmosaic",full.names = TRUE, recursive = TRUE,ignore.case = FALSE)


#if (length(MRTpath == 1)){
#	MRTpath
 if (length(MRTpath >= 1)) {

	MRTpath <- dirname(MRTpath)
		if(length(MRTpath)>1 & !quiet){
		cat("I'm not sure, is it one of those?\n")
		}
} else {
	if (!quiet){
		cat("MRT not found, sorry but you have to solve this problem first.\nMay MRT is not installed properly\n")
	}
	MRTpath <- 0
	}
}
return(MRTpath)
}

