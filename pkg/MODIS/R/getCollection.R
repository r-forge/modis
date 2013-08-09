# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3


getCollection <- function(product,collection=NULL,newest=TRUE,forceCheck=FALSE,as="character",quiet=TRUE)
{

    opts <- combineOptions()

    ####
    # checks for product
    if (missing(product))
    {
        stop("Please provide a valid product")
    }
    productN <- getProduct(x=product,quiet=TRUE)
    if (is.null(productN)) 
    {
        stop("Unknown product")
    }
    # load aux
    if (!file.exists(paste0(opts$auxPath,"collections.RData"))) # on the very first call use the delivered pre-updated version    
    {
        opts$auxPath <- MODIS:::setPath(opts$auxPath)
        invisible(file.copy(file.path(find.package("MODIS"), "external","collections.RData"), file.path(opts$auxPath,"collections.RData",fsep="/")))
        unlink(file.path(opts$auxPath,"collections.txt",fsep="/"))
    }
    load(paste0(opts$auxPath,"collections.RData"))
    
    # clean file
    MODIS <- ftpdirs[,grep(colnames(ftpdirs),pattern="M.D")]
    SRTM  <- ftpdirs[,grep(colnames(ftpdirs),pattern="SRTM")]
    ftpdirs <- cbind(MODIS,SRTM)

    if (productN$SENSOR[1] !="C-Band-RADAR")
    {    
        if (forceCheck | sum(!productN$PRODUCT %in% colnames(ftpdirs))>0) 
        {
	        if (! require(RCurl) ) 
	        {
	    	    stop("You need to install the 'RCurl' package: install.packages('RCurl')")
	        }
		    sturheit <- MODIS:::stubborn(level=opts$stubbornness)
		    
    		for (i in 1:length(unique(productN$PF1))) 
    		{		
    		    ftp <- paste("ftp://e4ftl01.cr.usgs.gov/",unique(productN$PF1)[i],"/",sep="")
    			cat("Updating collections from LP_DAAC for platform:",unique(productN$PLATFORM)[i],"\n")
    
    			if(exists("dirs")) 
    			{
    			    rm(dirs)
    			}
    			for (g in 1:sturheit)
    			{
    			    try(dirs <- getURL(ftp),silent=TRUE)
    				if(exists("dirs")){break}
    			} 
    
    			if (!exists("dirs")) 
    			{
    				cat("FTP is not available, using stored information from previous calls (this should be mostly fine)\n")
    			} else 
    			{
    				dirs <- unlist(strsplit(dirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"})) # Is this enought? Mac? Solaris?....
    				dirs <- dirs[substr(dirs, 1, 1)=='l'] 
    				dirs <- sapply(strsplit(dirs, "/"), function(x){x[length(x)]})	
    			
    				prod <- sapply(dirs,function(x){strsplit(x, "\\.")[[1]][1]})
    				coll <- sapply(dirs,function(x){strsplit(x, "\\.")[[1]][2]})
    		
    				mtr  <- cbind(prod,coll)
    				mtr  <- tapply(INDEX=mtr[,1],X=mtr[,2],function(x){x})
    		
    				maxrow <- max(nrow(ftpdirs),sapply(mtr,function(x)length(x)))
    				
    				basemtr <- matrix(NA,ncol=nrow(mtr), nrow = maxrow)
    				colnames(basemtr) <- names(mtr)
    		
    				for(u in 1:ncol(basemtr)) 
    				{
    					basemtr[1:length(mtr[[u]]),u] <- mtr[[u]]
    				}
    				
    				if (nrow(ftpdirs) < maxrow & nrow(ftpdirs) > 0) 
    				{
    					ftpdirs <- rbind(ftpdirs,as.data.frame(NA,nrow=(maxrow-nrow(ftpdirs)), ncol=ncol(ftpdirs)))
    				}
    					
    				if (ncol(ftpdirs)==0)
    				{ # relevant only for time
    					ftpdirs <- data.frame(basemtr) # create new
    				} else 
    				{ # or update the available one
    					indX    <- colnames(ftpdirs) %in% colnames(basemtr) 
    					ftpdirs <- cbind(ftpdirs[,!indX],basemtr)
    				}
    			}
    		}
    	}
    }
    save(ftpdirs,file = file.path(opts$auxPath,"collections.RData",fsep="/"))
    ind <- which(colnames(ftpdirs)%in%productN$PRODUCT)

    if(length(ind)==1)
    {
	    res <- list(ftpdirs[,ind])
	    names(res) <- colnames(ftpdirs)[ind]
    } else if (length(ind)>=1) 
    {
	    res <- as.list(ftpdirs[,ind])
    } else 
    {
	    stop("No data available, check product input?") # should not happen getProduct() should catch that before
    }

    res <- lapply(res, function(x){as.numeric(as.character(x[!is.na(x)]))})

    if (!is.null(collection)) 
    { # if collection is provided...return formatted collection or 'FALSE'
	
	    isOk <- lapply(res,function(x)
	    {
		    if (as.numeric(collection) %in% x)
		    {
				as.numeric(collection)
			} else 
			{
				FALSE		
			}
		})
	
	    if (sum(isOk==FALSE)==length(isOk)) 
	    {
		    cat("Product(s) not awailable in collection '",collection,"'. Try 'getCollection('",productN$request,"',newest=FALSE,forceCheck=TRUE)'\n",sep="")
	        return(invisible(isOk))
	    } else if (sum(isOk==FALSE)>0 & sum(isOk==FALSE)<length(isOk))
	    {
		    cat("Not all the products in your input are available in collection '", collection,"'. Try 'getCollection('", productN$request, "', newest=FALSE, forceCheck=TRUE)'\n", sep="")
	    }

	    res <- isOk[isOk!=FALSE]

    } else if (newest) 
    {
	    if(!quiet) {cat("No Collection specified getting the newest for",productN$PRODUCT,"\n",sep=" ")}

	    res <- lapply(res,function(x)
	    { #select the newest
		    x[order(sapply(x,function(c){		
		    s <- nchar(c)-1
		    if (s==0) 
		    {
		    	c
		    } else 
		    {
		    	c/as.numeric(paste(1,rep(0,s),sep=""))
		    }}),decreasing=TRUE)][1]
		})
    }   

    if (as=="character") 
    {
	    res <- lapply(res,function(x){sprintf("%03d",x)})	
    }
return(res)
}

