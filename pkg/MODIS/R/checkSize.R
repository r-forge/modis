# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : Oktober 2012
# Licence GPL v3

checkSize <- function(HdfName, dlmethod="auto",stubbornness="low",localArcPath=.getDef('localArcPath'))
{
    # 4 debug
    # quiet=FALSE;dlmethod="auto";stubbornness="low";localArcPath=MODIS:::.getDef('localArcPath'); u=1;j=1
    
    localArcPath <- paste(strsplit(localArcPath,"/")[[1]],collapse="/")# removes "/" or "\" on last position (if present)
    dir.create(localArcPath,showWarnings=FALSE)
    # test local localArcPath
    try(testDir <- list.dirs(localArcPath,recursive=FALSE), silent=TRUE)
    if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 
    #################
    
    sturheit <- MODIS:::.stubborn(level=stubbornness)

    if(!missing(HdfName)) 
    {
        HdfName <- unlist(HdfName)
        avFiles <- list()
        
        for (i in seq(length(HdfName)))
        {
            if (file.exists(HdfName[i])) 
            { # if exists than HdfName is a path+File+itexists
                avFiles[[i]] <- HdfName[i] 
            } else 
            {
                avFiles[[i]] <- list.files(localArcPath,pattern=HdfName[i],recursive=TRUE,full.names=TRUE)
                avFiles[[i]] <- grep(avFiles[[i]], pattern=".hdf$",value=TRUE) # no ".hdf.xml" files, only ".hdf" 
            }
        }
         
    avFiles <- unlist(avFiles)
    } else 
    {
        avFiles <- list.files(localArcPath,pattern=".hdf$",recursive=TRUE,full.names=TRUE) # all hdf under 'localArcPath'
    }
    avFiles <- normalizePath(avFiles,winslash="/")
    # tests if it is a MODIS-grid file(s) (TODO proper function that checks that)
    doit    <- MODIS:::.isSupported(avFiles)
    avFiles <- basename(avFiles)[doit]
      
    if(length(avFiles)==0) 
    {
        cat("No MODIS grid files found.\n")
        return(NULL)
    } else 
    {
        islocal <- rep(FALSE,length(avFiles))

        for (u in seq_along(avFiles))
        {
            product    <- getProduct(avFiles[u],quiet=TRUE)
            fdate      <- MODIS:::.getPart(product,"DATE")
            collection <- MODIS:::.getPart(product,"CCC")
            path       <- MODIS:::.genString(product)
            
            Sinfo <- seq_along(path$remotePath)
            refFile <- rep(0,length(Sinfo))
            # first get information from all servers
            for(j in Sinfo)
            {
                server   <- names(path$remotePath)[j]
                infofile <- list.files(path=path$localPath,pattern=paste(server,"_*",sep=""),full.names=TRUE)
                getIt    <- length(infofile)==0
                                
                if (!getIt)
                {  
                   getIt <- as.numeric(file.size(infofile)) < 14000
                }
                
                if(getIt)
                { 
                    cat("Getting information from",server,"          \r")
                    
                    for (g in 1:20)
                    {
                        remoteInfo <- NULL
                        #cat(paste(path$remotePath[j],"/",avFiles[u],sep=""),"\n")
                        try(remoteInfo <- MODIS:::filesUrl(paste(path$remotePath[j],"/",sep="")),silent=TRUE)
                        
                        if(!is.null(remoteInfo$fileNames))
                        {
                            break
                        } else 
                        {
                            cat("Server refused, retry",g+1,"       \r")
                        }
                    }                    
                    
                    tofile <- remoteInfo[grep(remoteInfo$fileNames,pattern=".hdf$"),]
                    if(length(tofile)>0)
                    {
                        write.table(tofile,row.names=FALSE,file=paste(path$localPath,"/",server,"_",format(Sys.time(),"%Y%m%d"),sep=""))
                        refFile[j] <- 1
                    }
                } else
                {
                    refFile[j] <- 1
                }
            }
            
            # then make the size checks
            onS <- rep(-1,length(Sinfo))
            for(j in Sinfo[refFile==1])
            {
                server   <- names(path$remotePath)[j]
                try(info <- read.table(list.files(path=path$localPath,pattern=paste(server,"_*",sep=""),full.names=TRUE),header=TRUE),silent=TRUE)
                isOK     <- MODIS:::.checksizefun(file=paste(path$localPath,"/",avFiles[u],sep=""),sizeInfo=info)
                
                if (is.null(isOK$isOK))
                {
                    onS[j] <- -1                
                }
                else if (isTRUE(isOK$isOK))
                {
                    onS <- 1
                    islocal[u] <- TRUE
                    break
                } else
                {
                    onS[j] <- 0
                }        
            }
            
            if(sum(onS==1)>0)
            {
                cat("FileSize OK:",avFiles[u],"\n")
            } else if (sum(onS==0)==length(onS))
            {
                cat("Chould not determine expected filesize!\n")
                # TODO try to open the file...ik ok it is probebly ok
            } else
            {
    
                for(j in which(onS==0))
                {               
                    server   <- names(path$remotePath)[j]
                    try(info <- read.table(list.files(path=path$localPath,pattern=paste(server,"_*",sep=""),full.names=TRUE),header=TRUE),silent=TRUE)
                    isOK     <- MODIS:::.checksizefun(file=paste(path$localPath,"/",avFiles[u],sep=""),sizeInfo=info)

                    cat("  Size Error detected for ",avFiles[u],"\nFileSize is ", isOK$FileSize,", but should be: ",isOK$MetaSize,"\n",sep="")
                
                    # get the hdf file if size fails
                    for (g in 1:sturheit)
                    {
                        if(g==1) cat("Getting HDF file from:",server,"\n")
    
                        hdf=1
                        #cat(paste(path$remotePath[j],"/",avFiles[u],sep=""),"\n")
                        try(hdf <- download.file( ## hdf file
                            paste(path$remotePath[j],"/",avFiles[u],sep=""),
                            destfile=paste(path$localPath, "/",avFiles[u],sep=""),
                            mode='wb', method=dlmethod, quiet=FALSE, cacheOK=FALSE)
                        ,silent=TRUE)
                        
                        if (MODIS:::.checksizefun(file=paste(path$localPath,"/",avFiles[u],sep=""),sizeInfo=info)$isOK)
                        {
                            hdf <- 0
                        }
                        if(hdf==0)
                        {
                            cat("Ok file updated\n")
                            islocal[u] <- TRUE
                            break
                        }
                    }
                }
            }
        }
    }    
}
