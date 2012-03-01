# This file contains default values for the R package 'MODIS'.
# version 0
#########################
# This file uses codified 'placeholders' for the creation the local archive structure, or to define the path on an remote location. This 'placeholders' are than substituted from internal package functions using the name of a EOS-file. Use 'placeholders' only for 'arcStructure'!!! Don't substitute the 'placeholdes' with a specific value, do only modify the order or the existance of 'placeholders'.

# Placeholders are:
# PLATFORM = "Terra","Aqua", "Combined" or "ENVISAT"
# PF1 = "MOLT","MOLA" or "MOTA"
# PF2 = "MOD",MYD" or "MCD"
# YYYY = year (i.e. '2009')
# DDD  = doy of the year (i.e. '003')
# DATE = YYYY.MM.DD (i.e. '2009.01.03')
# SENSOR = the sensor name (i.e. 'MODIS')
# CCC = collection (if applicable) as 3 digits character (i.e. '005')
# C   = collection (if applicable) as numeric value  (i.e. 5)
# PRODUCT = the product name (i.e. 'MOD13Q1')
# TIME = HHMM (MODIS Swath data style don't use it for now)
# new directory sublevel "/" (i.e. PRODUCT/DATE)
# internal separator: "." (i.e. PRODUCT.CCC)

# Example: The file 'MOD13Q1.A2009017.h18v04.005.2009036150230.hdf', the localArcPath<- '~/MODIS_ARC' and arcStructure <-'/SENSOR/PRODUCT.CCC/DATE' on a UNIX system will generate the following structure: '/home/YOURUSER/MODIS_ARC/MODIS/MOD13Q1.005/2009.01.17/MOD13Q1.A2009017.h18v04.005.2009036150230.hdf'

# Once you have modyfied values in sec 1. use the function 'orgStruc()' to re-organise your archive

#########################
# 1.) Path and archive structure defaults:
  
# set real path. All data will be stored below this directory. If it doesn't exist it is created.
localArcPath <- '~/MODIS_ARC'
  
# set, real path, default output location for GDAL, FWT, SSOAP, MRT processing results. If it doesn't exist it is created.
outDirPath   <- '~/MODIS_ARC/PROCESSED'
  
# define, local archive structure. USE 'placeholdes'!!
arcStructure <- '/PRODUCT.CCC/DATE'
  
#########################
# 2.) Processing defaults:
  
resamplingType <- 'NN'
outProj        <- 'GEOGRAPHIC'
  
#########################
# PLEASE DON'T MODIFY BELOW HERE, NOT IMPLEMENTED YET.
# Example ftpstring
# 3.) If you have a personal MODIS datapool within your LAN and you face problems in the creation of an additional 'ftpstring' please contact one of us.
# Use 'placeholders' only in 'variablepath'
# Additional 'placeholders':
# DATE1DATE2 period start/end (MERIS specific)
# REGION (MERIS specific) MERIS date is stores in regions

# ftpstring0 <- list(name='sitename',SENSOR='sensorname', basepath='/base/path',variablepath='/variable/path/',content=c('what data is awailable? The idea is more images + aux data and not dataformats!
  
ftpstring1 <- list(name = "LPDAAC", SENSOR = "MODIS", basepath = "ftp://e4ftl01.cr.usgs.gov", variablepath = "/PF1/PRODUCT.CCC/DATE/", content = c("images", "metadata"))
  
ftpstring2 <- list(name = "LAADS", SENSOR = "MODIS", basepath = "ftp://ladsftp.nascom.nasa.gov/allData", variablepath = "/C/PRODUCT/YYYY/DDD/", content = "images")
  
ftpstring3 <- list(name = "Culture-MERIS", SENSOR = "MERIS", basepath = "ftp://culturemeris:culturemeris@ionia2.esrin.esa.int", variablepath = "/DATE1DATE2/REGION/", content = "images")
  
