# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3


.getStruc <- function(product,collection=NULL,server="LPDAAC",begin=NULL,end=NULL,forceCheck=FALSE,wait=1, stubbornness=10,localArcPath=.getDef("localArcPath"))
{
    server <- toupper(server)
    if(!server %in% c("LPDAAC","LAADS"))
    {
        stop(".getStruc() Error! server must be or 'LPDAAC' or 'LAADS'")
    }

    sturheit <- .stubborn(level=stubbornness)

    localArcPath <- normalizePath(localArcPath,"/",mustWork=FALSE)
    dir.create(localArcPath,recursive=TRUE,showWarnings=FALSE)    
   
    # test local localArcPath
    try(testDir <- list.dirs(localArcPath),silent=TRUE)
    if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 

    auxPATH <- file.path(localArcPath,".auxiliaries",fsep="/")
    dir.create(auxPATH,recursive=TRUE,showWarnings=FALSE)

    #########################
    # Check Platform and product
    product <- getProduct(x=product,quiet=TRUE)
    # Check collection
    if (!is.null(collection))
    {
        product$CCC <- getCollection(product=product,collection=collection,localArcPath=localArcPath) 
    }
    if (length(product$CCC)==0)
    {
        product$CCC <- getCollection(product=product,localArcPath=localArcPath) # if collection isn't provided, this gets the newest for the selected products.
    }

    dates <- transDate(begin=begin,end=end)
    today <- as.Date(format(Sys.time(),"%Y.%m.%d"),format="%Y.%m.%d")
    ########################

    # load aux
    if (!file.exists(file.path(auxPATH,paste(server,"_ftp.txt",sep=""),fsep="/")))
    {
        invisible(file.copy(file.path(find.package('MODIS'),'external',paste(server,"_ftp.txt",sep="")),file.path(auxPATH,paste(server,"_ftp.txt",sep=""),fsep="/")))
    }

    ftpdirs <- read.table(file.path(auxPATH,paste(server,"_ftp.txt",sep=""),fsep="/"),stringsAsFactors=FALSE)
    good    <- sapply(colnames(ftpdirs), function(x) {length(strsplit(x,"\\.")[[1]])==2})
    ftpdirs <- ftpdirs[,good] # remove wrong cols
    
    for (i in 1:length(product$PRODUCT))
    {
        todo <- paste(product$PRODUCT[i],".",product$CCC[[which(names(product$CCC)==product$PRODUCT[i])]],sep="")
    
        for(u in 1:length(todo))
        {
            path <- MODIS:::.genString(x=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],local=FALSE,localArcPath=localArcPath)
        
            # test if the product is available on "LAADS" (default is LPDAAC!)
            if (server =="LAADS")
            { 
                if (! require(RCurl))
                {
                    stop("You need to install the 'RCurl' package: install.packages('RCurl')")
                }
                for (g in 1:sturheit)
                {
                    hm <- url.exists(strsplit(path$remotePath$LAADS,"YYYY")[[1]][1])
                    if(hm) {break}
                }
            } else 
            {
                hm <- FALSE
            }
        
            if (server == "LPDAAC" | (server == "LAADS" & hm ))
            {
                if (todo[u] %in% colnames(ftpdirs))
                {
                    avDates <- as.Date(as.character(ftpdirs[,which(colnames(ftpdirs)==todo[u])]),format="%Y.%m.%d")
                    avDates <- avDates[!is.na(avDates)]
                                      
                    lastAv   <- as.Date(max(avDates))
                    prodStep <- as.numeric(lastAv - avDates[length(avDates)-1])
                    
                    if (lastAv < dates$end & today >= lastAv+prodStep)
                    {
                        getIT <- TRUE
                    } else {
                        getIT <- FALSE
                    }
                } else {
                    getIT <- TRUE
                }
        
                if (getIT | forceCheck)
                {
                    if (! require(RCurl))
                    {
                        stop("You need to install the 'RCurl' package: install.packages('RCurl')")
                    }
    
                    cat("Getting structure on ",server," for: ",todo[u],"\n",sep="")
            
                    if(exists("FtpDayDirs"))
                    {
                        rm(FtpDayDirs)
                    }
                                
                    if (server=="LPDAAC")
                    {
                        startPath <- strsplit(path$remotePath$LPDAAC,"DATE")[[1]][1] # cut away everything behind DATE
    
                        for (g in 1:sturheit)
                        {
                            cat("Try:",g,"\r")
                            try(FtpDayDirs <- getURL(startPath),silent=TRUE)
                            Sys.sleep(wait)
                            cat("             \r")     
                            if(exists("FtpDayDirs"))
                            {    
                                break
                            }
                        }
                        if(exists("FtpDayDirs"))
                        {
                            FtpDayDirs <- unlist(strsplit(FtpDayDirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"}))
                            FtpDayDirs <- FtpDayDirs[substr(FtpDayDirs, 1, 1)=='d'] 
                            FtpDayDirs <- unlist(lapply(strsplit(FtpDayDirs, " "), function(x){x[length(x)]}))
                        }
    
                    } else if (server=="LAADS")
                    {
                        startPath <- strsplit(path$remotePath$LAADS,"YYYY")[[1]][1] # cut away everything behind YYYY
                        opt <- options("warn")
                        options("warn"=-1)
                        rm(p,years)
                        options("warn"=opt$warn)
    
                        once <- TRUE
                        for (g in 1:sturheit)
                        {
                            cat("Getting Year(s) try:",g,"\r")
                            try(years <- getURL(startPath),silent=TRUE)
                            if(g < (sturheit/2)) {
                                Sys.sleep(wait)
                            } else {
                                if(once & (30 > wait)) {cat("Server problems, trying with 'wait=",max(30,wait),"\n")}
                                once <- FALSE                        
                                Sys.sleep(max(30,wait))
                            }
                            if(exists("years"))
                            {    
                                break
                            }
                            cat("                          \r") 
                        }
    
                        years <- unlist(strsplit(years[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"}))
                        years <- years[substr(years, 1, 1)=='d'] 
                        years <- unlist(lapply(strsplit(years, " "), function(x){x[length(x)]}))
                        Ypath <- paste(startPath,years,"/",sep="")
    
                        once <- TRUE
                        for (g in 1:sturheit)
                        {
                            cat("                          \r")
                            cat("Getting day(s) try:",g,"\r") # for",todo[u],"
                            try(p <- getURL(Ypath),silent=TRUE) # async=T!
                            if(g < (sturheit/2))
                            {
                                Sys.sleep(wait)
                            } else {
                                if(once & (30 > wait)) {cat("Server problems, trying with 'wait=",max(30,wait),"\n")}
                                once <- FALSE                        
                                Sys.sleep(max(30,wait))
                            }
                            if(exists("p"))
                            {    
                                break
                            }
                        }
                        cat("                          \r")                    
                        if(exists("p"))
                        {
                            FtpDayDirs <- as.character(unlist(sapply(p, function(pb,l=0) {
                                pb <- unlist(strsplit(pb, if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"}))
                                pb <- pb[substr(pb, 1, 1)=='d'] 
                                pb <- unlist(lapply(strsplit(pb, " "), function(x){x[length(x)]}))
                                l=l+1
                                format(as.Date(as.numeric(pb) - 1, origin = paste(years[l],"-01-01", sep = "")), "%Y.%m.%d")
                            })))
                        }                
                    }
    
                    if(!exists("FtpDayDirs"))
                    {
                        cat("Couldn't get structure from",server,"server working with offline information!\n")
                        return(invisible(NULL))        
                    } else {
    
                        rowdim <- max(nrow(ftpdirs),length(FtpDayDirs))
                        if (todo[u] %in% colnames(ftpdirs)) { 
                            coldim <- ncol(ftpdirs)
                            colnam <- colnames(ftpdirs)
                        } else {
                            coldim <- ncol(ftpdirs) + 1
                            colnam <- c(colnames(ftpdirs),todo[u])
                        }
                        
                        mtr <- matrix(NA,ncol=coldim,nrow=rowdim)
                        colnames(mtr) <- colnam    
                        
                        if (ncol(ftpdirs)>0)
                        {
                            for(j in 1:(ncol(ftpdirs)))
                            {
                                mtr[,j] <- replace(mtr[,j], 1:nrow(ftpdirs),ftpdirs[,j])
                            }
                        }
                        mtr[,todo[u]] <- replace(mtr[,todo[u]], 1:length(FtpDayDirs),FtpDayDirs)
                        ftpdirs <- mtr
            
                        write.table(ftpdirs,file.path(auxPATH,paste(server,"_ftp.txt",sep=""),fsep="/"))
                    }
                }
            }
        }
    }
return(invisible(NULL))
}


