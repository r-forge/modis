# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

getTile <- function(tileH = NULL, tileV = NULL, extent = NULL, buffer = NULL,system = "MODIS",zoom=TRUE){

	old <- FALSE
	
	if (toupper(system) == "MERIS") {
		tiletable <- genTile(tileSize = 5)
		old <- TRUE
	} else if (toupper(system) == "SRTM") {
		tiletable <- genTile(tileSize = 5,extent=list(xmin=-180,xmax=180,ymin=-60,ymax=60),StartNameFrom=c(1,1))
		old <- TRUE
	}
	
	if (isTRUE(is.null(c(tileH,tileV,extent)))) {
		require(mapdata)
		x11(width=16,height=9)
		map("worldHires")
		box()
		grid(36,18,col="blue",lwd=0.5)
		abline(h=0,col="yellow",lwd=1)
		if(zoom) {
			title("ZOOM in by selecting UL and LR points with the mouse!")			
			# code taken from function raster:::drawExtent
			loc1 <- locator(n = 1, type = "p", pch = "+", col = "red")
			loc2 <- locator(n = 1,col = "red")
			loc  <- rbind(unlist(loc1), unlist(loc2))
			bb   <- extent(min(loc[, "x"]), max(loc[, "x"]), min(loc[,"y"]), max(loc[, "y"]))
			p    <- rbind(c(bb@xmin, bb@ymin), c(bb@xmin, bb@ymax),c(bb@xmax, bb@ymax), c(bb@xmax, bb@ymin), c(bb@xmin,bb@ymin))
			lines(p, col = "red")			
			#
			Sys.sleep(0.5)
			map("worldHires",xlim=c(bb@xmin,bb@xmax),ylim=c(bb@ymin,bb@ymax))
			box()
			grid(36,18,col="blue",lwd=0.5)			
		}
		title("Set UL and LR points with the mouse!")
		extent <- drawExtent()
		Sys.sleep(0.6)
		if(zoom){
			text(x=bb@xmin+((bb@xmax-bb@xmin)/2),y=bb@ymin+((bb@ymax-bb@ymin)/2),"OK extent set!\nclosing window...",cex=3)	
		} else {
			text(x=-4,y=21,"OK extent set!\nclosing window...",cex=5)
		}
		Sys.sleep(1.7)
		dev.off()
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
			try(test <- map("worldHires", extent, plot = FALSE),silent = TRUE)
			if (!exists("test")) {
				stop(paste("Country name not valid. Check availability/spelling, i.e. try if it works with: map('worldHires',',",extent, "')", sep = ""))
			}
			extent <- map("worldHires", extent, plot = FALSE)
			extent <- list(xmin = min(extent$range[1:2]), xmax = max(extent$range[1:2]),ymin = min(extent$range[3:4]), ymax = max(extent$range[3:4]))
	
		} else if (class(extent) %in% c("Extent", "RasterLaer", "RasterStack","RasterBrick")) { # if RASTER* object
			if (!inherits(extent,"Extent")) {
				inproj <- projection(extent)
				if (!inproj %in% c("+proj=longlat +datum=WGS84","+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") | !isLonLat(extent)) { # TODO a more trustful check than %in%!
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
  	          
			if(old){
			
				if (toupper(system) == "SRTM") {
					if (extent$ymin >  60){stop("Latitudes are ouside SRTM coverage. Select an area inside Latitudes -60/+60\n")}
					if (extent$ymax < -60){stop("Latitudes are ouside SRTM coverage. Select an area inside Latitudes -60/+60\n")}
					if (extent$ymin < -60){extent$ymin <- -60; warning("Minimum Latitude is out of SRTM coverage, extent is reduced to min LAT -60\n")}
					if (extent$ymax >  60){extent$ymax <- 60;  warning("Maximum Latitude is out of SRTM coverage, extent is reduced to max LAT 60\n")}
				}
				
				minTile <- subset(tiletable, (tiletable$xmin <= extent$xmin & tiletable$xmax >= extent$xmin) & (tiletable$ymin <= extent$ymin & tiletable$ymax >= extent$ymin), select = c(iv, ih))
				minTile <- c(min(minTile$iv), min(minTile$ih))
				maxTile <- subset(tiletable, (tiletable$xmin <= extent$xmax & tiletable$xmax >= extent$xmax) & (tiletable$ymin <= extent$ymax & tiletable$ymax >= extent$ymax), select = c(iv, ih))
				maxTile <- c(max(maxTile$iv), max(maxTile$ih))
				tileV <- as.vector(minTile[1]:maxTile[1])
				tileH <- as.vector(minTile[2]:maxTile[2])
				vmax  <- max(tiletable$iv)
				hmax  <- max(tiletable$ih)
				if (min(tileH) < 0 || max(tileH) > hmax) {
					stop(paste("'tileH' number(s) must be between 0 and",hmax, sep = ""))
				}
				if (min(tileV) < 0 || max(tileV) > vmax) {
					stop(paste("'tileV' number(s) must be between 0 and",vmax, sep = ""))
				}
				vsize <- nchar(vmax)
				hsize <- nchar(hmax)
				tiles <- list()
				for (i in seq(along = tileH)) {
					if (toupper(system) == "SRTM"){
						tiles[[i]] <- paste("_", sprintf(paste("%0", hsize, "d", sep = ""), tileH[i]), "_", sprintf(paste("%0", hsize, "d", sep = ""), tileV), sep = "")
					} else {
						tiles[[i]] <- paste("h", sprintf(paste("%0", hsize, "d", sep = ""), tileH[i]), "v", sprintf(paste("%0", hsize, "d", sep = ""), tileV), sep = "")						
					}
				}
				result <- list(tile = unlist(tiles), tileH = tileH, tileV = tileV,extent = extent, system = system)
				return(result)
		
			} else {
				
				sr <- readOGR(file.path(find.package("MODIS"), "external","modis_latlonWGS84_grid_world.shp"),"modis_latlonWGS84_grid_world",verbose=FALSE)
	
				po   <- Polygon(cbind(c(extent$xmin,extent$xmax,extent$xmax,extent$xmin,extent$xmin),c(extent$ymax,extent$ymax,extent$ymin,extent$ymin,extent$ymax)),hole=FALSE)
				pos  <- Polygons(list(po),"selection")
				spos <- SpatialPolygons(list(pos))
	
				if (is.na(proj4string(spos))) {
					proj4string(spos) <- proj4string(sr)
				}
				selected = sr[spos,]
				tileH  <- unique(as.numeric(selected@data$h))
				tileV  <- unique(as.numeric(selected@data$v))
				result <- as.character(apply(selected@data,1,function(x) {paste("h",sprintf("%02d",x[2]),"v",sprintf("%02d",x[3]),sep="")}))
				result <- list(tile = result, tileH = tileH, tileV = tileV,extent = extent, system = system)
				return(result)
			}
		} else {
			stop("Could not convert extent informtion to a list")
		}
	}
}


