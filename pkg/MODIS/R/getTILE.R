# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

getTILE <- function(tileH=NULL,tileV=NULL,extent=NULL,buffer=NULL,system="MODIS") {

if(is.null(extent)) {
	if (is.null(tileV)||is.null(tileH)) stop("Provide or an 'extent' or 'tileV+tileH' information!")
extent <- ""
} else {
###########################################
# from mapdata/maps 

if (inherits(extent,"map")){
extent <- list(xmin=min(extent$range[1:2]),xmax=max(extent$range[1:2]),ymin=min(extent$range[3:4]),ymax=max(extent$range[3:4]))
}

if (inherits(extent,"character")){
require(mapdata)
try(test <- map("worldHires",extent,plot=FALSE),silent=TRUE) # for error handling
	if (exists("test")){
		extent  <- map("worldHires",extent,plot=FALSE)
	} else {
		stop(paste("Country name not valid. Check availability/spelling, i.e. try if it works with: map('worldHires',',",extent,"')",sep=""))
	}
extent <- list(xmin=min(extent$range[1:2]),xmax=max(extent$range[1:2]),ymin=min(extent$range[3:4]),ymax=max(extent$range[3:4]))
}
############################################
# extent class "raster* object (extent)"
if (class(extent) %in% c("Extent","RasterLayer","RasterStack","RasterBrick") ){

	if (class(extent) != "Extent"){  
		extent <- extent(extent)# checking if lat/lon !!??
	} 

extent <- list(xmin=extent@xmin,xmax=extent@xmax,ymin=extent@ymin,ymax=extent@ymax)
}
####################################
# extent class "list"
if (inherits(extent,"list")){ # all possible extent classes should have been converted to a list

if(length(extent$extent)==4) {extent<-extent$extent}

#if (length(extent)==2) {  } # if extent it is a point!

if (!is.null(buffer)) {
	if (length(buffer)==1) {buffer <- c(buffer,buffer)}
extent[1] <- as.numeric(extent[1]) - buffer[1]
extent[2] <- as.numeric(extent[2]) + buffer[1]
extent[3] <- as.numeric(extent[3]) - buffer[2]
extent[4] <- as.numeric(extent[4]) + buffer[2]
}

if(system=="MODIS") {
	data("tiletable")
	} else if (system=="MERIS") {
	tiletable <- genTILE(tileSize=5)
	}

  minTile <- subset(tiletable,
                  (tiletable$xmin <= extent$xmin & tiletable$xmax >= extent$xmin) &
                  (tiletable$ymin <= extent$ymin & tiletable$ymax >= extent$ymin)
         ,select=c(iv,ih))
  minTile <- c(min(minTile$iv),min(minTile$ih))
    
  maxTile <-  subset(tiletable,
                  (tiletable$xmin <= extent$xmax & tiletable$xmax >= extent$xmax) &
                  (tiletable$ymin <= extent$ymax & tiletable$ymax >= extent$ymax)
         ,select=c(iv,ih))
  maxTile <- c(max(maxTile$iv),max(maxTile$ih))

  tileV <- minTile[1]:maxTile[1]
  tileH <- minTile[2]:maxTile[2]
}#
} 
###################################
# get the results

tileH <- as.vector(tileH)
tileV <- as.vector(tileV)

vmax <- max(tiletable$iv)
hmax <- max(tiletable$ih)

if (min(tileH) < 0 || max(tileH) > hmax) {stop(paste("'tileH' number(s) must be between 0 and",hmax,sep=""))}
if (min(tileV) < 0 || max(tileV) > vmax) {stop(paste("'tileV' number(s) must be between 0 and",vmax,sep=""))}

vsize <- nchar(vmax)
hsize <- nchar(hmax)

tiles <- list()	
for (i in seq(along=tileH)){
	tiles[[i]] <- paste("h",sprintf(paste("%0",hsize,"d",sep=""),tileH[i]),"v",sprintf(paste("%0",hsize,"d",sep=""),tileV),sep="")	
}
result <- list(tile=unlist(tiles),tileH=tileH,tileV=tileV,extent=extent,system=system)

return(result)
}


