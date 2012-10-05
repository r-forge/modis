# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3

whittaker.raster <- function(vi, wt=NULL, inT=NULL, groupYears=TRUE, timeInfo = orgTime(vi), lambda = 500, nIter= 5, outPath = "./")
{
    
    dir.create(outPath,showWarnings=FALSE)
    outPath <- normalizePath(outPath, winslash = "/", mustWork = TRUE)

    if(!require(ptw))
    {
        stop("For using the whittaker filter please install the package: install.package('ptw')") 
    }
    
    if(!inherits(vi,"Raster")) 
    {
        vi <- stack(vi)
    }
    
    if(!inherits(wt,"Raster") & !is.null(wt)) 
    {
        wt <- stack(wt)
    }

    if(!inherits(inT,"Raster") & !is.null(inT)) 
    {
        inT <- stack(inT)
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
    
    #TEMP
    NAflag=-10000
    
    b <- list()
    if (groupYears)
    {
        for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
        {
            y <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
            b[[a]] <- brick(raster(vi),nl=as.integer(sum(format(timeInfo$outputLayerDates,"%Y")==y)), values=FALSE)
            b[[a]] <- writeStart(b[[a]], filename=paste(outPath,"/NDVI_",nameL,inlam,"_year",y,".tif",sep=""),overwrite=TRUE,datatype="INT2S",NAflag=NAflag)
        }
    
    } else {
        b[[1]] <- brick(raster(vi),nl=as.integer(length(timeInfo$outSeq)), values=FALSE)  
        b[[1]] <- writeStart(b[[1]], filename=paste(outPath,"/NDVI_",nameL,inlam,"_fullPeriod.tif",sep=""),overwrite=TRUE,datatype="INT2S",NAflag=NAflag)
    }
        
    tr <- blockSize(vi)
    
    cluster <- raster:::.doCluster()
    if (cluster)
    {
        cl <- getCluster()
        on.exit(endCluster())
        nodes <- getOption("rasterClusterCores")
        
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
    # TODO
    minval      <- -2000
    bitShift    <-  2 
    bitMask     <- 15
    bitTreshold <-  6
    
    val    <- getValues(vi, row=tr$row[l], nrows=tr$nrows[l])
    mtrdim <- dim(val)
    set0   <- val <= minval
    set0[is.na(val)] <- TRUE

    
    if (!is.null(wt))
    {

        require(bitops)
        wtu <- getValues(wt, row=tr$row[l], nrows=tr$nrows[l])
        set0[wtu==0] <- TRUE
        wtu <- bitAnd(bitShiftR(wtu, bitShift ), bitMask)
        
        if(!is.null(bitTreshold))
        {
            set0[wtu > bitTreshold] <- TRUE
        }
        
        # turn upsidedown wtu values
        wtu <- ((-1) * (wtu - bitMask))/bitMask # bitMask is the maximum possible value in the VI Qual Mask in MODIS: "1111" 
        wtu <- matrix(wtu,nrow=mtrdim[1],ncol=mtrdim[2])
        
    } else
    {
        wtu <- matrix(1,nrow=mtrdim[1],ncol=mtrdim[2])
    }
    
    if (inherits(inT,"Raster"))
    {
        inTu  <- getValues(inT, row=tr$row[l], nrows=tr$nrows[l])
        inTu  <- repDoy(inTu,timeInfo,bias=timeInfo$inSeq[1]-1)
        set0[is.na(inTu)] <- TRUE
        inTu[set0] <- 0
    } else 
    {
        inTu <- matrix(timeInfo$inSeq,nrow=mtrdim[1],ncol=mtrdim[2],byrow=TRUE)
    }

    wtu[set0] <- 0
    val[set0] <- 0    

    r <- whittakerMtr(vali=val, wti=wtu, inTi=inTu, timeInfo=timeInfo, lambda=lambda, nIter=nIter, minVal=5)
    r[rowSums(abs(r))==0,] <- NAflag
return(r)
}

    if (!cluster)
    {    
        for ( i in seq_along(tr$row) )
        {    
            res <- clFun(i)
            res <- round(res)
    
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
            sendCall(cl[[i]], clFun, i, tag=i)
        }
    
        for (i in 1:tr$n)
        {
            d <- recvOneData(cl)
    
            if (!d$value$success)
            {
                stop("cluster error in Row:", tr$row[d$value$tag],"\n")
            }
            
            ind <- d$value$tag
            d$value$value <- round(d$value$value)
            
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
                sendCall(cl[[d$node]], clFun, ni, tag=ni)
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
            write.table(x=timeInfo$outputLayerDates[format(timeInfo$outputLayerDates,"%Y")==y],file=paste(outPath,"/LayerDates_NDVI_",nameL,inlam,"_year",y,sep=""),row.names=FALSE,col.names=FALSE)
        } else
        {
            write.table(x=timeInfo$outputLayerDates,file=paste(outPath,"/LayerDates_NDVI_",nameL,inlam,"fullPeriod",sep=""),col.names=FALSE,row.names=FALSE)
        }
    }

return(NULL)
}

# vali=val;wti=wtu;inTi=inTu;timeInfo=timeInfo;lambda=lambda
whittakerMtr <- function(vali,wti=NULL,inTi=NULL,timeInfo=NULL,lambda=NULL, nIter= 5, minVal=5)
{
    
    vali <- t(vali)
    
    yRow <- nrow(vali)
    yCol <- ncol(vali)

    if(is.null(wti))
    {
        wti <- matrix(1,nrow=yRow,ncol=yCol)
    } else {
        wti <- as.matrix(wti)
        wti <- t(wti)
    }
                    
    if(is.null(inTi))
    {
        inTi <- matrix(1:yRow,ncol=yCol,nrow=yRow)
    } else {
        inTi <- as.matrix(inTi)
        # if inT is a fixed vector (i.e.: from filename of Landsat of length nrow(x) (==nlayer) create a matrix with 1:nlayer for each col.
        if(ncol(inTi)==1)
        {
            inTi <- matrix(inTi[,1],ncol=yCol,nrow=yRow)            
        } else {
            inTi <- t(inTi)
        }
    }
    
    # generate output matrix    
    if (is.null(timeInfo))
    {
        outTi <- inTi
        out   <- matrix(NA, nrow=nrow(inTi), ncol=yCol)
    } else {
        outTi <- as.matrix(timeInfo$outSeq)
        if (ncol(outTi)==1)
        {
            outTi <- matrix(outTi, nrow=length(outTi), ncol=yCol)            
        }
        out <- matrix(NA, nrow=nrow(outTi), ncol=yCol)
    }
        
    # minimum "minVal" input values for filtering 
    Cvec <- (colSums(wti!=0) > minVal)
    Cvec <- (1:yCol)[Cvec]

    for (u in Cvec)
    {
        inTo    <- inTi[,u]
        msk     <- inTo > 0
        inTiVec <- inTo[msk]
        valVec  <- rep(NA,max(timeInfo$inSeq,timeInfo$outSeq) - (min(timeInfo$inSeq,timeInfo$outSeq)-1))
        valVec[inTiVec] <- vali[msk,u]
        wtVec   <- rep(0,max(inTiVec,na.rm=TRUE))
        wtVec[inTiVec]  <- wti[msk,u]
        s <- MODIS:::miwhitatzb1(orgTS=valVec, w=wtVec, l=lambda, maxiter=nIter)
        out[,u] <- s[outTi[,u]]
    }

return(t(out))
}
    
