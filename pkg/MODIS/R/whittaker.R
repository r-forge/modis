# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3

# maybe to add: derivate=1

# vx=val[index,u];wx=wtu[index,u];tx=inTu[index,u]
# tmtr <- cbind(vx,wx,tx)

unifyDoubleWM <- function(vx,wx,tx)
{
  vx <- as.numeric(vx)
  wx <- as.numeric(wx)
  tx <- as.numeric(tx)

  double <- tx[duplicated(tx)]
  
  if(length(double)>0)
  {
    double <- unique(double)

    for(i in seq_along(double))
    {
      inx        <- which(tx==double[i])
      vx[inx[1]] <- weighted.mean(vx[inx],w=wx[inx])
      wx[inx[1]] <- max(wx[inx])
      vx         <- vx[-inx[-1]]
      wx         <- wx[-inx[-1]]
      tx         <- tx[-inx[-1]]
    }
  }

  list(vx=vx,wx=wx,tx=tx)
}

unifyDoubleMX <- function(vx,wx,tx)
{
  vx <- as.numeric(vx)
  wx <- as.numeric(wx)
  tx <- as.numeric(tx)

  double <- tx[duplicated(tx)]
  
  if(length(double)>0)
  {
    double <- unique(double)

    for(i in seq_along(double))
    {
      inx <- which(tx==double[i])
      mx  <- which.max(wx[inx])
      vx  <- vx[-inx[-mx]]
      wx  <- wx[-inx[-mx]]
      tx  <- tx[-inx[-mx]]
    }
  }

  list(vx=vx,wx=wx,tx=tx)
}


doCollapse <- function(tx,pillow)
{
  ord <- order(tx)
  txS <- tx[ord]
  
  t0 <- 365 - pillow
  
  tS <- ord[txS >= t0]
  tE <- ord[txS <= pillow]
  
  s0 <- txS[txS >= t0] - t0 
  s1 <- txS + pillow
  s2 <- txS[txS <= pillow] + 365 + pillow 
  
  list(order=c(tS,ord,tE),sequence=c(s0,s1,s2)+1)
}
    
