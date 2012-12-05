filename <- file("/home/matteo/Desktop/MODIS/pkg/MODIS/inst/external/MODIS_internals.R", open="wt")

write('# This file contains default values for the R package \'MODIS\'.', filename)
write('# version 0.6-25', filename)

write('#########################', filename)
write('# PLEASE DON\'T MODIFY, NOT IMPLEMENTED FOR CHANGING (YET).', filename)
write('#########################', filename)
write('# define, local archive structure. USE \'placeholdes\'!!',filename)

write('# This file uses codified \'placeholders\' for the creation of the local archive structure, or to define the path on an remote location. This \'placeholders\' are than substituted from internal functions using the name of a EOS-file. Use \'placeholders\' only for \'arcStructure\'!!! Don\'t substitute the \'placeholdes\' with a specific value.\n', filename)
write('# Placeholders are:\n# PLATFORM = "Terra","Aqua", "Combined", "SRTM", or "ENVISAT"\n# PF1 = "MOLT","MOLA" or "MOTA"\n# PF2 = "MOD",MYD" or "MCD"\n# YYYY = year (i.e. \'2009\')\n# DDD  = doy of the year (i.e. \'003\')\n# DATE = YYYY.MM.DD (i.e. \'2009.01.03\')\n# SENSOR = the sensor name (i.e. \'MODIS\')\n# CCC = collection (if applicable) as 3 digits character (i.e. \'005\')\n# C   = collection (if applicable) as numeric value  (i.e. 5)\n# PRODUCT = the product name (i.e. \'MOD13Q1\')\n# TIME = HHMM (MODIS Swath data style don\'t use it for now)\n# "/" = new subdirectory  (i.e. PRODUCT/DATE)\n# "." = internal separator (i.e. PRODUCT.CCC)\n', filename)
write('# Example: The file \'MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\', the localArcPath<- \'~/MODIS_ARC\' and arcStructure <-\'/SENSOR/PRODUCT.CCC/DATE\' on a UNIX system will generate the following structure: \'/home/YOURUSER/MODIS_ARC/MODIS/MOD13Q1.005/2009.01.17/MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\'\n\n#########################', filename)

write(paste('arcStructure <- "/SENSOR/PRODUCT.CCC/DATE" # Don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)
write('#########################', filename)         
write('  ', filename)

a=0
for (i in grep(names(opt),pattern="^ftpstring.")) 
{
    a = a+1
    write(paste('ftpstring',a,' <- ',opt[i], sep=''), filename)
    write('  ', filename)	
}

close(filename)



