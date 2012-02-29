# 'ParaSource' file for runMrt(). package 'MODIS'; by Matteo Mattiuzzi 25.11.2011
# You can set all parameters or here or directly in the runMrt function. Parameters inside this file are overruling all the others.
# Absolutely needed is only the 'product' (in case of global 'CMG' products!). For tiled data also an extent (or tileH/V) must be spezified! All the rest is facultativ and provided with defaults!

job        <- "MOD11_Austria" # if not set a partially randomised name is created! 
product    <- "MOD11A1"       # see: absolute needed Parameter! Type getProduct() to list supported products
begin      <- "2010.01.01"    # see: ?transDate. if not set the function will process MODIS from the beginning.
end        <- "2010-01-05"    # if not set the function will process MODIS to the last available date.
collection <-  5              # see: ?getCollection. if not set the newest collection for the given product is used.
extent     <- "austria"       # see: ?getTile for possibilities. 'extent' or 'tileH/V' are absolutly needed for "TILE" product, but ignored for "CMG" products. If both are provided,'extent' is priorised to tileH/V. 
buffer     <- 0.1             # See: ?getTile 
tileH      <- 5:8
tileV      <- 10:15

## 'NULL' is just for visualisation here. You can also remove them completely!
localArcPath <- NULL    # if not set see MODIS:::.getDef('localArcPath')?runMrt
outDirPath   <- NULL    # if not set MODIS:::.getDef('outDirPath')

#### MRT parameters:
# consult MRT manual for details
pixelSize <- NULL # if missing input pixel size is used. 
# resamplingType <- NULL # iff missing MODIS:::.getDef('resamplingType') is used!
outProj   <- NULL # if missing MODIS:::.getDef('outProj')
zone      <- NULL # needed only for outProj="UTM", if missing MRT automated detection is used!
datum     <- NULL # if missing "WGS84" is used.   
outPara   <- NULL # if missing all parameters are set to 0.0

SDSstring <- "110011000000" # see: ?getSds and MRT manual. If not sett all SDS are extraced!

mosaic <- TRUE # should multiple MODIS tiles be mosaiced?
anonym <- TRUE # no job name in output files


# TODO bit extraction 

####


