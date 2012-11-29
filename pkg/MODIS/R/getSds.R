# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

getSds <- function(HdfName,SDSstring=NULL,method="gdal") 
{

    method <- tolower(method) 
    fsep <- .Platform$file.sep

    if (!file.exists(HdfName)) 
    {
        cat("Hm, I have to search for the file! Next time provide the full path and I'll be very fast!\n")
        HdfName <- normalizePath(list.files(path=MODISpackageOpts$localArcPath,pattern=paste(HdfName,"$",sep=""),recursive=TRUE,full.names = TRUE),winslash=fsep)
    }
    
    HdfName <- HdfName[1]

    checkMethod <- unlist(MODIS:::.checkTools(what=method,quiet=TRUE))

    if (!toupper(method) %in% names(checkMethod[which(checkMethod==1)])) 
    {
        stop("in getSds! Method ",method, " does not work. Is ", method," installed properly on your system? Run: 'MODIS:::.checkTools()' to check out which metods should work on your system!")
    }

    if (method=="gdal")
    {

        if (.Platform$OS=="unix")
        {
            sdsRaw <- system(paste("gdalinfo ", HdfName,sep=""),intern=TRUE) 
        } else if (.Platform$OS=="windows")
        {
            gdalPath <- MODIS:::.getDef()$FWToolsPath
            if (is.null(gdalPath))
            {
                cmd <- paste('gdalinfo ', shortPathName(HdfName),sep="")
            } else
            {
                gdalPath <- shortPathName(gdalPath)
                cmd <- shQuote(paste(gdalPath,'\\gdalinfo ', shortPathName(HdfName),sep=""),type="cmd")            
            }
             
            sdsRaw <- shell(cmd,intern=TRUE)

        }
        
        SDSnames <- grep(x=sdsRaw,pattern="SUBDATASET_[0-9]{1,2}_NAME",value=T)
    
        SDSnames <- unlist(lapply(SDSnames,function(x) strsplit(x,"=")[[1]][2]))
    
        sds <- unlist(lapply(SDSnames,function(x) 
                {
                    x <- strsplit(x,":")[[1]]
                    x <- x[length(x)]                    
                }
            ))    
    
    } else if (method=="mrt")
    {
    
        if (.Platform$OS=="unix")
        {
            sdsRaw <- system(paste("sdslist",HdfName,sep=" "),intern=TRUE)
        
        }else if (.Platform$OS=="windows")
        {
            sdsRaw <- shell(gsub(fsep,"\\\\",paste('sdslist "',HdfName,'"',sep="")),intern=TRUE)
    
        } else 
        {
            stop(cat("What OS have you? Please tell me so I can fix this.\n")) 
        }

        sds <- list()
        for (i in 1:length(sdsRaw))
        {
            sds[[i]] <- substr(sdsRaw[i],1,11) == "SDgetinfo: "
        }
        sds <- sdsRaw[unlist(sds)]
        sds <- unlist(lapply(sds,function(x){strsplit(x,", ")[[1]][2]}))
    }
    
    if (!is.null(SDSstring))
    {
        if (inherits(SDSstring,"list"))
        {
            SDSstring <- paste(SDSstring$SDSstring,collapse="")
        } else if (inherits(SDSstring,"numeric")) 
        {
            SDSstring <- paste(SDSstring,collapse="")
        }
    
        SDSstring <- gsub(pattern=" ",replacement="",x=SDSstring) # collapse the spaces

        if (nchar(SDSstring)!= length(sds)) 
        {
            warning("The file has ",length(sds)," layers (SDS), your SDSstring has length ",nchar(SDSstring),"!\nThe string is auto-completed!")
        }
                    
        msk <- rep(FALSE,length(sds))
        for (o in 1:length(sds))
        {
            msk[o] <- substr(SDSstring,o,o)==1
        }
    
        if (method=="gdal") 
        {
            return(list(SDSnames = sds[msk],SDSstring = paste(as.numeric(msk),collapse=" "),SDS4gdal=SDSnames[msk]))
        } else 
        {
            return(list(SDSnames = sds[msk],SDSstring = paste(as.numeric(msk),collapse=" ")))
        }
    } else 
    {
    
        if (method=="gdal") 
        {
            return(list(SDSnames = sds,SDS4gdal=SDSnames))
        } else 
        {
            return(list(SDSnames = sds))
        }
    }
}

