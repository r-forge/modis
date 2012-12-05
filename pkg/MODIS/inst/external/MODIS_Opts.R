# This file contains default values for the R package 'MODIS'.
# version 0.6-23
#########################
# 1.) Path and archive structure defaults. Use single forward slashes "/"):
  
# set path. All data will be stored below this directory. If it doesn't exist it is created. Should work also with a remote path like a samba share!
localArcPath <- '~/MODIS_ARC' # Don't forget to call the function 'orgStruc()' after changing here!!
  
# set path, default output location for GDAL, FWTools/OSGeo4W, SSOAP, MRT processing results. If it doesn't exist it is created.
outDirPath   <- '~/MODIS_ARC/PROCESSED'
  
#########################
# 2.) Processing defaults:
  
resamplingType <- 'NN' # there are several layers that require NN (i.e. VI_Quality, Day of the year,...)!
outProj        <- 'asIn'
pixelSize      <- 'asIn'
  
#########################
# Windows specific section:
# Set path to "OSGeo4W" (recommanded) or "FWTools" _bin_ directory; (USE EIGHTER SINGLE FORWARD "/" OR DOUBLE BACKWARD SLASHES "\\")
# Or run: "MODIS:::.checkTools()" for autodetection.
  
# Example :
# GDALpath <- "C:/OSGeo4W/bin"
  
