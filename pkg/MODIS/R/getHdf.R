# Author: Matteo Mattiuzzi, Anja Klisch, matteo.mattiuzzi@boku.ac.at
# Date : July 2011
# Licence GPL v3
  

getHdf <- function(product, begin=NULL, end=NULL, tileH=NULL, tileV=NULL, extent=NULL, collection=NULL, HdfName, quiet=FALSE, wait=0.5, checkIntegrity=FALSE,...) 
{
   # product="MOD11A1"; begin="2010001"; end="2010005"; tileH=NULL; tileV=NULL; extent=NULL; collection=NULL; quiet=FALSE; wait=0.5; checkIntegrity=FALSE; z=1;u=1
    opts <- MODIS:::combineOptions(...)
    
    sturheit <- MODIS:::stubborn(level=opts$stubbornness)
    wait     <- as.numeric(wait)
    
    # TODO HdfName as regex
    if (!missing(HdfName))
    { 
        HdfName <- unlist(HdfName)
        dates <- list()
        
        for (i in seq_along(HdfName))
        {
            HdfName[i] <- basename(HdfName[i]) # separate name from path
            path       <- MODIS:::genString(HdfName[i],...)
            MODIS:::setPath(path$localPath)
        
            if (!file.exists(paste0(path$localPath,"/",HdfName[i]))) 
            {
                MODIS:::ModisFileDownloader(HdfName[i],quiet=quiet,...)
            }
            
            if(checkIntegrity)
            {
                MODIS:::doCheckIntegrity(HdfName[i], quiet=quiet,...)
            }
            dates[[i]] <- paste0(path$local,"/",HdfName[i])
        }
        return(invisible(unlist(dates)))
    
    } else 
    { # if HdfName isn't provided:

        if (missing(product))
        {
            stop("Please provide the supported-'product'. See in: 'getProduct()'")
        }
    
        #######
        # check product
        product <- getProduct(x=product,quiet=TRUE)
        # check collection
        product$CCC <- getCollection(product=product,collection=collection,quiet=TRUE)
        #########
    
        if (product$SENSOR[1]=="MODIS")
        {
    
            if (is.null(begin)) 
            {
                cat("No begin(-date) set, getting data from the beginning\n")
            } 
            if (is.null(end))
            {
                cat("No end(-date) set, getting data up to the most actual\n")
            } 

            # tranform dates
            tLimits <- transDate(begin=begin,end=end)
            #########
            # getStruc
            MODIS:::getStruc(product=product,begin=tLimits$begin,end=tLimits$end,wait=0)
            #getStruc(product=product,server="LAADS",begin=tLimits$begin,end=tLimits$end,wait=0)
            ftpdirs <- list()
            ftpdirs[[1]] <- read.table(paste0(opts$auxPath,"LPDAAC_ftp.txt"),stringsAsFactors=FALSE)
            #ftpdirs[[2]] <- read.table(paste0(opts$auxPath,"LPDAAC_ftp.txt"),stringsAsFactors=FALSE)

        } else if (product$SENSOR=="C-Band-RADAR")
        {
            if (!is.null(tileH) & !is.null(tileV))
            {   
                tileID <- getTile(tileH=tileH,tileV=tileV,system="SRTM")$tile
            } else 
            {
                tileID <- getTile(extent=extent,system="SRTM")$tile
            }
            ntiles <- length(tileID)
         
            ntiles <- length(tileID)
            path   <- MODIS:::genString("SRTM")
            files  <- paste0("srtm",tileID,".zip")
            dir.create(path$localPath,showWarnings=FALSE,recursive=TRUE)
        
            if (!file.exists(paste(path$localPath,"meta.zip",sep="/"))) 
            {
                cat("Getting SRTM metadata from: ftp://xftp.jrc.it\nThis is done once (the metadata is not used at the moment!)\n")
                download.file("ftp://xftp.jrc.it/pub/srtmV4/SRTM_META/meta.zip",paste(path$localPath,"meta.zip",sep="/"),
                mode='wb', method=opts$dlmethod, quiet=quiet, cacheOK=TRUE)
            }
            if (!file.exists(paste(path$localPath,".SRTM_sizes",sep="/")))
            {
                if (! require(RCurl)) 
                {
                    stop("You need to install the 'RCurl' package: install.packages('RCurl')")
                }
                sizes <- getURL(paste0(path$remotePath[[1]],"/"))
                sizes <- strsplit(sizes, if(.Platform$OS.type=="unix"){"\n"} else{"\r\n"})[[1]]
                sizes <- sapply(sizes,function(x){x <- strsplit(x," ")[[1]];paste(x[length(x)],x[length(x)-5],sep=" ")})
                names(sizes) <- NULL
                write.table(sizes,paste(path$localPath,".SRTM_sizes",sep="/"),quote=FALSE,row.names=FALSE,col.names=FALSE)
            }
        
            sizes <- read.table(paste(path$localPath,".SRTM_sizes",sep="/"))
        
            files <- files[files %in% sizes[,1]] # remove Tiles that are not on the server
        
            startIND <- 1:length(path$remotePath) # for better cycling over the servers
            startIND <- rep(startIND,length(files))
        
            cat("Be avare, that sources for SRTM data have limited the number of requests!\nNormally it suspends the download, and after a while it continues. So may you have to be patient!\n")
        
            for(d in seq_along(files)) 
            {
        
                isOK <- TRUE
                if (file.exists(paste0(path$localPath,"/",files[d])))
                {
                    isOK <- MODIS:::checksizefun(file=paste0(path$localPath,"/",files[d]),type="SRTM",sizeInfo=sizes,flexB=50000)$isOK # flexB!
                }
                if (!file.exists(paste0(path$localPath,"/",files[d]))| !isOK)
                {
                    timeout <- options("timeout") # TEST I'm not sure if it helps (timeout is used in ?download.file)
                    options(timeout=15)
    
                    for(g in 1:sturheit) 
                    {
                        server <- names(path$remotePath)[rep(startIND[d:(d+length(path$remotePath)-1)],length=sturheit)]
                        cat("Getting SRTM data from:",server[g],"\n")
                        Sys.sleep(wait)        
                                        
                        hdf=1
                        try(
                            hdf <- download.file(
                                paste0(path$remotePath[[server[g]]],"/", files[d]),
                                destfile=paste0(path$localPath,"/", files[d]),
                                mode='wb', method=opts$dlmethod, quiet=quiet, cacheOK=TRUE),
                            silent=TRUE
                        )
                        if (hdf==0) 
                        {
                            SizeCheck <- MODIS:::checksizefun(file=paste0(path$localPath,"/", files[d]),type="SRTM",sizeInfo=sizes,flexB=50000)
                            if(!SizeCheck$isOK) {hdf=1} # if size check fails, re-try!
                        }
                        if(hdf==0 & !quiet) 
                        {
                            lastused <- server[g] 
                            if (g==1) 
                            {
                                cat("Downloaded by the first try!\n\n")
                            } else 
                            {
                                cat("Downloaded after",g,"retries!\n\n")
                            }
                        }
                        if(hdf==0) 
                        {
                            break
                        }    
                    }
                options(timeout=as.numeric(timeout)) # set timeout back to default
                }
            }
            SRTM <- paste0(path$localPath,"/",files)
        return(invisible(SRTM))
    }
    
    dates  <- list()
    output <- list() # path info for the invisible output
    l=0
       
    for(z in seq_along(product$PRODUCT))
    { # Platforms MOD/MYD

        if (product$TYPE[z]=="Swath") 
        {
            cat("'Swath'-products not yet supported, jumping to the next.\n")
        } else 
        {

            todo <- paste0(product$PRODUCT[z],".",product$CCC[[which(names(product$CCC)==product$PRODUCT[z])]])
        
            for (u in seq_along(todo))
            {
                # tileID
                if (product$TYPE[z]=="CMG") 
                {
                    tileID="GLOBAL"
                    ntiles=1 
                } else 
                {
                    if (!is.null(tileH) & !is.null(tileV)) 
                    {
                        extent <- getTile(tileH=tileH,tileV=tileV)
                    } else
                    {
                        extent <- getTile(extent=extent)
                    }
                    tileID <- extent$tile
                    ntiles <- length(tileID)
                }
                    
                datedirs <- ftpdirs[[1]][,todo[u]]
                datedirs <- datedirs[!is.na(datedirs)]            
                sel <- as.Date(datedirs,format="%Y.%m.%d")
                us  <- sel >= tLimits$begin & sel <= tLimits$end
                
                if (sum(us,na.rm=TRUE)>0)
                { 
                    suboutput <- list()
                    l=l+1                
                    dates[[l]] <- datedirs[us]

                    dates[[l]] <- cbind(dates[[l]],matrix(rep(NA, length(dates[[l]])*ntiles),ncol=ntiles,nrow=length(dates[[l]])))
                    colnames(dates[[l]]) <- c("date",tileID)

                    for (i in 1:nrow(dates[[l]]))
                    { # i=1
                        cat(dates[[l]][i,1],"\n")
                        flush.console()
                        
                        year <- format(as.Date(dates[[l]][i,1],format="%Y.%m.%d"), "%Y")
                        doy  <- as.integer(format(as.Date(dates[[l]][i,1],format="%Y.%m.%d"), "%j"))
                        doy  <- sprintf("%03d",doy)
                        mtr  <- rep(1,ntiles) # for file availability flaging
                        path <- MODIS:::genString(x=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],date=dates[[l]][i,1])
                        
                        for(j in 1:ntiles)
                        {  
                            dates[[l]][i,j+1] <- paste0(strsplit(todo[u],"\\.")[[1]][1],".",paste0("A",year,doy),".",if (tileID[j]!="GLOBAL") {paste0(tileID[j],".")},strsplit(todo[u],"\\.")[[1]][2],".*.hdf$") # create pattern            
                            if (length(dir(path$localPath,pattern=dates[[l]][i,j+1]))>0)
                            { # if available locally
                                HDF <- dir(path$localPath,pattern=dates[[l]][i,j+1]) # extract HDF file
          
                                if (length(HDF)>1)
                                { # in very recent files sometimes there is more than 1 file/tile/date if so get the most recent processing date
                                    select <- list()
                                    for (d in 1:length(HDF))
                                    { 
                                        select[[d]]<- strsplit(HDF[d],"\\.")[[1]][5]
                                    }
                                    HDF <- HDF[which.max(unlist(select))]        
                                }
                                dates[[l]][i,j+1] <- HDF
                                mtr[j] <- 0
                            }
                        }
                        
                        if (sum(mtr)!=0) 
                        { # if one or more of the tiles in the given date is missing, its necessary to go online

                            if(exists("ftpfiles")) 
                            {
                                rm(ftpfiles)
                            }
                            
                            if (!require(RCurl)) 
                            {
                                stop("You need to install the 'RCurl' package: install.packages('RCurl')")
                            }
            
                            for (g in 1:sturheit)
                            { # get list of FILES in remote dir
                                server <- names(path$remotePath)[g%%length(path$remotePath)+1]
                                ftpfiles <- try(MODIS:::filesUrl(path$remotePath[[server]]),silent=TRUE)
                                
                                if(ftpfiles[1]==FALSE)
                                {
                                    #stop("Problem to connect to: ",path$remotePath[[server]],"\nmaybe there is a date problem,check this path in your browser.\nIf it does not work try to solve this by running: 'MODIS:::getStruc(product=",todo[u],",wait=0,forceCheck=TRUE)'\nand restart your job (getHdf or runGdal/runMrt)")
                                    rm(ftpfiles)
                                }
                                if(exists("ftpfiles"))
                                {
                                  break
                                }
                                Sys.sleep(wait)
                            }
                            
                            if(!exists("ftpfiles")) 
                            {
                                stop("Problems with online connections try a little later")
                            }
                            
                            if (ftpfiles[1] != "total 0") 
                            {
                                ftpfiles <- unlist(lapply(strsplit(ftpfiles," "),function(x){x[length(x)]})) # found empty dir!
        
                                for(j in 1:ntiles)
                                { # j=1
                                    if(mtr[j]==1)
                                    { # if tile is missing get it
                                        onFtp <- grep(ftpfiles,pattern=dates[[l]][i,j+1],value=TRUE)
                                        HDF   <- grep(onFtp,pattern=".hdf$",value=TRUE)
        
                                        if(length(HDF)>0)
                                        {
                                            if (length(HDF)>1) 
                                            { # in very recent files sometimes there is more than 1 file/tile/date if so get the last
                                                select <- list()
                                                for (d in 1:length(HDF))
                                                {
                                                    select[[d]] <- strsplit(HDF[d],"\\.")[[1]][5]
                                                }
                                                HDF <- HDF[which.max(unlist(select))]        
                                            }

                                            dates[[l]][i,j+1] <- HDF
                                            hdf <- MODIS:::ModisFileDownloader(HDF, wait=wait, quiet=quiet,...)
                                            mtr[j] <- hdf

                                        } else 
                                        { 
                                            dates[[l]][i,j+1] <- NA 
                                        }
                                    }
                                }
                            } else 
                            {
                                dates[[l]][i,(j+1):ncol(dates[[l]])] <- NA
                            } # on ftp is possible to find empty folders!
                        }
                        if(checkIntegrity)
                        { # after each 'i' do the sizeCheck
                            isIn <- MODIS:::doCheckIntegrity(paste0(path$localPath,dates[[l]][i,-1]), wait=wait, quiet=quiet,...)
                        }
                    suboutput[[i]] <- paste0(path$localPath,dates[[l]][i,-1])                    
                    } # end i
        
                    output[[l]] <-  as.character(unlist(suboutput))
                    names(output)[l] <- todo[u]
                } else 
                {
                    cat(paste0("No files on ftp in date range for: ",todo[u],"\n\n"))
                }
            } 
        }
    }
    return(invisible(output))
} 
} ## END: FTP vs ARC check and download 

