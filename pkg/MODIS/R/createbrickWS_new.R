# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011

## this is a helper function
## for the getModisWS.R
## not sure what the best way is here
## to deal with helper functions

createbrickWSX <- function(result) {	
	## set raster
	modisprj <-c("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
	res   <- result@cellsize
	nrows <- result@nrows	
	ncols <- result@ncols	
	nl    <- length(result@subset) # nl <- dim(summary(ddd))[1]

	dd <- strsplit(result@subset,"\n")# is the form of result@subset the only option to get the values?
	dd <- sapply(dd,function(x){as.numeric(strsplit(x,",")[[1]][-1:-5])})
	dd <- dd * result@scale

	if (nl==1) {		
	res <- raster(nrows=nrows, ncols=ncols,xmn=result@xllcorner, xmx=result@xllcorner+(ncols*res),ymn=result@yllcorner, ymx=result@yllcorner+(nrows*res), crs=modisprj)
	} else {
	res <- brick(nrows=nrows, ncols=ncols,xmn=result@xllcorner, xmx=result@xllcorner+(ncols*res),ymn=result@yllcorner, ymx=result@yllcorner+(nrows*res), crs=modisprj)
	}

res <- setValues(res,dd)
return(res) # brick or raster depends on the layers
}

