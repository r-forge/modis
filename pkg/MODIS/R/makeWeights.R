# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : October 2012
# Licence GPL v3

makeWeights <- function(x, bitShift, bitMask, threshold=NULL, filename='', decodeOnly=FALSE,...)
{
    if (inherits(x,"Raster"))
    {
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
                v[v > threshold] <- bitMask
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
    } else
    {
        ve <- dim(x)

        # decode bits
        x <- bitAnd(bitShiftR(x, bitShift ), bitMask)
        
        if (!is.null(threshold))
        {
            # thres <- ((-1) * (threshold - bitMask))/bitMask
            x[x > threshold] <- 0
        }
       
        if (!decodeOnly)
        {
            # turn up side down and scale bits for weighting
            x <- ((-1) * (x - bitMask))/bitMask      
        }

        if (!is.null(ve))
        {
            x <- matrix(x,ncol=ve[2],nrow=ve[1],byrow=FALSE)
        } 
        return(x)
    }
}    


maskWater <- function(QC, bitShift=NULL, bitMask = NULL, maskOut = c(0,5,6),...)
{
    if (!inherits(QC,"Raster"))
    {
        stop("'maskWater' requires a raster* object")
    }
    
    if (is.null(bitShift) | is.null(bitMask))
    {
        cat("Missing required information, trying to autodetect 'Land/Water Flag'!\n")
        fname    <- filename(QC)        
        prodinfo <- strsplit(fname,"\\.")[[1]][1]
        # test
        prodinfo <- getProduct(prodinfo)$request
        
        try(info <- eval(parse(text=paste("MODIS:::",prodinfo,"_QC",sep=""))),silent=TRUE)
        if(exists("info"))
        {
            water    <- grep(info$LongName,pattern="Land/Water Flag")
            if (length(water)==1)
            {
                cat("Ok 'Land/Water Flag' found, extracting\n")
                result <- makeWeights(QC, bitShift = info$bitShift[water], bitMask = info$bitMask[water], decodeOnly=TRUE,...)
            } else 
            {
                stop(paste("No 'Land/Water Flag' found, please set it manualy. See: https://lpdaac.usgs.gov/products/modis_products_table/",tolower(prodinfo),sep=""))
            }

        } else
        {
            stop(paste("No 'Land/Water Flag' found, please set it manualy. See: https://lpdaac.usgs.gov/products/modis_products_table/",tolower(prodinfo),sep=""))
        }
    } else 
    {
        result <- makeWeights(QC, bitShift = bitShift, bitMask = bitMask, decodeOnly=TRUE,...)
    }
    if (!is.null(maskOut))
    {
        eval(parse(text=paste("result <- result %in% ", paste("c(",paste(maskOut,sep="",collapse=","),")"))))    
    }
return(result)
}




