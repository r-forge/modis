job <- "Austria_LST"
product <- "MYD11A1"  ## For available products run: " data("MODIS_Products");MODIS_Products " or see: https://lpdaac.usgs.gov/lpdaac/products/modis_products_table !!!
startdate <- "2008.01.01"  ## start-date YYYY.MM.DD, limit periode to be downloaded/processed
enddate   <- "2008.01.02"  ## end-date YYYY.MM.DD,limit periode to be downloaded/processed
extent    <-  list(lat_min=46.12,lat_max=49.3,lon_min=9.2,lon_max=17.47) # see: ?getTILE for possibilities
# outDir <- "./MRTresult"

####### consult MRT manual for details
# pixelsize <- xxx # empty for no change
resample  <- "NN" # "NN", "CC" or "BI" (if missin "NN" is used)
outProj   <- "GEOGRAPHIC" # See: MRT doc for available (if missing "GEOGRAPHIC" is used)
#UTM_zone <- 33 # only needed for: outProj <- "UTM" 
# ProjParam <- TODO

# extract SDS
SDSstring <- "110011000000" # run: getSDS(HdfName="name.hdf") to create the string 

# encode bits TODO


