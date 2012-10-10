# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : October 2012
# Licence GPL v3

makeWeights <- function(x, bitShift, bitMask, threshold=NULL, filename='', decodeOnly=FALSE,...)
{
    require(bitops)

    out <- brick(x, values=FALSE)
    if(nlayers(out)==1)
    {
        out <- raster(x)
    }

    out <- writeStart(out, filename=filename,...)
    tr  <- blockSize(out)
    
    for (i in 1:tr$n) 
    {
        v <- getValues(x, row=tr$row[i], nrows=tr$nrows[i])
        ve <- dim(v)

        # decode bits
        v <- bitAnd(bitShiftR(v, bitShift ), bitMask)
        
        if (!is.null(threshold))
        {
            # thres <- ((-1) * (threshold - bitMask))/bitMask
            v[v > threshold] <- 0
        }
       
        if (!decodeOnly)
        {
            # turn up side down and scale bits for weighting
            v <- ((-1) * (v - bitMask))/bitMask      
        }

        if (!is.null(ve))
        {
            v <- matrix(v,ncol=ve[2],nrow=ve[1],byrow=FALSE)
        } 

        out <- writeValues(out, v, tr$row[i])
    }
    out <- writeStop(out)
    return(out)
}    

