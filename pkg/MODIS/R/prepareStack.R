# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3


preStack <- function(path="./",pattern,begin=NULL,end=NULL,pos1=10,pos2=16)
{
    fnames <- list.files(path=path,pattern=pattern,full.names=TRUE)

    if (length(fnames)==0)
    {
        cat("No files found!\n");return(NULL)
    }

    dates   <- extractDate(basename(fnames),pos1=pos1,pos2=pos2)
    timings <- transDate(begin=begin,end=end)
    
    fnames <- fnames[timings$beginDOY <= dates & timings$endDOY >= dates]
    dates  <- dates[timings$beginDOY <= dates & timings$endDOY >= dates]
    fnames <- fnames[order(dates)]

    cat("Found",length(fnames),"files!\n")
    if (length(fnames)==0) (return(NULL))
    
    return(fnames)
}
