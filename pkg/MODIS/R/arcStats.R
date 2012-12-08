# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : July 2012
# Licence GPL v3


arcStats <- function(product, collection=NULL, extent="global", begin=NULL, end=NULL, asMap=TRUE, outName=NULL,...)
{  

    if (!require(rgdal))
    {
        stop("Please install rgdal package: install.packages('rgdal')")
    }

    date4name <- format(Sys.time(), "%Y%m%d%H%M%S")       
    if(is.null(outName))
    {
        if (inherits(extent,"character"))
        {
            outName <- paste(paste(extent,sep="",collapse=""),date4name,sep="_")
        } else 
        {
            outName <- date4name
        }
    }
    
    opts <- combineOptions(...)
    opts$localArcPath <- MODIS:::setPath(opts$localArcPath) 
    opts$outDirPath   <- MODIS:::setPath(opts$outDirPath) 
    
    # product/dates/extent
    product     <- getProduct(x=product, quiet=TRUE)
    product$CCC <- getCollection(product=product, collection=collection, quiet=TRUE)
    tLimits     <- transDate(begin=begin, end=end)

    if (extent[1]!="global")
    {  
        ext <- getTile(extent=extent)
    }

    MODIS:::.getStruc(product=product, begin=tLimits$begin, end=tLimits$end, wait=0,opts)
    ftpdirs <- list()
    ftpdirs[[1]] <- read.table(file.path(opts$auxPath,"LPDAAC_ftp.txt",fsep="/"), stringsAsFactors=FALSE)

    for (z in seq_along(product$PRODUCT))
    {
        todo <- paste(product$PRODUCT[z],".", product$CCC[[which(names(product$CCC)==product$PRODUCT[z])]],sep="")

        for(u in seq_along(todo))
        {
            path <- MODIS:::.genString(x=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],remote=FALSE,opts)$localPath
            path <- strsplit(path,"/")[[1]]
            path <- paste(path[-length(path)],sep="",collapse="/")
  
            expected <- as.Date(ftpdirs[[1]][,todo[u]],"%Y.%m.%d")
            expected <- expected[tLimits$begin <= expected & tLimits$end >= expected]
            expected <- expected[!is.na(expected)]
  
            allLocal <- list.files(path=path,pattern=".hdf$",recursive=TRUE,full.names=TRUE)
            
            # remove not requested dates
            locDates <- sapply(allLocal,function(x)
                {
                    date <- strsplit(normalizePath(dirname(x),winslash="/"),"/")[[1]]
                    date <- date[length(date)]
                    return(date)
                })
                
            allLocal <- allLocal[as.Date(locDates,"%Y.%m.%d")%in%expected]
            
            # remove not requested tiles
            if(extent[1]=="global")
            {
                tileinfo <- unique(sapply(basename(allLocal),function(x){x <- getProduct(x);MODIS:::.getPart(x,"TILE")}))
            } else {
                tileinfo <- ext$tile
            }
                       
            sr <- shapefile(system.file("external","modis_latlonWGS84_grid_world.shp",package="MODIS"))
            tileNames <- paste("h",sprintf("%02d", sr@data[,"h"]),"v",sprintf("%02d", sr@data[,"v"]),sep="")            
            quanti <- nrow(sr@data)
            available <- rep(0,nrow=quanti)
            needed    <- rep(0,nrow=quanti)
            percent   <- rep(0,nrow=quanti)
            MBperHDF  <- rep(0,nrow=quanti)            
            sr@data   <- cbind(sr@data,tileNames,available,needed,percent,MBperHDF)
            sr@data[,"needed"] <- length(expected)
                        
            # calculation section
            for ( i in seq_along(tileinfo))
            {
                n <- grep(allLocal,pattern=tileinfo[i],value=TRUE)
                meanSize <- mean(file.size(n,units="Mb")) 
                
                if (length(n)!=0)
                {
                    n <- sapply(n,function(x)
                    {
                        date <- strsplit(normalizePath(dirname(x),winslash="/"),"/")[[1]]
                        date <- date[length(date)]
                        return(date)
                    })
                    
                    n <- as.Date(n,"%Y.%m.%d")
                    n <- sum(n%in% expected)
                } else {
                    n <- 0 
                }
                    
                ind <- which(tileNames==tileinfo[i])
                sr@data[ind,"available"] <- n
                sr@data[ind,"percent"]   <- round(100*(n/length(expected)),2)
                sr@data[ind,"MBperHDF"]  <- meanSize
            }
            
            # mapping 
            if (isTRUE(asMap)|asMap=="both")
            {
                if (!(require(maptools)))
                {
                    stop("Please install maptools package: install.packages('maptools')")
                }
                
                if (!(require(mapdata)))
                {
                    stop("Please install mapdata package: install.packages('mapdata')")
                }
                if (!(require(plotrix)))
                {
                  stop("Please install plotrix package: install.packages('plotrix')")
                }
                
                # require(scales)
                # colors <- c("#00000000",colorRampPalette(c("red","blue","green"))(100))
                colors <- c("#00000000", "#FF0000", "#F90005", "#F4000A", "#EF000F", "#EA0014", "#E50019", "#E0001E", "#DA0024", "#D50029", "#D0002E", "#CB0033", "#C60038", "#C1003D", "#BC0042", "#B60048", "#B1004D", "#AC0052", "#A70057", "#A2005C", "#9D0061", "#970067", "#92006C", "#8D0071", "#880076", "#83007B", "#7E0080", "#790085", "#73008B", "#6E0090", "#690095", "#64009A", "#5F009F", "#5A00A4", "#5400AA", "#4F00AF", "#4A00B4", "#4500B9", "#4000BE", "#3B00C3", "#3600C8", "#3000CE", "#2B00D3", "#2600D8", "#2100DD", "#1C00E2", "#1700E7", "#1200EC", "#0C00F2", "#0700F7", "#0200FC", "#0002FC", "#0007F7", "#000CF2", "#0012EC", "#0017E7", "#001CE2", "#0021DD", "#0026D8", "#002BD3", "#0030CE", "#0036C8", "#003BC3", "#0040BE", "#0045B9", "#004AB4", "#004FAF", "#0055A9", "#005AA4", "#005F9F", "#00649A", "#006995", "#006E90", "#00738B", "#007985", "#007E80", "#00837B", "#008876", "#008D71", "#00926C", "#009767", "#009D61", "#00A25C", "#00A757", "#00AC52", "#00B14D", "#00B648", "#00BC42", "#00C13D", "#00C638", "#00CB33", "#00D02E", "#00D529", "#00DA24", "#00E01E", "#00E519", "#00EA14", "#00EF0F", "#00F40A", "#00F905", "#00FF00")
             
                if (extent[1]!="global")
                {
                    png(paste(opts$outDirPath,"/",todo[u],".",outName,".png",sep=""), width = 800, height = 600)
                    
                    xlim <- c(ext$extent@xmin,ext$extent@xmax)
                    ylim <- c(ext$extent@ymin,ext$extent@ymax)
     
                    globe <- map("worldHires",plot=FALSE,xlim=xlim,ylim=ylim)
                    globe <- map2SpatialLines(globe)
                    proj4string(globe) <- proj4string(sr)
                    
                    spl <- list("sp.lines", as(globe, "SpatialLines"), lwd=0.8)
                    spplot(sr, zcol="percent", col.regions=colors, xlim=xlim, ylim=ylim, at=0:100, sp.layout=spl,scales=list(draw = TRUE),main=paste("Percentage of ",todo[u]," available on the local archive\nbetween ",min(expected)," and ",max(expected),sep=""))
                    dev.off()
                    
                } else 
                {
                
                    dime   <- 400
                    width  <- (2*dime)
                    height <- (1*dime) + dime * 0.5 
                    
                    png(paste(opts$outDirPath,"/",todo[u],".",outName,".png",sep=""), width = width, height = height)
                    
                    plot(sr,col=colors[(round(sr@data$percent,0)+1)],xlim=c(-180,180),ylim=c(-90,90))
                    axis(1,labels=seq(-180,180,by=60),at=seq(-180,180,by=60),pos=-100)
                    axis(2,labels=seq(-90,90,by=30),at=seq(-90,90,by=30))
                    globe <- map(plot=FALSE)
                    globe <- map2SpatialLines(globe)
                    proj4string(globe) <- proj4string(sr)
                    plot(globe,add=TRUE) 
                    #add a legend
                    color.legend(-180,-140,180,-130,seq(0,100,by=10),colors)
                    inxpd <- par()$xpd
                    par(xpd=NA)
                    text(0,-148,"[%]",cex=1) # substiture with mtext!
                    par(xpd=inxpd)
                    title(paste("Percentage of ",todo[u]," available on the local archive\nbetween ",min(expected)," and ",max(expected),sep=""),line=-2,cex.main=2)
                    dev.off()
                }
            }
            if (!isTRUE(asMap)|asMap=="both")
            {
                if (extent[1]=="global")
                {
                    out <- sr@data[,c("tileNames","available","needed","percent","MBperHDF")]
                } else 
                {
                    out <- sr@data[sr@data$tileName %in% ext$tile,c("tileNames","available","needed","percent","MBperHDF")]
                }
                write.csv(x=out,file=paste(opts$outDirPath,"/",todo[u],".",outName,".csv",sep=""),row.names = FALSE)                
            }
        }
    }
return(invisible(NULL))
}
