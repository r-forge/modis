.onLoad <- function(lib, pkg)  {
	pkg.info <- drop(read.dcf(file=system.file("DESCRIPTION", package=pkg), fields=c("Version","Date")))
	packageStartupMessage(paste("\n",pkg, " version ", pkg.info["Version"], " (", pkg.info["Date"], ")\n\nThe MODIS package is still in an early development status. So bugs and substantial changes are very frequent!\nMODIS_manual: http://www.wuala.com/IVFL/R_MODIS/\n", sep=""))
	
	if (!file.exists("~/.MODIS_Opts.R")) {

	packageStartupMessage("#########################\n IMPORTANT PLEASE READ!\n#########################\nThe 'defaults' file does not exist. This file contains all important package options.\nOpen \'", file.path(find.package("MODIS"), "external","MODIS_Opts.R") ,"\' with an editor, check/modify the values in that file and save it to: \'", path.expand("~/.MODIS_Opts.R"),"\'")

	} else {
	
	# eval(parse("/home/matteo/R/x86_64-pc-linux-gnu-library/2.14/MODIS/external/MODIS_Opts.R"),env=opts)
	opts  <- new.env()
	eval(parse(file.path(find.package("MODIS"), "external","MODIS_Opts.R")),env=opts) # if we need to add an option, this makes it possible
	eval(parse(file.path("~/.MODIS_Opts.R")),env=opts) # this options are overwriting the original one
	opt <- as.list(opts)	

	optfile  <- file.path("~/.MODIS_Opts.R")
	filename <- file(optfile, open="wt")

	write('# This file contains default values for the R package \'MODIS\'.', filename)
	write('# version 0', filename)
	write('#########################', filename)
	write('# This file uses codified \'placeholders\' for the creation the loacal archive structure, or to define the path on an remote location. This \'placeholders\' are than substituted from internal package functions using the name of a EOS-file. Use \'placeholders only for \'arcStructure\'!!! Don\'t substitute the \'placeholdes\' with a specific value, do only modify the order or the existance of \'placeholders\'.\n', filename)
	write('# Placeholders are:\n# PLATFORM = "Terra","Aqua", "Combined" or "ENVISAT"\n# PF1 = "MOLT","MOLA" or "MOTA"\n# PF2 = "MOD",MYD" or "MCD"\n# YYYY = year (i.e. \'2009\')\n# DDD  = doy of the year (i.e. \'003\')\n# DATE = YYYY.MM.DD (i.e. \'2009.01.03\')\n# SENSOR = the sensor name (i.e. \'MODIS\')\n# CCC = collection (if applicable) as 3 digits character (i.e. \'005\')\n# C   = collection (if applicable) as numeric value  (i.e. 5)\n# PRODUCT = the product name (i.e. \'MOD13Q1\')\n# TIME = HHMM (MODIS Swath data style don\'t use it for now)\n# new directory sublevel "/" (i.e. PRODUCT/DATE)\n# internal separator: "." (i.e. PRODUCT.CCC)\n', filename)
	write('# Example: The file \'MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\', the localArcPath<- \'~/MODIS_ARC\' and arcStructure <-\'/SENSOR/PRODUCT.CCC/DATE\' on a UNIX system will generate the following structure: \'/home/YOURUSER/MODIS_ARC/MODIS/MOD13Q1.005/2009.01.17/MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\'\n\n#########################', filename)
	write('# Path and archive structure defaults:', filename)	
	write('  ', filename)
	write('# set real path. All data will be stored below this directory. If it doesn\'t exist it is created.',filename)	
	write(paste('localArcPath <- \'',opt$localArcPath,'\'', sep=''), filename)
	write('  ', filename)
	write('# set, real path, default output location for GDAL, FWT, SSOAP, MRT processing results. If it doesn\'t exist it is created.',filename)
	write(paste('outDirPath   <- \'',opt$outDirPath,'\'',sep=''),filename)
	write('  ', filename)
	write('# define, local archive structure. USE \'placeholdes\'!!',filename)
	write(paste('arcStructure <- \'',opt$arcStructure,'\'', sep=''), filename)
	write('  ', filename)
	write('#########################', filename)
	write('# Processing defaults:', filename)
	write('  ', filename)
	write(paste('resamplingType <- \'',opt$resamplingType,'\'',sep=''), filename)
	write(paste('outProj        <- \'',opt$outProj,'\'',sep=''),filename)
	write('  ', filename)	
	write('#########################', filename)
	write('# Example ftpstring\n# If you have a personal MODIS datapool within your LAN and you face problems in the creation of an additional \'ftpstring\' please contact one of us.\n# Use \'placeholders\' only in \'variablepath\'\n# Additional \'placeholders\':\n# DATE1DATE2 period start/end (MERIS specific)\n# REGION (MERIS specific) MERIS date is stores in regions\n\n# ftpstring0 <- list(name=\'sitename\',SENSOR=\'sensorname\', basepath=\'/base/path\',variablepath=\'/variable/path/\',content=c(\'what data is awailable? The idea is more images + aux data and not dataformats!',filename)	
	write('  ', filename)	
	a=0
	for (i in grep(names(opt),pattern="^ftpstring.")) {
	a = a+1
	write(paste('ftpstring',a,' <- ',opt[i], sep=''), filename)
	write('  ', filename)	
	}
	close(filename)

	} 

}



