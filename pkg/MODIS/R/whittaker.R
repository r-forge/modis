# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3

# maybe to add: derivate=1
whittaker.raster <- function(vi, w=NULL, t=NULL, groupYears=TRUE, timeInfo = orgTime(vi), lambda = 500, nIter= 3, collapse=FALSE, outDirPath = "./", removeOutlier=FALSE, threshold=NULL, ...)
{
    # debug 
    # w=wt; t=inT; groupYears=TRUE; lambda = 3000; nIter= 3; outDirPath = "./"
    # w=NULL; t=NULL; groupYears=TRUE; lambda = 500; nIter= 5; outDirPath = "./SUB/"

    # opt <- list(bitShift=2,bitMask=15,threshold=6)
    # opt <- list(bitShift=2,bitMask=15)
    # opt <- list()
        
    opt       <- combineOptions(...)
    bitShift  <- opt$bitShift
    bitMask   <- opt$bitMask
    threshold <- opt$threshold
    NAflag    <- opt$NAflag
    
    dataFormat <- opt$dataFormat
    rasterOut  <- writeFormats()
    
    if(dataFormat %in% rasterOut[,"name"])
    {
        dataFormat <- raster:::.defaultExtension(dataFormat)
    } else
    {
        stop("Argument dataFormat='",dataFormat,"' in 'smooth.spline.raster()' is unknown/not supported. Please run 'writeFormats()' (column 'name') so list available dataFormat's")
    }
    
    if (is.null(opt$minDat))
    {
        minDat <- 3
    } else 
    {
        minDat <- opt$minDat
    }
       
    dir.create(opt$outDirPath,recursive=TRUE,showWarnings=FALSE)
    opt$outDirPath <- normalizePath(opt$outDirPath, winslash = "/", mustWork = TRUE)

    if(!require(ptw))
    {
        stop("In order to use the the whittaker filter please install 'ptw': install.package('ptw')") 
    }
    
    if(!inherits(vi,"Raster")) 
    {
        vi <- stack(vi)
    }
    
    if(!inherits(w,"Raster") & !is.null(w)) 
    {
        w <- stack(w)
    }

    if(!inherits(t,"Raster") & !is.null(t)) 
    {
        t <- stack(t)
    }
    
    if(collapse)
    {
        tsLength <- 365        
        tsLayers <- length(unique(timeInfo$inputLayerDates))
    } else
    {
        tsLength <- as.numeric(max(timeInfo$inputLayerDates) - (min(timeInfo$inputLayerDates)-1)) 
        tsLayers <- length(unique(timeInfo$inputLayerDates))
    }
    
    inlam  <- lambda
    if (is.character(lambda))
    {
        cat("Using fixed 'lambda':",lambda,"\n")
        nameL <- "FixedLambda"
    } else 
    {
        lambda <- lambda*(tsLength/365)
        if(!collapse)
        {
            cat("Yearly 'lambda' is:",inlam,"\nNow changed with lambda*('length of input data period in days'/365) to:",lambda,"\n")
            nameL <- "YearlyLambda"
        } else 
        {
            outDoys <- seq(1,365,by=as.numeric(round((max(timeInfo$outputLayerDates)-min(timeInfo$outputLayerDates))/length(timeInfo$outputLayerDates))))
            cat("'lambda':",inlam,"\n")
            nameL <- "Lambda"
        }    
    }
    
    lambda <- as.numeric(lambda)

    b <- list()
    if (collapse)
    {
        b[[1]] <- brick(raster(vi),nl=length(outDoys), values=FALSE)  
        b[[1]] <- writeStart(b[[1]], filename=paste(opt$outDirPath,"/NDVI_",nameL,inlam,"_sumarised",format(min(timeInfo$outputLayerDates),"%Y"),"to",format(max(timeInfo$outputLayerDates),"%Y"),dataFormat,sep=""),...)
    }
    else if (groupYears)
    {
        for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
        {
            y <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
            b[[a]] <- brick(raster(vi),nl=as.integer(sum(format(timeInfo$outputLayerDates,"%Y")==y)), values=FALSE)
            b[[a]] <- writeStart(b[[a]], filename=paste(opt$outDirPath,"/NDVI_",nameL,inlam,"_year",y,dataFormat,sep=""),...)
        }
    } else 
    {
        b[[1]] <- brick(raster(vi),nl=as.integer(length(timeInfo$outSeq)), values=FALSE)  
        b[[1]] <- writeStart(b[[1]], filename=paste(opt$outDirPath,"/NDVI_",nameL,inlam,"_fullPeriod",dataFormat,sep=""),...)
    }

    if(substr(dataType(b[[1]]),1,3) == "FLT")
    {
        doround <- FALSE
    } else
    {
        doround <- TRUE
    }
    if(is.null(NAflag))
    {
        NAflag <- NAvalue(b[[1]])
    }
    
    tr <- blockSize(vi)
    
    cluster <- raster:::.doCluster()
    if (cluster)
    {
        # beginCluster()
        cl <- getCluster()
        on.exit(endCluster())
        nodes <- getOption("rasterClusterCores")

        # MODIS fails to load if not done like that ...        
        clF <- function(i){require(MODIS)}
        for (i in 1:nodes) 
        {
            sendCall(cl[[i]], clF, i, tag=i)
            recvOneData(cl)
        }
        
        # better to be save than sorry:
        clusterEvalQ(cl,require(bitops))
        clusterEvalQ(cl,require(rgdal))
        clusterEvalQ(cl,require(raster))
        clusterEvalQ(cl,require(ptw))
        tr <- MODIS:::blockSizeCluster(vi)
    }    

    cat("Data is in, start processing!\n")
# clusterExport(cl,ls())
###############################
# clusterFuns: 

clFun <- function(l)
{
    val    <- getValues(vi, row=tr$row[l], nrows=tr$nrows[l])
    val    <- t(val)
    mtrdim <- dim(val)

    set0   <- matrix(FALSE,nrow=mtrdim[1], ncol=mtrdim[2])

    # very save and very limited to scaled NDVI (-3000 to +10000)
    set0[is.na(val)]   <- TRUE
    set0[val <= -3000] <- TRUE
    set0[val >  10000] <- TRUE
    
    if (!is.null(w))
    {
        wtu <- getValues(w, row=tr$row[l], nrows=tr$nrows[l])
        
        # is it not a weight info [0-1]?
        if(max(wtu,na.rm=TRUE) > 1)
        {
            if(is.null(bitShift) | is.null(bitMask))
            {
                # try to detect VI usefulness layer
                bits     <- MODIS:::detectBitInfo(vi,"VI usefulness",warn=FALSE)
                bitShift <- bits$bitShift
                bitMask  <- bits$bitMask
            }
             
            if(is.null(bitShift))
            {
                stop("Could not extract 'bits' for weighting from this product. Use '?makeWeights' function to generate weightings manualy!")
            }
            wtu  <- makeWeights(wtu, bitShift = bitShift, bitMask = bitMask, threshold = threshold, decodeOnly = FALSE)
        }
        wtu <- t(wtu)
        set0[wtu==0] <- TRUE
    } else
    {
        # if no weighting info is available then weight = 1
        wtu <- matrix(1,nrow=mtrdim[1],ncol=mtrdim[2])
    }
    
    if (inherits(t,"Raster"))
    {
        inTu <- getValues(t, row=tr$row[l], nrows=tr$nrows[l])
        inTu <- repDoy(inTu,timeInfo,bias=timeInfo$inSeq[1]-1)
        inTu <- t(inTu)
        set0[ inTu <= 0 ] <- TRUE
        set0[is.na(inTu)] <- TRUE
        inTu[set0] <- 0
    } else 
    {
        if (collapse)
        {
            inTu <- matrix(timeInfo$inDoys,nrow=mtrdim[1],ncol=mtrdim[2],byrow=FALSE)
        } else
        {       
            inTu <- matrix(timeInfo$inSeq,nrow=mtrdim[1],ncol=mtrdim[2],byrow=FALSE)
        }
    }
    # the entire info to use or not a pix is in "wtu"
    wtu[set0] <- 0
    val[set0] <- 0    

    if (collapse)
    {
        out <- matrix(NA, nrow=length(outDoys), ncol=mtrdim[2])
        collapser <- outDoys
    } else
    {
        out <- matrix(NA, nrow=length(timeInfo$outSeq), ncol=mtrdim[2])
        collapser <- timeInfo$outSeq
    }      
    
    if(removeOutlier)
    {
        if (is.null(threshold))
        {
            if(max(val,na.rm=TRUE)>1)
            {   
                threshold <- 2000
            } else
            {
                threshold <- 0.2
            }
        }
        kickOutlier <- function(vals,weights,lambda,threshold)
        {
            fTS <- whit2(vals,w=weights,lambda=lambda)
            weights[weights==1][abs(vals[weights==1]-fTS[weights==1]) > threshold] <- 0            
            return(weights)    
        }
    } else
    {
        # if outlier removal is FALSE generate a faky function to avoid a per pixel "if"
        threshold <- NULL
        kickOutlier <- function(vals,weights,lambda,threshold)
        {
            return(weights)
        }       
    }

    # minimum "minDat" input values for filtering 
    Cvec   <- (colSums(wtu > 0) >= minDat)
    Cvec   <- (1:mtrdim[2])[Cvec]
    ind    <- inTu > 0    
    wtVec0 <- valVec0 <- rep(0,max(inTu))
        
    win <- options("warn")
    options(warn=-1)
    for (u in Cvec)
    {   
        valVec <- valVec0
        wtVec  <- wtVec0
        index  <- ind[,u]
        doys   <- inTu[index,u]

        valVec[doys] <- val[index,u]
        wtVec[doys]  <- wtu[index,u]

        wtVec <- kickOutlier(vals=valVec,weights=wtVec,lambda=lambda,threshold=threshold)
        
        # taken form A. Lobo implementation in R
        for(i in 1:nIter)
        {
            fTS <- whit2(valVec,w=wtVec,lambda=lambda)
            valVec[valVec < fTS] <- fTS[valVec < fTS]
        }
        #
        out[,u] <- fTS[collapser]
    }
    options(warn=win$warn)
    out[,colSums(abs(out))==0] <- NA
return(t(out))
}

    if (!cluster)
    {    
        for (i in seq_along(tr$row))
        {    
            res <- clFun(i)
            
            if(doround)
            {
                res <- round(res)
            }
               
            if (groupYears & !collapse)
            {
                for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
                {
                    y      <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
                    b[[a]] <- writeValues(b[[a]], res[,format(timeInfo$outputLayerDates,"%Y")==y], tr$row[i])
                }   
            } else 
            {
                b[[1]] <- writeValues(b[[1]], res, tr$row[i])
            }
        }       
    } else
    {
        for (i in 1:nodes) 
        {
            sendCall(cl[[i]], fun = clFun, args = i, tag=i)
        }
    
        for (i in 1:tr$n)
        {
            d <- recvOneData(cl)
    
            if (!d$value$success)
            {
                stop("cluster error")
            }
            
            if(doround)
            {
                d$value$value <- round(d$value$value)
            }

            #####
            if (groupYears & !collapse)
            {
                for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
                {
                    y      <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
                    b[[a]] <- writeValues(b[[a]], d$value$value[,format(timeInfo$outputLayerDates,"%Y")==y], tr$row[d$value$tag])
                }   
            } else 
            {
                b[[1]]  <- writeValues(b[[1]], d$value$value, tr$row[d$value$tag])
            }
            #####        
    
            ni <- nodes + i
            if (ni <= tr$n)
            {
                sendCall(cl[[i]], fun = clFun, args = ni, tag=ni)
            }
        
        }
    }
###############################
    
    for (a in seq_along(b))
    {    
        b[[a]] <- writeStop(b[[a]])
        if (groupYears & !collapse)
        {
            y <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
            write.table(x=timeInfo$outputLayerDates[format(timeInfo$outputLayerDates,"%Y")==y], 
                file=paste(opt$outDirPath,"/NDVI_",nameL,inlam,"_year",y,sep=""),row.names=FALSE,col.names=FALSE)
        } else 
        {
            if (collapse)
            {
                write.table(x=outDoys, file=paste(opt$outDirPath,"/NDVI_",nameL,inlam,"_sumarised",format(min(timeInfo$outputLayerDates),"%Y"),"to",format(max(timeInfo$outputLayerDates),"%Y"),sep=""), 
                    col.names=FALSE,row.names=FALSE)
            } else
            {
                write.table(x=timeInfo$outputLayerDates, file=paste(opt$outDirPath,"/NDVI_",nameL,inlam,"fullPeriod",sep=""), 
                    col.names=FALSE,row.names=FALSE)
            }
        }
    }
}