whittaker.raster <- function(vi, w=NULL, t=NULL, timeInfo = orgTime(vi), groupYears=TRUE, lambda = 5000, nIter= 3, collapse=FALSE, outDirPath = "./", removeOutlier=FALSE, threshold=NULL, mergeDoyFun="max", ...)
{
  if(!require(ptw))
  {
    stop("In order to use the the whittaker filter please install 'ptw': install.package('ptw')") 
  }

  # debug 
  # w=wt; t=inT; groupYears=TRUE; lambda = 5000; nIter= 3; outDirPath = "./"; collapse=TRUE; opt <- MODIS:::combineOptions();removeOutlier=FALSE;mergeDoyFun="max"
  # w=NULL; t=NULL; groupYears=TRUE; lambda = 5000; nIter= 5; outDirPath = "./SUB/";collapse=TRUE; opt <- MODIS:::combineOptions();removeOutlier=FALSE;mergeDoyFun="max"

  # opt <- list(bitShift=2,bitMask=15,threshold=6)
  # opt <- list(bitShift=2,bitMask=15)
  # opt <- list()
      
  opt <- combineOptions(...)
  
  opt$outDirPath <- setPath(outDirPath)
  bitShift       <- opt$bitShift
  bitMask        <- opt$bitMask
  threshold      <- opt$threshold

  dataFormat     <- opt$dataFormat
  rasterOut      <- toupper(writeFormats())
    
  if(toupper(dataFormat) %in% rasterOut[,"name"])
  {
    dataFormat <- raster:::.defaultExtension(dataFormat)
  } else
  {
    stop("Argument dataFormat='",dataFormat,"' is unknown/not supported. Please run 'writeFormats()' (column 'name') so list available dataFormat's")
  }

  if (is.null(opt$minDat))
  {
    minDat <- 3 # 3 is very small!
  } else 
  {
    minDat <- opt$minDat
  }
        
  if(collapse)
  {
    fitt <- seq(as.numeric(format(min(timeInfo$outputLayerDates),"%j")),as.numeric(format(max(timeInfo$outputLayerDates),"%j")),by=timeInfo$call$nDays) + timeInfo$call$pillow    
  } else
  {
    fitt <- timeInfo$outSeq
  }

  inlam  <- lambda
  if (is.character(lambda))
  {
    cat("Using fixed 'lambda':",lambda,"\n")
    nameL <- "FixedLambda"
  } else 
  {
    if (collapse)
    {
      lambda <- lambda*((365 + 2*timeInfo$call$pillow)/365)
      cat("Yearly 'lambda' is:",inlam,"\nNow changed with lambda*((365+2*pillow)/365) to:",lambda,"\n")
    } else
    {
      lambda <- lambda*((max(timeInfo$inSeq) - min(timeInfo$inSeq) -1)/365)
      cat("Yearly 'lambda' is:",inlam,"\nNow changed with lambda*('length of input data period in days'/365) to:",lambda,"\n")
    }
    nameL <- "YearlyLambda"
  }
  lambda <- as.numeric(lambda)

  if(!inherits(vi,"Raster")) 
  {
    vi <- stack(vi,quick=TRUE)
  }

  if(!inherits(w,"Raster") & !is.null(w)) 
  {
    w <- stack(w,quick=TRUE)
  }

  if(!inherits(t,"Raster") & !is.null(t)) 
  {
    t <- stack(t,quick=TRUE)
  }
   
  if(!is.null(opt$datatype))
  {
    datatype <- opt$datatype
  } else
  {
    datatype <- dataType(vi)[1]
  }
    
  b <- list()
  if (collapse)
  {
    b[[1]] <- brick(raster(vi),nl=length(fitt), values=FALSE)  
    b[[1]] <- writeStart(b[[1]], filename=paste0(opt$outDirPath,"NDVI_",nameL,inlam,"_summarised",format(min(timeInfo$outputLayerDates),"%Y"),"to",format(max(timeInfo$outputLayerDates),"%Y"),dataFormat),datatype=datatype,...)
  } else if (groupYears)
  {
    for (a in seq_along(unique(format(timeInfo$outputLayerDates,"%Y"))))
    {
      y <- unique(format(timeInfo$outputLayerDates,"%Y"))[a]
      b[[a]] <- brick(raster(vi),nl=as.integer(sum(format(timeInfo$outputLayerDates,"%Y")==y)), values=FALSE)
      b[[a]] <- writeStart(b[[a]], filename=paste0(opt$outDirPath,"NDVI_",nameL,inlam,"_year",y,dataFormat),datatype=datatype,...)
    }
  } else 
  {
    b[[1]] <- brick(raster(vi),nl=length(fitt), values=FALSE)  
    b[[1]] <- writeStart(b[[1]], filename=paste0(opt$outDirPath,"NDVI_",nameL,inlam,"_fullPeriod",dataFormat),datatype=datatype,...)
  }

  if(substr(dataType(b[[1]]),1,3) == "FLT")
  {
    doround <- FALSE
  } else
  {
    doround <- TRUE
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
    clusterEvalQ(cl,require(ptw))
    tr <- blockSizeCluster(vi)
  }    

  cat("Data is in, start processing!\n")

  if(tolower(mergeDoyFun)=="max")
  {
    mergeFun <- unifyDoubleMX
  } else if (tolower(mergeDoyFun)=="weighted.mean" | tolower(mergeDoyFun)== "mean")
  {
    mergeFun <- unifyDoubleWM
  }
# clusterExport(cl,ls())
###############################
# clusterFuns: 

  clFun <- function(l)
  {
    val    <- getValues(vi, row=tr$row[l], nrows=tr$nrows[l])
    val    <- t(val)
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
          bits     <- detectBitInfo(vi,"VI usefulness",warn=FALSE)
          bitShift <- bits$bitShift
          bitMask  <- bits$bitMask
        }
        if(is.null(bitShift) | is.null(bitMask))
        {
          stop("Could not extract 'bits' for weighting from this product. Use '?makeWeights' function to generate weights manually!")
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
      inTu <- t(inTu)
            
      set0[is.na(inTu)] <- TRUE
      set0[ inTu <= 0 ] <- TRUE
            
      if(!collapse)
      {
        inTu <- t(repDoy(t(inTu),layerDate=timeInfo,bias=0))
      }
      
      inTu[set0] <- 0
    } else 
    {
      if (collapse)
      {
        inTu <- matrix(timeInfo$inDoys,nrow=length(timeInfo$inDoys),ncol=mtrdim[2])
      } else
      {       
        inTu <- matrix(timeInfo$inSeq,nrow=length(timeInfo$inSeq),ncol=mtrdim[2])
      }
    }
    # the entire info to use or not a pix is in "wtu"
    wtu[set0] <- 0
    val[set0] <- 0    

    out <- matrix(NA, nrow=length(fitt), ncol=mtrdim[2])
    
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

    if (collapse)
    {
      tsLength <- 365 + (2*timeInfo$call$pillow) + 30 # add a save length of data (because layer doy + effectice composite doy)
    } else
    {
      tsLength <- max(timeInfo$inSeq,timeInfo$outSeq) - min(timeInfo$inSeq,timeInfo$outSeq) - 1  + 30
    }
    # minimum "minDat" input values for filtering 
    Cvec <- (colSums(wtu > 0) >= minDat)
    Cvec <- (1:mtrdim[2])[Cvec]
    ind  <- inTu > 0    
    vec0 <- rep(0,tsLength)
    
    win <- options("warn")
    options(warn=-1)
    
    for (u in Cvec)
    {   
      index <- ind[,u]
      use <- mergeFun(vx=val[index,u],wx=wtu[index,u],tx=inTu[index,u])    
      
      valVec <- wtVec  <- vec0
      
      if(!collapse)
      {
        valVec[use$tx] <- use$vx
        wtVec[use$tx]  <- use$wx
      } else
      {
        newOrder <- doCollapse(tx=use$tx,pillow=timeInfo$call$pillow)
        valVec[newOrder$sequence] <- use$vx[newOrder$order]
        wtVec[newOrder$sequence]  <- use$wx[newOrder$order]  
      }
      wtVec <- kickOutlier(vals=valVec,weights=wtVec,lambda=lambda,threshold=threshold)
      #plot(valVec,ylim=c(-1000,9000))
      for(i in 1:nIter)
      {
        fTS <- whit2(valVec,w=wtVec,lambda=lambda)
        valVec[valVec < fTS] <- fTS[valVec < fTS]
      }
      out[,u] <- fTS[fitt]
      #lines(fTS,col=2)
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

            ni <- nodes + i
            if (ni <= tr$n)
            {
                sendCall(cl[[d$node]], fun = clFun, args = ni, tag=ni)
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
        file=paste0(opt$outDirPath,"NDVI_",nameL,inlam,"_year",y),row.names=FALSE,col.names=FALSE)
    } else 
    {
      if (collapse)
      {
        write.table(x=fitt-timeInfo$call$pillow, file=paste0(opt$outDirPath,"NDVI_",nameL,inlam,"_summarised",format(min(timeInfo$outputLayerDates),"%Y"),"to",format(max(timeInfo$outputLayerDates),"%Y")), 
            col.names=FALSE,row.names=FALSE)
      } else
      {
        write.table(x=timeInfo$outputLayerDates, file=paste0(opt$outDirPath,"NDVI_",nameL,inlam,"fullPeriod"), 
            col.names=FALSE,row.names=FALSE)
      }
    }
  }
  return(b)
}



