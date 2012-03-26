# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

getTile <- function (tileH = NULL, tileV = NULL, extent = NULL, buffer = NULL,system = "MODIS"){
	
	if (system == "MODIS") {
		data("tiletable")
	} else if (system == "MERIS") {
		tiletable <- genTile(tileSize = 5)
	} else {
		stop("Tiling system not recognised")
	}
    if (is.null(extent)) {
        if (is.null(tileV) || is.null(tileH)) 
            stop("Provide or an 'extent' or 'tileV+tileH' information!")
        extent <- ""
    } else {

        if (inherits(extent, "map")) { # if MAP
            extent <- list(xmin = min(extent$range[1:2]), xmax = max(extent$range[1:2]), 
                ymin = min(extent$range[3:4]), ymax = max(extent$range[3:4]))

        } else if (inherits(extent, "character")) { # if CHARACTER (country name of MAP)
            require(mapdata)
            try(test <- map("worldHires", extent, plot = FALSE), 
                silent = TRUE)
			if (!exists("test")) {
                stop(paste("Country name not valid. Check availability/spelling, i.e. try if it works with: map('worldHires',',", 
                  extent, "')", sep = ""))
            }
        extent <- map("worldHires", extent, plot = FALSE)
        extent <- list(xmin = min(extent$range[1:2]), xmax = max(extent$range[1:2]),ymin = min(extent$range[3:4]), ymax = max(extent$range[3:4]))

        } else if (class(extent) %in% c("Extent", "RasterLayer", "RasterStack","RasterBrick")) { # if RASTER* object
        	if (!inherits(extent,"Extent")) {
        	 	inproj <- projection(extent)
           	if (!inproj %in% c("+proj=longlat +datum=WGS84","+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") | !isLonLat(extent)) {
        	 		require(rgdal)
           		ex <- extent(extent)
           		xy <- matrix(c(ex@xmin,ex@ymin,ex@xmin,ex@ymax,ex@xmax,ex@ymax,ex@xmax,ex@ymin),ncol=2,nrow=4,byrow=TRUE)
           		colnames(xy) <- c("x","y")
           		xy <- as.data.frame(xy)
           		coordinates(xy) <- c("x","y")
           		proj4string(xy) <- CRS(inproj)
 							outBB  <- spTransform(xy,CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))@bbox
							extent <- list(xmin=outBB["x","min"],xmax=outBB["x","max"],ymin=outBB["y","min"],ymax=outBB["y","max"])
						} else {
	      	  	extent <- extent(extent)
							extent <- list(xmin = extent@xmin, xmax = extent@xmax, ymin = extent@ymin, ymax = extent@ymax)
						}
					} else {
	    	  	extent <- extent(extent)
						extent <- list(xmin = extent@xmin, xmax = extent@xmax, ymin = extent@ymin, ymax = extent@ymax)
        	}
        } 
        
        if (inherits(extent, "list")) {
            if (length(extent$extent) == 4) {
                extent <- extent$extent
            }
            if (!is.null(buffer)) {
                if (length(buffer) == 1) {
                  buffer <- c(buffer, buffer)
                }
                extent[1] <- as.numeric(extent[1]) - buffer[1]
                extent[2] <- as.numeric(extent[2]) + buffer[1]
                extent[3] <- as.numeric(extent[3]) - buffer[2]
                extent[4] <- as.numeric(extent[4]) + buffer[2]
            }
            minTile <- subset(tiletable, (tiletable$xmin <= extent$xmin & tiletable$xmax >= extent$xmin) & (tiletable$ymin <= extent$ymin & tiletable$ymax >= extent$ymin), select = c(iv, ih))
            minTile <- c(min(minTile$iv), min(minTile$ih))
            maxTile <- subset(tiletable, (tiletable$xmin <= extent$xmax & tiletable$xmax >= extent$xmax) & (tiletable$ymin <= extent$ymax & tiletable$ymax >= extent$ymax), select = c(iv, ih))
            maxTile <- c(max(maxTile$iv), max(maxTile$ih))
            tileV <- minTile[1]:maxTile[1]
            tileH <- minTile[2]:maxTile[2]
        }
    }
    tileH <- as.vector(tileH)
    tileV <- as.vector(tileV)
    vmax <- max(tiletable$iv)
    hmax <- max(tiletable$ih)
    if (min(tileH) < 0 || max(tileH) > hmax) {
        stop(paste("'tileH' number(s) must be between 0 and", 
            hmax, sep = ""))
    }
    if (min(tileV) < 0 || max(tileV) > vmax) {
        stop(paste("'tileV' number(s) must be between 0 and", 
            vmax, sep = ""))
    }
    vsize <- nchar(vmax)
    hsize <- nchar(hmax)
    tiles <- list()
    for (i in seq(along = tileH)) {
        tiles[[i]] <- paste("h", sprintf(paste("%0", hsize, "d", sep = ""), tileH[i]), "v", sprintf(paste("%0", hsize, "d", sep = ""), tileV), sep = "")
    }
    result <- list(tile = unlist(tiles), tileH = tileH, tileV = tileV,extent = extent, system = system)
    return(result)
}


