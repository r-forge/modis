# 'ParaSource' file for runMrt(). package 'MODIS'; by Matteo Mattiuzzi 25.11.2011
# You can set all parameters or here or directly in the runMrt function. Parameters inside this file are overruling all other settings.
# Absolutely needed is only the 'product' (in case of global 'CMG' products!). For tiled data also an extent (or tileH/V) must be specified! All the rest is facultativ and provided with defaults!

# if not set a partially randomised name is created! 
job        <- "MOD11_Austria" 
outDirPath <- NULL # if not set MODIS:::.getDef('outDirPath')

# product information see: ?getProduct or ?getCollection
product    <- "MOD11A1" # absolute needed Parameter! Type "getProduct()" to list supported products
collection <-  5        # if not set the newest collection for the given product is used.

# temporal subset see: ?transDate
begin  <- "2010.01.01" # if not set the function will process MODIS from the beginning.
end    <- "2010002"    # if not set the function will process MODIS to the last available date.

# spatial subset see: ?getTile
extent     <- "austria" 
buffer     <- 0.1           
# tileH      <- 5:8							
# tileV      <- 10:15						

# other 
pixelSize      <- NULL # in output projection units, if missing input pixel size is used. 
resamplingType <- NULL # if missing MODIS:::.getDef('resamplingType') is used!
outProj        <- NULL # if missing MODIS:::.getDef('outProj')
datum          <- NULL # if missing "WGS84" is used.   
outPara        <- NULL # if missing all parameters are set to 0.0...
zone           <- NULL # needed only for outProj="UTM", if missing MRT automated detection is used!

# Extract strings
SDSstring <- "101" # exteract only the first and the third layer (SDS). If not set all SDS are extraced! see: ?getSds and MRT manual. 

# should multiple input tiles be mosaicked? Normaly TRUE is ok, but HDF has a size limit of 2GB, in such a case the processing will not be acomplished. In this case you have to set FALSE
mosaic <- TRUE # should multiple MODIS tiles be mosaiced?

# If anonym <- FALSE the jobname is included to the output filenames
anonym <- TRUE


