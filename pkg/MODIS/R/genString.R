# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : February 2012
# Licence GPL v3

# 'date' is an EXISTING date! result from getStruc() and passed as single date! For format see ?transDate

genString <- function(x, date=NULL, collection=NULL, what="images", local=TRUE, remote=TRUE, ...)
{
    if (missing(x)) 
    {
        stop(".genString Error: 'x' must be a HDF-file or MODIS-product name!")
    }

    opts <- MODIS:::combineOptions(...)
    remotePath <- localPath <- NULL
    
    opts$auxPath <- MODIS:::setPath(opts$auxPath)
    
    product <- getProduct(x=x,quiet=TRUE)
    if(length(product$PRODUCT)>1)
    {
        warning(".genString() does not support multiple products! Generating 'path' only for the first:", product$PRODUCT[1], "\n")
        product <- lapply(product,function(x){x[1]}) # take only the first argument
    }
    
    if(length(product$CCC)==0)
    {
        product$CCC <- getCollection(product=product$PRODUCT,collection=collection)[[1]]
    }
    
    if (!is.null(date)) 
    { # date can be supplied as argument! 
        product$DATE <- list(paste("A",transDate(begin=date)$beginDOY,sep="")) # generates MODIS file date format "AYYYYDDD"
    }
    
    if (is.null(product$DATE)) # if x is a PRODUCT and date is not provided 
    { 
        if (local) 
        {
            tempString <- strsplit(opts$arcStructure,"/")[[1]]
            
            string <- list()
            l=0
            for (i in 1:length(tempString))
            {
                s <- strsplit(tempString[i],"\\.")[[1]]
            
                if (length(s)>0) 
                {
                    tmp <- list()
                        for (u in 1:length(s))
                        {
                            if (s[u] %in% c("DATE","YYYY","DDD")) 
                            {
                                if (product$PRODUCT!="SRTM")
                                {
                                    tmp[[u]] <- s[u]
                                }
                            } else 
                            {
                                tmp[[u]] <- MODIS:::getPart(x=product,s[u])
                            }
                        }
                    if (length(tmp)>0)
                    {
                        l=l+1
                        string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
                    }
                }
            }
        localPath <- MODIS:::setPath(path.expand(paste0(opts$localArcPath,paste0(unlist(string),collapse="/"))))
        }
        if (remote) 
        {
            namesFTP <- names(MODIS_FTPinfo)
            Hmany <- grep(namesFTP,pattern="^ftpstring*.")
            
            remotePath <- list()
            n = 0
            for (e in Hmany)
            {
       
                stringX <- MODIS:::MODIS_FTPinfo[[e]]
                
                if(length(grep(product$SOURCE,pattern=stringX$name))>0 & what %in% stringX$content)
                {
                    n=n+1                    
                    if(is.null(stringX$variablepath))
                    {
                        remotePath[[n]] <- stringX$basepath
                    } else 
                    {
                        struc      <- stringX$variablepath    
                        tempString <- strsplit(struc,"/")[[1]]
                
                        string <- list()
                        l=0
                        for (i in 1:length(tempString))
                        {
                            s <- strsplit(tempString[i],"\\.")[[1]]
                    
                            if (length(s)> 0) 
                            {
                                l=l+1    
                                tmp <- list()
                                for (u in 1:length(s))
                                {
                                    if (s[u] %in% c("DATE","YYYY","DDD")) 
                                    {
                                        if (product$PRODUCT!="SRTM")
                                        {
                                            tmp[[u]] <- s[u]
                                        }
                                    } else 
                                    {
                                        tmp[[u]] <- MODIS:::getPart(x=product,s[u])
                                    }
                                }                                
                                string[[l]] <- paste(unlist(tmp),sep="",collapse=".")    
                            }
                        }
                    remotePath[[n]] <- path.expand(paste(stringX$basepath,paste(unlist(string),sep="",collapse="/"),sep="/"))
                    }
                    names(remotePath)[n] <- stringX$name
                }
            }
        }
    } else 
    { # if x is a file name
            
        if (local) 
        {
            tempString <- strsplit(opts$arcStructure,"/")[[1]]
        
            string <- list()
            l=0
            for (i in 1:length(tempString))
            {
                s <- strsplit(tempString[i],"\\.")[[1]]
                
                if (length(s)>0)
                {
                    l=l+1
                    tmp <- list()
                    for (u in 1:length(s))
                    {
                        tmp[[u]] <- MODIS:::getPart(x=product,s[u])
                    }
                string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
                }
            } 
        localPath <- MODIS:::setPath(path.expand(paste0(opts$localArcPath,paste0(unlist(string),collapse="/"))))
        }

        if (remote) 
        {
            if (!what %in% c("images","metadata")) 
            {
                stop("Parameter 'what' must be 'images' or 'metadata'")
            }
                     
            namesFTP <- names(MODIS_FTPinfo)
            Hmany <- grep(namesFTP,pattern="^ftpstring*.") # get ftpstrings in ./MODIS_opts.R
        
            remotePath <- list()
            n = 0
            for (e in Hmany)
            {
                stringX <- MODIS_FTPinfo[[e]]
                
                # if (stringX$name %in% eval(parse(text=product$SOURCE)) & what %in% stringX$content)                 
                if(length(grep(product$SOURCE,pattern=stringX$name))>0 & what %in% stringX$content)
                {
                    struc <- stringX$variablepath    
                    tempString <- strsplit(struc,"/")[[1]]
                
                    string <- list()
                    l=0        
                    for (i in 1:length(tempString))
                    {
                        s <- strsplit(tempString[i],"\\.")[[1]]
                
                        if (length(s)>0)
                        {
                            l=l+1
                            tmp <- list()
                            for (u in 1:length(s))
                            {
                                tmp[[u]] <- MODIS:::getPart(x=product,s[u])
                            }
                            string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
                        }
                    }
                    n=n+1
                    remotePath[[n]]      <- path.expand(paste(stringX$basepath,paste(unlist(string),sep="",collapse="/"),sep="/"))
                    names(remotePath)[n] <- stringX$name
                }
            }        
        }
    }        
    return(list(localPath=correctPath(localPath), remotePath=remotePath))
}

