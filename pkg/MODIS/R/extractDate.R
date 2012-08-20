# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : February 2012
# Licence GPL v3

extractDate <- function(files,pos1=10,pos2=16,asDate=FALSE,format="%Y%j")
{
    files <- basename(files)
    date  <- sapply(files,function(x){substr(x,pos1,pos2)})
    if(asDate)
    {
        date <- as.Date(date, format=format)
        return( list(dates = date, pos1=pos1, pos2=pos2, asDate = asDate, format=format) )
    } else 
    {
        return( list(dates = date, pos1 = pos1, pos2 = pos2))
    }
}

