# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3

# product="M.D13Q1"; collection=NULL; server="LPDAAC"; begin=NULL; end=NULL; forceCheck=FALSE; wait=0; stubbornness=1

getStruc <- function(product, collection=NULL, server="LPDAAC", begin=NULL, end=NULL, forceCheck=FALSE, wait=1, stubbornness=10)
{
    server <- toupper(server)
    if(!server %in% c("LPDAAC","LAADS"))
    {
        stop("getStruc() Error! Server must be or 'LPDAAC' or 'LAADS'")
    }
    
    opts <- combineOptions()
    
    sturheit <- stubborn(level=stubbornness)
    
    #########################
    # Check Platform and product
    product <- getProduct(x=product,quiet=TRUE)
    # Check collection
    if (!is.null(collection))
    {
        product$CCC <- getCollection(product=product,collection=collection) 
    }
    if (length(product$CCC)==0)
    {
        product$CCC <- getCollection(product=product) # if collection isn't provided, this gets the newest for the selected products.
    }

    dates <- transDate(begin=begin,end=end)
    today <- as.Date(format(Sys.time(),"%Y.%m.%d"),format="%Y.%m.%d")
    ########################

    # load aux
    if (!file.exists(paste0(opts$auxPath,server,"_ftp.txt")))
    {
      opts$auxPath <- setPath(opts$auxPath)
      invisible(file.copy(file.path(find.package('MODIS'),'external',paste0(server,"_ftp.txt")),paste0(opts$auxPath,server,"_ftp.txt")))
    }
    ftpdirs <- read.table(paste0(opts$auxPath,server,"_ftp.txt"),stringsAsFactors=FALSE)
    good    <- sapply(colnames(ftpdirs), function(x) {length(strsplit(x,"\\.")[[1]])==2})
    ftpdirs <- ftpdirs[,good] # remove wrong cols
    
    # clean the data.frame for "FALSE" and "NA"
    
    res <- vector(length=ncol(ftpdirs),mode="list")
    for (ag in 1:ncol(ftpdirs))
    {
      iu <- ftpdirs[,ag]
      iu <- iu[!is.na(iu)]
      iu <- iu[iu!=FALSE]
      res[[ag]] <- iu
    }
    
    mtr <- matrix(NA,nrow=max(sapply(res,length)),ncol=length(res))
    colnames(mtr) <- names(ftpdirs)    
    
    for(j in seq_along(ftpdirs))
    {
      mtr[,j] <- replace(mtr[,j], 1:length(res[[j]]),res[[j]])
    }
    write.table(mtr,paste0(opts$auxPath,server,"_ftp.txt"))
   
    for (i in seq_along(product$PRODUCT))
    {
      todo <- paste(product$PRODUCT[i],".",product$CCC[[which(names(product$CCC)==product$PRODUCT[i])]],sep="")
      
      for(u in seq_along(todo))
      {
        path <- genString(x=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],local=FALSE)
        
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
            } else 
            {
            getIT <- FALSE
            }
          } else 
          {
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
                cat("Try:",g," \r")
                FtpDayDirs <- try(filesUrl(startPath))
                cat("             \r")
                if(exists("FtpDayDirs"))
                {    
                  break
                }
                Sys.sleep(wait)
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
              years <- try(filesUrl(startPath))
              if(g < (sturheit/2))
              {
                Sys.sleep(wait)
              } else
              {
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
            once  <- TRUE
            for (g in 1:sturheit)
            {
              cat("                          \r")
              cat("Getting day(s) try:",g,"\r") # for",todo[u],"
              p <- try(filesUrl(Ypath)) # async=T!
              if(g < (sturheit/2))
              {
                Sys.sleep(wait)
              } else 
              {
                if(once) 
                {
                  cat("Server problems, trying with 'wait=",max(30,wait),"\n")
                }
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
              FtpDayDirs <- as.character(unlist(sapply(p, function(pb,l=0) 
                {
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
            cat("Couldn't get structure from",server,"server using with offline information!\n")
            return(invisible(NULL))        
          } else if (FtpDayDirs==FALSE)
          {
            cat("Couldn't get structure from",server,"server using with offline information!\n")
            return(invisible(NULL))        
          } else
          {
            rowdim <- max(nrow(ftpdirs),length(FtpDayDirs))
            if (todo[u] %in% colnames(ftpdirs)) 
            { 
              coldim <- ncol(ftpdirs)
              colnam <- colnames(ftpdirs)
            } else 
            {
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
            write.table(ftpdirs,paste0(opts$auxPath,server,"_ftp.txt"))
          }
        }
      }
    }
  }
  return(invisible(NULL))
}


