# This file contains Internal unt user accessed information.
# version 0.6-25
#########################
# PLEASE DON'T MODIFY, NOT IMPLEMENTED FOR CHANGING (YET).
#########################
  
# This file uses codified 'placeholders' for the creation of the local archive structure, or to define the path on an remote location. This 'placeholders' are than substituted from internal functions using the name of a EOS-file. Use 'placeholders' only for 'arcStructure'!!! Don't substitute the 'placeholdes' with a specific value.

# Placeholders are:
# PLATFORM = "Terra","Aqua", "Combined", "SRTM", or "ENVISAT"
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
# "/" = new subdirectory  (i.e. PRODUCT/DATE)
# "." = internal separator (i.e. PRODUCT.CCC)
  
# Create ftpstring:
# Example: The file 'MOD13Q1.A2009017.h18v04.005.2009036150230.hdf', the localArcPath<- '~/MODIS_ARC' and arcStructure <-'/SENSOR/PRODUCT.CCC/DATE' on a UNIX system will generate the following structure: '/home/YOURUSER/MODIS_ARC/MODIS/MOD13Q1.005/2009.01.17/MOD13Q1.A2009017.h18v04.005.2009036150230.hdf'
#########################
  
ftpstring1 <- list(name = "LPDAAC", SENSOR = "MODIS", basepath = "ftp://e4ftl01.cr.usgs.gov", variablepath = "/PF1/PRODUCT.CCC/DATE/", content = c("images", "metadata"))
  
ftpstring2 <- list(name = "LAADS", SENSOR = "MODIS", basepath = "ftp://ladsftp.nascom.nasa.gov/allData", variablepath = "/C/PRODUCT/YYYY/DDD/", content = "images")
  
ftpstring3 <- list(name = "Culture-MERIS", SENSOR = "MERIS", basepath = "ftp://culturemeris:culturemeris@ionia2.esrin.esa.int", variablepath = "/DATE1DATE2/REGION/", content = "images")
  
ftpstring4 <- list(name = "JRC.it", SENSOR = "C-Band-RADAR", basepath = "ftp://xftp.jrc.it/pub/srtmV4/tiff", variablepath = NULL, content = "images")
  
ftpstring5 <- list(name = "Telescience", SENSOR = "C-Band-RADAR", basepath = "http://hypersphere.telascience.org/elevation/cgiar_srtm_v4/tiff/zip", variablepath = NULL, content = "images")
  
ftpstring6 <- list(name = "CGIAR", SENSOR = "C-Band-RADAR", basepath = "http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff", variablepath = NULL, content = "images")
  
