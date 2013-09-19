# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011

## this is a helper function
## for the getModisWS.R
## not sure what the best way is here
## to deal with helper functions

createbrickWS <- function(result) 
{  

  ## set raster
  modisprj <- c("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
  res   <- result@cellsize
  nrows <- result@nrows  
  ncols <- result@ncols  
  nl    <- length(result@subset) # nl <- dim(summary(ddd))[1]

  dd <- strsplit(result@subset,"\n") # is the form of result@subset the only option to get the values?

  # modd by Joan Maspons
  if (length(unlist(dd)) == 0){ # No data
    dd <- matrix(nrow=nrows * ncols, ncol=nl)
    warning("No data for these coordinates. Latitude Longitude: ", result@latitude, " ", result@longitude) ##TODO: error vs warning?

  }else{
    dd <- sapply(dd, function(x){
        dat <- strsplit(x, ",")
        dat <- as.numeric(dat[[1]][-1:-5])

        if (length(dat) != nrows * ncols){
          warning("Incorrect MODIS data:\n\t", x) ##TODO: error vs warning?
          dat <- rep(NA, nrows * ncols)
        }

        return(dat)
      })

  }
  
  #dd <- sapply(dd,function(x){as.numeric(strsplit(x,",")[[1]][-1:-5])})
  #dd <- dd * result@scale
  
  if (nl==1) 
  {    
    res <- raster(nrows=nrows, ncols=ncols,xmn=result@xllcorner, xmx=result@xllcorner+(ncols*res),ymn=result@yllcorner, ymx=result@yllcorner+(nrows*res), crs=modisprj)
  } else 
  {
    res <- brick(nrows=nrows, ncols=ncols,xmn=result@xllcorner, xmx=result@xllcorner+(ncols*res),ymn=result@yllcorner, ymx=result@yllcorner+(nrows*res), crs=modisprj)
  }
  
  res <- setValues(res,dd)
  return(res) # brick or raster depends on the layers
}

## TEST
# ornlMODIS = processWSDL("http://daac.ornl.gov/cgi-bin/MODIS/GLBVIZ_1_Glb_subset/MODIS_webservice.wsdl")
# ornlMODISFuncs = genSOAPClientInterface(operations = ornlMODIS@operations[[1]], def = ornlMODIS)

# lat<- 41.38879
# lon<-   2.15899

# lat0<- lon0<- 0 # incorrect data
#
# dates<- getDatesWS(lat, lon, "MOD13Q1")
# radi<- 10
# result1 = ornlMODISFuncs@functions$getsubset(lat, lon, "MOD13Q1", "250m_16_days_NDVI", dates[1], dates[2], radi, radi)
# result0<- ornlMODISFuncs@functions$getsubset(lat0, lon0, "MOD13Q1", "250m_16_days_NDVI", dates[1], dates[2], radi, radi)


##TODO remove?
# createbrickWS <- function(result) {  
#   ## set raster
#   modisprj <-c("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs")
#   res <- result@cellsize
#   nrows <- result@nrows  
#   ncols <- result@ncols
#   rwebs <- raster(nrows=nrows, ncols=ncols, 
#                   xmn=result@xllcorner, xmx=result@xllcorner+(nrows*res), 
#                   ymn=result@yllcorner, ymx=result@yllcorner+(ncols*res), crs=modisprj)
#   ## add values
#   ## extract the data and process
#   dd <- strsplit(result@subset,"\n")
#   ddd <- lapply(dd,strsplit,",")
#   nl <- dim(summary(ddd))[1] ### number of lists i.e. dates!
#   
#   ## combine the layers
#   for(i in 1:nl) {
#     da <- unlist(ddd[[i]])
#     oneimage <- da[6:length(da)] # the data
#     rvalues <- as.vector(oneimage, mode="numeric")
#     rwebs <- setValues(rwebs,rvalues*result@scale)    
#       if (i>1) {
#         mrwebs <- addLayer(mrwebs,rwebs)
#       } else {
#         mrwebs <- rwebs
#       } 
#     }
#   return(brick(mrwebs)) ## return a brick
# }






