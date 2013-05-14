# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : October 2012
# Licence GPL v3

makeWeights <- function(x, bitShift=2, bitMask=15, threshold=NULL, filename='', decodeOnly=FALSE,...)
{
    if(!require(bitops))
    {
        stop("You need to install the 'bitops' package: install.package('bitopts')")
    }
    
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
            v  <- getValues(x, row=tr$row[i], nrows=tr$nrows[i])
            ve <- dim(v)

            v[v==0] <- NA    
            
            # decode bits
            v <- bitAnd(bitShiftR(v, bitShift ), bitMask)
            
            v[is.na(v)] <- bitMask
                    
            if (!is.null(threshold))
            {
                v[v > threshold] <- bitMask
            }
           
            if (!decodeOnly)
            {
                # turn up side down and scale bits for weighting
                v <- ((-1) * (v - bitMask))/bitMask
                v[v > 1] <- 1
                v[v < 0] <- 0      
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
        
        x[x==0] <- NA

        # decode bits
        x <- bitAnd(bitShiftR(x, bitShift ), bitMask)

        x[is.na(x)] <- bitMask        

        if (!is.null(threshold))
        {
            x[x > threshold] <- bitMask
        }
       
        if (!decodeOnly)
        {
            # turn up side down and scale bits for weighting
            # theoretically best is 0 but the lowest value I have ever noticed is 1! So: (x-1)
            x <- ((-1) * (x - bitMask))/bitMask     
            x[x > 1] <- 1
            x[x < 0] <- 0
        }

        if (!is.null(ve))
        {
            x <- matrix(x,ncol=ve[2],nrow=ve[1],byrow=FALSE)
        }

        return(x)
    }
}    

### maskWater (experimental)
maskWater <- function(QC, bitShift=NULL, bitMask = NULL, maskOut = c(0,5,6),datatype="INT1U",...)
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
        bits <- detectBitInfo(prodinfo, what='Land/Water Flag',warn=FALSE)
        
        if(is.null(bits))
        {
            stop(paste("No 'Land/Water Flag' found, please set it manualy. See: https://lpdaac.usgs.gov/products/modis_products_table/",tolower(prodinfo),sep=""))
        }
        result <- makeWeights(QC, bitShift = bits$bitShift, bitMask = bits$bitMask, decodeOnly=TRUE,...)
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

### detectBitInfo
detectBitInfo <- function(product,what='all',warn=TRUE)
{
    if(inherits(product,"Raster"))
    {
        product <- basename(names(product)[1])
        product <- strsplit(product,"\\.")[[1]][1]
    }
    
    prodinfo <- getProduct(product,quiet=TRUE)$PRODUCT[1]
    if(is.null(prodinfo))
    {
        stop()
    } 
    
    if(exists("info"))
    {
        rm(info)
    }  
      
    try(info <- eval(parse(text=paste("MODIS:::",prodinfo,"_QC",sep=""))),silent=TRUE)
    
    if(exists("info"))
    {
        if(what!='all')
        {
            index <- grep(info$LongName,pattern=what)
            res <- list(bitShift=info[index,"bitShift"],bitMask=info[index,"bitMask"])
        } else 
        {
            res <- info
        }
    } else
    {
        if(warn)
        {
            warning("Could not detect 'bit' information, please provide me the product name you have used so I can enable it!")
        }
        res <- NULL
    }
return(res)    
}







