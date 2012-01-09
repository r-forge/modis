# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011

## this is a helper function
## for the getModisWS.R
## not sure what the best way is here
## to deal with helper functions

## if extent is 1x1km!!!
## needs to be changed

createbrickWS <- function(result) {	
	## set raster
	modisprj <-c("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
	res <- result@cellsize
	nrows <- result@nrows	
	ncols <- result@ncols
	rwebs <- raster(nrows=nrows, ncols=ncols, 
									xmn=result@xllcorner, xmx=result@xllcorner+(9*res), 
                  ymn=result@yllcorner, ymx=result@yllcorner+(9*res), crs=modisprj)
	## add values
	## extract the data and process
	dd <- strsplit(result@subset,"\n")
	ddd <- lapply(dd,strsplit,",")
	nl <- dim(summary(ddd))[1] ### number of lists i.e. dates!
	
	## combine the layers
	for(i in 1:nl) {
		da <- unlist(ddd[[i]])
		oneimage <- da[6:length(da)] # the data
		rvalues <- as.vector(oneimage, mode="numeric")
		rwebs <- setValues(rwebs,rvalues*result@scale)		
			if (i>1) {
				mrwebs <- addLayer(mrwebs,rwebs)
			} else {
				mrwebs <- rwebs
			} 
		}
	return(brick(mrwebs)) ## return a brick
}






