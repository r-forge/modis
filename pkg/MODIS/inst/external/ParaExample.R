# 'ParaSource' file for runMRT(). package 'MODIS'; by Matteo Mattiuzzi 25.11.2011
# You can set all parameters or here or directly in the runMRT function. Parameters inside this file are overruling all the others.
# Absolutely needed is only the 'product' (in case of global 'CMG' products!). For tiled data also an extent (or tileH/V) must be spezified! All the rest is facultativ and provided with defaults!

job        <- "MOD11_Austria" # if not set a partially randomised name is created! 
product    <- "MOD11A1"       # see: ?getPRODUCT absolute needed Parameter! type 'data(MODIS_Product); MODIS_Product' or https://lpdaac.usgs.gov/lpdaac/products/modis_products_table to see available one.
startdate  <- "2010.01.01"    # see: ?transDATE. if not set the function will process MODIS from the beginning.
enddate    <- "2010-01-05"    # if not set the function will process MODIS to the last available date.
collection <-  5              # see: ?getCOLLECTION. if not set the newest collection for the given product is used.
extent     <- "austria"       # see: ?getTILE for possibilities. 'extent' or 'tileH/V' are absolutly needed for "TILE" product, but ignored for "CMG" products. If both are provided,'extent' is priorised to tileH/V. 
buffer		 <- 0.1             # See: ?getTILE 
tileH      <- 5:8
tileV      <- 10:15

## 'NULL' is just for visualisation here. You can also remove them completely!
LocalArcPath <- NULL    # if not set see ?runMRT
outDir       <- NULL    # if not set ?runMRT

#### MRT parameters:
# consult MRT manual for details
pixelSize <- NULL # if missing input pixel size is used. 
outProj   <- NULL # if missing "GEOGRAPHIC" is used.
zone      <- NULL # needed only for outProj="UTM", if missing MRT automated detection is used!
datum     <- NULL # if missing "WGS84" is used.   
outPara   <- NULL # if missing all parameters are set to 0.0

SDSstring <- "110011000000" # see: ?getSDS and MRT manual. If not sett all SDS are extraced!

# TODO bit extraction 

