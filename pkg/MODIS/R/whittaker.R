# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3

# maybe to add: derivate=1
whittaker.raster <- function(vi, w=NULL, t=NULL, groupYears=TRUE, timeInfo = orgTime(vi), lambda = 500, nIter= 5, outPath = "./",...)
{
    # debug 
    # w=wt; t=inT; groupYears=TRUE; lambda = 500; nIter= 5; outPath = "./"
    # w=NULL; t=NULL; groupYears=TRUE; lambda = 500; nIter= 5; outPath = "./SUB/"

    # args <- list(bitShift=2,bitMask=15,threshold=6)
    # args <- list(bitShift=2,bitMask=15)
    # args <- list()
    args <- list(...)
    bitShift  <- args$bitShift
    bitMask   <- args$bitMask
    threshold <- args$threshold
    NAflag    <- args$NAflag
    
    if (is.null(args$minDat))
    {
        mindat <- 5
    } else 
    {
        minDat <- args$minDat
    }
       
    dir.create(outPath,recursive=TRUE,showWarnings=FALSE)
    outPath <- normalizePath(outPath, winslash = "/", mustWork = TRUE)

    if(!require(ptw))
    {
        stop("For using the the whittaker filter please install the package: install.package('ptw')") 
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
   
    tsLength <- as.numeric(max(timeInfo$inputLayerDates) - (min(timeInfo$inputLayerDates)-1)) 
    tsLayers <- length(unique(timeInfo$inputLayerDates))
    
    inlam  <- lambda
    if (is.character(lambda))
    {
        cat("Using fixed 'lambda':",lambda,"\n")
        nameL <- "fixedLambda"
    } else 
    {
        lambda <- lambda*(tsLength/365)
        cat("Yearly 'lambda' is:",inlam,"\nNow changed with lambda*('length of input data period in days'/365) to:",lambda,"\n")
        nameL <- "YearlyLambda"
    }
    
    lambda <- as.numeric(lambda)

    b <- list()
    if (groupYears)
    {
        for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
        {
            y <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
            b[[a]] <- brick(raster(vi),nl=as.integer(sum(format(timeInfo$outputLayerDates,"%Y")==y)), values=FALSE)
            b[[a]] <- writeStart(b[[a]], filename=paste(outPath,"/NDVI_",nameL,inlam,"_year",y,".tif",sep=""),...)
        }
    
    } else 
    {
        b[[1]] <- brick(raster(vi),nl=as.integer(length(timeInfo$outSeq)), values=FALSE)  
        b[[1]] <- writeStart(b[[1]], filename=paste(outPath,"/NDVI_",nameL,inlam,"_fullPeriod.tif",sep=""),...)
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
    mtrdim <- dim(val)

    set0   <- matrix(FALSE,nrow=mtrdim[1], ncol=mtrdim[2])
    set0[is.na(val)] <- TRUE
    
    if (!is.null(w))
    {
        wtu <- getValues(w, row=tr$row[l], nrows=tr$nrows[l])
        
        # is it not a weight info [0-1]?
        if(max(wtu,na.rm=TRUE) > 1)
        {
            if(is.null(bitShift) | is.null(bitMask))
            {
                # try to detect VI usefulness layer
                bits <- MODIS:::detectBitInfo(vi,"VI usefulness",warn=FALSE)
                if(is.null(bitShift))
                {
                    bitShift <- bits$bitShift
                }
                if(is.null(bitMask))
                {
                    bitMask <- bits$bitMask
                }
            }
             
            if(is.null(bitShift))
            {
                stop("Could not extract 'bits' for weighting from this product. Use 'makeWeights' function to generate weightings manualy!")
            }
            wtu  <- makeWeights(wtu, bitShift = bitShift, bitMask = bitMask, threshold = threshold, decodeOnly = FALSE)
        }
        set0[wtu==0] <- TRUE

    } else
    {
        wtu <- matrix(1,nrow=mtrdim[1],ncol=mtrdim[2])
    }
    
    if (inherits(t,"Raster"))
    {
        inTu <- getValues(t, row=tr$row[l], nrows=tr$nrows[l])
        inTu <- repDoy(inTu,timeInfo,bias=timeInfo$inSeq[1]-1)
        set0[ inTu <= 0 ] <- TRUE
        set0[is.na(inTu)] <- TRUE
        inTu[set0] <- 0
    } else 
    {
        inTu <- matrix(timeInfo$inSeq,nrow=mtrdim[1],ncol=mtrdim[2],byrow=TRUE)
    }

    # the entire info to use or nor a pix in in "wtu"
    wtu[set0] <- 0
    val[set0] <- 0    

    r <- whittakerMtr(vali=val, wti=wtu, inTi=inTu, timeInfo=timeInfo, lambda=lambda, nIter=nIter, minDat=minDat)
    r[rowSums(abs(r))==0,] <- NA

return(r)
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
               
            if (groupYears)
            {
                for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
                {
                    y      <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
                    b[[a]] <- writeValues(b[[a]], res[,format(timeInfo$outputLayerDates,"%Y")==y], tr$row[i])
                }   
            } else 
            {
                b[[1]]  <- writeValues(b[[1]], res, tr$row[i])
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
            
            ind <- d$value$tag
            
            if(doround)
            {
                d$value$value <- round(d$value$value)
            }

            #####
            if (groupYears)
            {
                for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
                {
                    y      <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
                    b[[a]] <- writeValues(b[[a]], d$value$value[,format(timeInfo$outputLayerDates,"%Y")==y], tr$row[ind])
                }   
            } else 
            {
                b[[1]]  <- writeValues(b[[1]], d$value$value, tr$row[ind])
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
        if (groupYears)
        {
            y <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
            write.table(x=timeInfo$outputLayerDates[format(timeInfo$outputLayerDates,"%Y")==y], 
                file=paste(outPath,"/LayerDates_NDVI_",nameL,inlam,"_year",y,sep=""),row.names=FALSE,col.names=FALSE)
        } else
        {
            write.table(x=timeInfo$outputLayerDates, file=paste(outPath,"/LayerDates_NDVI_",nameL,inlam,"fullPeriod",sep=""), 
                col.names=FALSE,row.names=FALSE)
        }
    }

return(NULL)
}


# vali=val;wti=wtu;inTi=inTu;timeInfo=timeInfo;lambda=lambda;minDat=5
whittakerMtr <- function(vali,wti,inTi,timeInfo=NULL, lambda, nIter = 5, minDat=5)
{
    vali <- t(as.matrix(vali))
    wti  <- t(as.matrix(wti))
    inTi <- t(as.matrix(inTi))
       
    yRow <- nrow(vali)
    yCol <- ncol(vali)
    
    # generate output matrix    
    if (is.null(timeInfo))
    {
        outTi <- inTi
        out   <- matrix(NA, nrow=yRow, ncol=yCol)
    } else 
    {
        outTi <- matrix(timeInfo$outSeq, nrow=length(timeInfo$outSeq), ncol=yCol)            
        out   <- matrix(NA, nrow=nrow(outTi), ncol=yCol)
    }
        
    # minimum "minDat" input values for filtering 
    Cvec <- (colSums(wti!=0) >= minDat)
    Cvec <- (1:yCol)[Cvec]

    inTi[inTi<=0] <- FALSE
    wtVec1 <- valVec1 <- rep(0,max(inTi))

    win <- options("warn")
    options(warn=-1)
    for (u in Cvec)
    {   
        valVec <- valVec1
        wtVec  <- wtVec1
        valVec[inTi[,u]] <- vali[,u]
        wtVec[inTi[,u]]  <- wti[,u]
        # s <- MODIS:::miwhitatzb2(orgTS=valVec, w=wtVec, l=lambda, maxiter=nIter)
        # taken form A. Lobo
        for(i in 1:nIter)
        {
            fTS <- whit2(valVec,w=wtVec,lambda=lambda)
            valVec[valVec < fTS] <- fTS[valVec < fTS]
        }
        #
        out[,u] <- fTS[outTi[,u]]
    }
    options(warn=win$warn)
    
    return(t(out))
}
    

