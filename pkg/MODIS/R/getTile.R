# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

getTile <- function(extent = NULL, tileH = NULL, tileV = NULL, buffer = NULL, system = "MODIS", zoom = TRUE)
{
    # debug:
    # extent = "austria"; tileH = NULL; tileV = NULL; buffer = NULL; system = "srtm"; zoom=TRUE
    
    # if extent is a former result of getTile
    if (inherits(extent,"MODISextent"))
    {
        return(extent)
    }
    
    old    <- FALSE # "old=T" always works, "old=F" only for MODIS system + having rgdal and rgeos installed
    target <- NULL  # if extent is a raster*/Spatial* and has a different proj it is changed
    isPoly <- FALSE
    system <- toupper(system) 
    
    if (system == "MERIS") 
    {
        # generate tiling structure of Culture-Meris data
        tiltab <- genTile(tileSize = 5)
        old <- TRUE
    } else if (system == "SRTM") 
    {
        # generate tiling structure of SRTMv4 data
        tiltab <- genTile(tileSize = 5,extent=list(xmin=-180,xmax=180,ymin=-60,ymax=60),StartNameFrom=c(1,1))
        old <- TRUE
    } else 
    {
        if (! require(rgdal) ) 
        {
            cat("Using 'old' selection method,\nFor precise subsetting install the 'rgdal' package: install.packages('rgdal')\n")
            old <- TRUE
            tiltab <- tiletable
        }

        if (! require(rgeos) ) 
        {
            cat("Using 'old' selection method,\nFor precise subsetting install the 'rgeos' package: install.packages('rgeos')\n")
            old <- TRUE
            tiltab <- tiletable
        }
    }
    
    # supported extent: shp, list, raster-Extent/-Layer/-Brick/-Stack, map or blank
    # everything (except 'shp' and 'map') merges to an raster 'Extent' object
    # 'shp' and 'map' to a sp Polygon object (since the exact conture is used not the bounding box of the extent) 
    # argument extent is prioritary to tileV/H.
    
    # if extent is a raster or a "path/name" to a rasterfile. 
    if(inherits(extent,"character") & length(extent)==1)
    {
        if (file.exists(extent))
        {
            exts <- raster:::extension(extent)
            if (exts!= ".shp")
            {
                test <- try(raster(extent), silent=TRUE)
                if (!inherits(test,"try-error"))
                {
                    extent <- ex <- test
                    rm(ex)
                }
            }
        }
    }
    
    # if extent is a shapefileNAME    
    test <- try(shapefile(extent), silent=TRUE)
    if (!inherits(test,"try-error"))
    {
        extent <- ex <- test
        rm(ex)
        isPoly <- TRUE
    # if extent is a "shapefile"    
    }
    
    oclass <- class(extent)
    if (length(grep(oclass, pattern="^SpatialPolygon*"))==1)
    {
        isPoly <- TRUE
    }
    # TODO for now only SpatialPolygons can do the exact matching... 
    if (length(grep(oclass, pattern="^SpatialLine*"))==1)
    {
        isPoly <- FALSE
    }
    if (length(grep(oclass, pattern="^SpatialPoint*"))==1)
    {
        isPoly <- FALSE
    }
        
    if (isTRUE(isTRUE(is.null(tileH) | is.null(tileV)) & is.null(extent))) 
    {
        if (!require(mapdata)) 
        {
            stop("For interactive TILE selection you need to install the 'mapdata' package: install.packages('mapdata')")
        }
        
        x11(width=9,height=7)
        map("worldHires")
        map.axes() 
        grid(36,18,col="blue",lwd=0.5)
        abline(h=0,col="yellow",lwd=1)
        if(zoom) 
        {
            title("ZOOM-IN by selecting UL and LR points with the mouse!")            
            # code taken from function raster:::drawExtent
            loc1 <- locator(n = 1, type = "p", pch = "+", col = "red")
            loc2 <- locator(n = 1, type = "p", pch = "+", col = "red")
            loc  <- rbind(unlist(loc1), unlist(loc2))
            #
            p    <- rbind(c(min(loc[, "x"]), min(loc[,"y"])), c(min(loc[, "x"]), max(loc[, "y"])),
            c(max(loc[, "x"]), max(loc[, "y"])), c(max(loc[, "x"]), min(loc[,"y"])), c(min(loc[, "x"]),min(loc[,"y"])))
            lines(p, col = "red")            

            Sys.sleep(0.5)
            map("worldHires",xlim=c(min(loc[, "x"]),max(loc[, "x"])),ylim=c(min(loc[,"y"]),max(loc[, "y"])))
            map.axes() 
            grid(36,18,col="blue",lwd=0.5)            
        }
        title("Set UL and LR points with the mouse!")
        # code taken from function raster:::drawExtent
        loc1 <- locator(n = 1, type = "p", pch = "+", col = "red")
        loc2 <- locator(n = 1, type = "p", pch = "+", col = "red")
        loc  <- rbind(unlist(loc1), unlist(loc2))
        #
        p    <- rbind(c(min(loc[, "x"]), min(loc[,"y"])), c(min(loc[, "x"]), max(loc[, "y"])),
        c(max(loc[, "x"]), max(loc[, "y"])), c(max(loc[, "x"]), min(loc[,"y"])), c(min(loc[, "x"]),min(loc[,"y"])))
        lines(p, col = "red")
        
        extent <- extent(c(min(loc[, "x"]), max(loc[, "x"]), min(loc[, "y"]), max(loc[, "y"])))
        
        Sys.sleep(0.6)
        if(zoom)
        {
            text(x=min(loc[, "x"])+((max(loc[, "x"])-min(loc[, "x"]))/2),y=min(loc[,"y"])+((max(loc[, "y"])-min(loc[,"y"]))/2),"OK, extent is set!\nclosing window...",cex=3)    
        } else 
        {
            text(x=-4,y=21,"OK, extent is set!\nclosing window...",cex=5)
        }
        Sys.sleep(1.6)
        dev.off()
    }
    
    # if extent is expressed using tileV+H
    if(all(!is.null(tileH), !is.null(tileV), is.null(extent))) 
    {
        tileH <- as.numeric(tileH)
        tileV <- as.numeric(tileV)

        if (system == "MODIS")
        {
            tiltab <- MODIS:::tiletable
        }

        tt      <- subset(tiltab,(tiltab$ih %in% tileH) & (tiltab$iv %in% tileV) & tiltab$xmin>-999)
        extent  <- extent(c(min(tt$xmin),max(tt$xmax),min(tt$ymin),max(tt$ymax)))
        
        if (system == "SRTM")
        {
            tilesSUB <- as.character(apply(tt,1, function(x)
            {
                paste("_", sprintf(paste("%02d", sep = ""), x[2]), "_", sprintf(paste("%02d", sep = ""), x[1]), sep = "")}
            ))
            tiles <- as.character(sapply(tileH, function(x){paste("_", sprintf(paste("%02d", sep = ""), x), "_", sprintf(paste("%02d", sep = ""), tileV), sep = "")}))

        } else if(system == "MODIS")
        {
            tilesSUB <- as.character(apply(tt,1, function(x)
            {
                paste("h", sprintf(paste("%02d", sep = ""), x[2]), "v", sprintf(paste("%02d", sep = ""), x[1]), sep = "")
            }
            ))
            
            tiles <- as.character(sapply(tileH, function(x){paste("h", sprintf(paste("%02d", sep = ""), x), "v", sprintf(paste("%02d", sep = ""), tileV), sep = "")}))
                
        }
        if (!all(tiles %in% tilesSUB))
        {
            rem <- paste(tiles[!tiles %in% tilesSUB],sep="",collapse=", ")
            cat(paste("Not all 'tiles' are existing! The following 'tiles' are removed:\n",rem,"\n",sep=""))
            tiles <- tilesSUB
            tileH <- unique(tt$ih)
            tileV <- unique(tt$iv)
        }
        result <- list( tile = tiles, tileH = tileH, tileV = tileV, extent = NULL, system = system, target=NULL )
        class(result) <- "MODISextent"
        return(result)
    }

    # if CHARACTER (country name of MAP)     
    if (inherits(extent, "character"))
    {

        if (! require(mapdata))
        {
            stop("For interactive TILE selection you need to install the 'mapdata' package: install.packages('mapdata')")
        }

        try(testm <- map("worldHires", extent, plot = FALSE),silent = TRUE)
        if (!exists("testm"))
        {
            stop(paste("Country name not valid. Check availability/spelling, i.e. try if it works with: map('worldHires,'",extent, "'), or use 'search4map('pattern')' function", sep = ""))
        }
        extent <- map("worldHires", extent, plot = FALSE, fill=TRUE)
    }
    
    # if MAP (from mapdata/maps)
    if (inherits(extent, "map"))
    {
        if (require(maptools) & system == "MODIS")
        {
            extent <- map2SpatialPolygons(extent, extent$names,CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
            isPoly <- TRUE            
        } else
        {
            extent <- extent(c(extent$range[1],extent$range[2],extent$range[3],extent$range[4]))
            cat("'maptools' is not installed 'polygon area' extent disabled, simple bounding box is used instead!\n")
        }   
    }
    
    # if raster* object or Spatial*
    if (length(grep(oclass,pattern="Raster*"))==1 | length(grep(oclass,pattern="Spatial*"))==1) 
    {
        t_srs <- projection(extent)
        
        if (length(grep(oclass,pattern="Raster*"))==1)
        {
            resolution <- res(extent)
        } else 
        {
            resolution <- NULL
        }
        
        ext <- extent(extent)
            
        # Is this grep query right to catch LatLon wgs84? are there other latlons?
        if (length(grep(t_srs,pattern="+proj=longlat"))==0 | !isLonLat(extent)) 
        { 
            if (! require(rgdal) )
            {
               stop("You need to install the 'rgdal' package: install.packages('rgdal')")
            }
            
            xy <- matrix( c(ext@xmin, ext@ymin, ext@xmin, ext@ymax, ext@xmax, ext@ymax, ext@xmax, ext@ymin), ncol=2, nrow=4, byrow=TRUE)
            colnames(xy) <- c("x","y")
            xy <- as.data.frame(xy)
            coordinates(xy) <- c("x","y")
            proj4string(xy) <- CRS(t_srs)
            outBB  <- spTransform(xy,CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))@bbox
            #ext    <- extent(c(outBB["x","min"],outBB["x","max"],outBB["y","min"],outBB["y","max"]))
            extent <- extent(c(outBB["x","min"],outBB["x","max"],outBB["y","min"],outBB["y","max"]))
        }
        target <- list(t_srs = t_srs, extent = ext, resolution = resolution) 
    }

    if (length(grep(oclass, pattern="^SpatialPolygon*")==1) & old)
    {
        extent <- extent(extent)
    }
    # TODO; Quick and dirty
    if(length(grep(oclass, pattern="^SpatialLine*"))==1 | length(grep(oclass, pattern="^SpatialPoint*"))==1)
    {
        extent <- extent(extent)
    }

    if (inherits(extent, "list")) 
    {
        if (length(extent$extent) == 4) 
        {
            extent <- extent$extent
        }
        
        extent <- extent(c(min(extent$xmin,extent$xmax), max(extent$xmin,extent$xmax), min(extent$ymin,extent$ymax), max(extent$ymin,extent$ymax)))
    }
    
    if (inherits(extent,"Extent"))
    {
    # every input extent information (except "SpatialPolygonsDataFrame" & old == TRUE)
    # should merge to a "raster:::extent" object, evaluated here below.
         
    # if min/max is inverted
        Txmax <- max(extent@xmin,extent@xmax)
        Txmin <- min(extent@xmin,extent@xmax)
        Tymax <- max(extent@ymin,extent@ymax)
        Tymin <- min(extent@ymin,extent@ymax)
        
        extent@ymin <- Tymin        
        extent@ymax <- Tymax
        extent@xmin <- Txmin
        extent@xmax <- Txmax        
        
        if (!is.null(buffer)) 
        {
            if (length(buffer) == 1) 
            {
                buffer <- c(buffer, buffer)
            }
            extent@xmin <- extent@xmin - buffer[1]
            extent@xmax <- extent@xmax + buffer[1]
            extent@ymin <- extent@ymin - buffer[2]
            extent@ymax <- extent@ymax + buffer[2]
        }
        
    } else if (inherits(extent,"SpatialPolygonsDataFrame") & !is.null(buffer))
    {
        if (length(buffer)>1)
        {
            buffer <- buffer[1]
            warning(paste("'buffer' on a vector object must have length==1. Used only the first element of 'buffer': ",buffer[1],sep=""))
        }
        
        # gBuffer doesn't allow buffer on LatLon, fake CRS bypass this. Found in: 
        # http://stackoverflow.com/questions/9735466/how-to-compute-a-line-buffer-with-spatiallinesdataframe
        win                 <- options()$warn 
        options(warn=-2)
        inproj              <- proj4string(extent)
        proj4string(extent) <- CRS("+init=epsg:3395")
        extent              <- gBuffer(extent,width=buffer)
        proj4string(extent) <- CRS(inproj)
        options(warn=win)
    }
    
    if(old)
    {
        if (system == "SRTM") 
        {
            if (extent@ymin >  60){stop("Latitudes are higer than SRTM coverage! Select an area inside Latitudes -60/+60\n")}
            if (extent@ymax < -60){stop("Latitudes are lower than SRTM coverage! Select an area inside Latitudes -60/+60\n")}
            if (extent@ymin < -60){extent@ymin <- -60; warning("Minimum Latitude is out of SRTM coverage, extent is trimmed to min LAT -60\n")}
            if (extent@ymax >  60){extent@ymax <-  60;  warning("Maximum Latitude is out of SRTM coverage, extent is trimmed to max LAT 60\n")}
        }

        minTile <- tiltab[((tiltab$xmin <= extent$xmin & tiltab$xmax >= extent$xmin) & (tiltab$ymin <= extent$ymin & tiltab$ymax >= extent$ymin)),c("iv","ih")]
        maxTile <- tiltab[((tiltab$xmin <= extent$xmax & tiltab$xmax >= extent$xmax) & (tiltab$ymin <= extent$ymax & tiltab$ymax >= extent$ymax)),c("iv","ih")]
        tiles   <- rbind(maxTile,minTile)
            
        tileV <- as.vector(min(tiles[1]):max(tiles[1]))
        tileH <- as.vector(min(tiles[2]):max(tiles[2]))
        
        vmax  <- max(tiltab$iv)
        hmax  <- max(tiltab$ih)
        
        if (min(tileH) < 0 || max(tileH) > hmax) 
        {
            stop(paste("'tileH' number(s) must be between 0 and",hmax, sep = ""))
        }
        if (min(tileV) < 0 || max(tileV) > vmax) 
        {
            stop(paste("'tileV' number(s) must be between 0 and",vmax, sep = ""))
        }
        
        vsize <- nchar(vmax)
        hsize <- nchar(hmax)
        tiles <- list()
        
        for (i in seq(along = tileH)) 
        {
            if (system == "SRTM")
            {
                tiles[[i]] <- paste("_", sprintf(paste("%0", hsize, "d", sep = ""), tileH[i]), "_", sprintf(paste("%0", hsize, "d", sep = ""), tileV), sep = "")
            } else 
            {
                tiles[[i]] <- paste("h", sprintf(paste("%0", hsize, "d", sep = ""), tileH[i]), "v", sprintf(paste("%0", hsize, "d", sep = ""), tileV), sep = "")                        
            }
        }
        result <- list(tile = unlist(tiles), tileH = tileH, tileV = tileV,extent = extent, system = system, target = target)
        class(result) <- "MODISextent"        
        return(result)
   
    } else 
    {
        if(isPoly) 
        {
            po <- list()
            for(u in seq_along(extent))
            {
                po[[u]] <- Polygon(extent@polygons[[u]]@Polygons[[1]]@coords,hole=FALSE)
            }    
            extent <- extent(extent)
                        
        } else
        {
            po <- list(Polygon(cbind(c(extent@xmin,extent@xmax,extent@xmax,extent@xmin,extent@xmin),c(extent@ymax,extent@ymax,extent@ymin,extent@ymin,extent@ymax)),hole=FALSE))
        }
        
        pos  <- Polygons(po,"selection")
        spos <- SpatialPolygons(list(pos))
       
        if (is.na(proj4string(spos)))
        {
            proj4string(spos) <- proj4string(MODIS:::sr) # MODIS:::sr
        }
         
        selected <- MODIS:::sr[spos,] # == rgeos:::over() # MODIS:::sr 
        
        tileH  <- unique(as.numeric(selected@data$h))
        tileV  <- unique(as.numeric(selected@data$v))
        result <- as.character(apply(selected@data,1,function(x) {paste("h",sprintf("%02d",x[2]),"v",sprintf("%02d",x[3]),sep="")}))
        result <- list(tile = result, tileH = tileH, tileV = tileV, extent = extent, system = system, target = target)
        class(result) <- "MODISextent"
        return(result)
    }
}

