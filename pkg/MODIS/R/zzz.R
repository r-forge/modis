.onLoad <- function(lib, pkg)
{
  # Starting message taken from pkg raster (R.J.Hijmans)
	pkg.info <- utils::packageDescription('MODIS')
	packageStartupMessage(paste("\nMODIS version ", pkg.info[["Version"]], " (", pkg.info["Date"], ") \nMODIS_manual: https://www.dropbox.com/sh/18t0rgcm6bga7xt/-4k_Xwojxr/MODIS\nTo install the complete set of suggested packages run: MODIS:::checkDeps()", sep=""))
    
	if (!file.exists("~/.MODIS_Opts.R"))
	{
        packageStartupMessage(
            "#################################\n IMPORTANT PLEASE READ!\n#################################\n\nThe file containing package defaults doesn't exist!\nOpen \'",file.path(find.package("MODIS"), "external","MODIS_Opts.R") ,"\' with an editor, check/modify the values in that file and save it to: \'", normalizePath("~/.MODIS_Opts.R","/",mustWork=FALSE),"\'\nIf settings are fine as they are just copy the file with:\n\'file.copy('",file.path(find.package('MODIS'), 'external','MODIS_Opts.R'),"','",normalizePath("~/.MODIS_Opts.R","/",mustWork=FALSE),"')",sep="")

	} else 
	{
	
	    opts  <- new.env()
	    eval(parse(file.path(find.package("MODIS"), "external","MODIS_Opts.R")),envir=opts) # if we need to add an option, this makes it possible
    	eval(parse(file.path("~/.MODIS_Opts.R",fsep="/")),envir=opts) # user options are overruling the defaults
    	opt <- as.list(opts)	

    	optfile  <- file.path("~/.MODIS_Opts.R", fsep = "/")
    	filename <- file(optfile, open="wt")

    	write('# This file contains default values for the R package \'MODIS\'.', filename)
    	write('# version 0', filename)
    	write('#########################', filename)
    	write('# This file uses codified \'placeholders\' for the creation of the local archive structure, or to define the path on an remote location. This \'placeholders\' are than substituted from internal functions using the name of a EOS-file. Use \'placeholders\' only for \'arcStructure\'!!! Don\'t substitute the \'placeholdes\' with a specific value.\n', filename)
    	write('# Placeholders are:\n# PLATFORM = "Terra","Aqua", "Combined", "SRTM", or "ENVISAT"\n# PF1 = "MOLT","MOLA" or "MOTA"\n# PF2 = "MOD",MYD" or "MCD"\n# YYYY = year (i.e. \'2009\')\n# DDD  = doy of the year (i.e. \'003\')\n# DATE = YYYY.MM.DD (i.e. \'2009.01.03\')\n# SENSOR = the sensor name (i.e. \'MODIS\')\n# CCC = collection (if applicable) as 3 digits character (i.e. \'005\')\n# C   = collection (if applicable) as numeric value  (i.e. 5)\n# PRODUCT = the product name (i.e. \'MOD13Q1\')\n# TIME = HHMM (MODIS Swath data style don\'t use it for now)\n# "/" = new subdirectory  (i.e. PRODUCT/DATE)\n# "." = internal separator (i.e. PRODUCT.CCC)\n', filename)
    	write('# Example: The file \'MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\', the localArcPath<- \'~/MODIS_ARC\' and arcStructure <-\'/SENSOR/PRODUCT.CCC/DATE\' on a UNIX system will generate the following structure: \'/home/YOURUSER/MODIS_ARC/MODIS/MOD13Q1.005/2009.01.17/MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\'\n\n# Once you have modyfied values in sec 1. use the function \'orgStruc()\' to re-organise your archive\n\n#########################', filename)

    	write('# 1.) Path and archive structure defaults:', filename)	
    	write('  ', filename)

    	write('# set path. All data will be stored below this directory. If it doesn\'t exist it is created.',filename)	
    	write(paste('localArcPath <- \'',opt$localArcPath,'\' # Don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)
    	write('  ', filename)

    	write('# set path, default output location for GDAL, FWT, SSOAP, MRT processing results. If it doesn\'t exist it is created.',filename)
    	write(paste('outDirPath   <- \'',opt$outDirPath,'\'',sep=''),filename)
    	write('  ', filename)

    	write('# define, local archive structure. USE \'placeholdes\'!!',filename)
    	write(paste('arcStructure <- \'',opt$arcStructure,'\' # Don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)
    	write('  ', filename)
    	write('#########################', filename)

    	write('# 2.) Processing defaults:', filename)
    	write('  ', filename)

    	write(paste('resamplingType <- \'',opt$resamplingType,'\'',sep=''), filename)
    	write(paste('outProj        <- \'',opt$outProj,'\'',sep=''),filename)
    	write('  ', filename)	
    	write('#########################', filename)

    	write('# Windows specific (run: "MODIS:::.checkTools()" for inputs)', filename)
    	write('  ', filename)
    	
    	if (is.null(opt$FWToolsPath))
    	{
        	write('# Example:', filename)
        	write('# FWToolsPath <- "C:/Programms/FWTools2.4.7/bin"', filename)
    	} else 
    	{
        	write(paste('FWToolsPath <- "',opt$FWToolsPath,'"',sep=''), filename)
    	}
    	write('  ', filename)	

    	write('#########################', filename)
    	write('# PLEASE DON\'T MODIFY BELOW HERE, NOT IMPLEMENTED YET.\n# Example ftpstring\n# 3.) If you have a personal MODIS datapool within your LAN and you face  problems in the creation of an additional \'ftpstring\' please contact one of us.\n# Use \'placeholders\' only in \'variablepath\'\n# Additional \'placeholders\':\n# DATE1DATE2 period start/end (MERIS specific)\n# REGION (MERIS specific) MERIS date is stores in regions\n\n# ftpstring0 <- list(name=\'sitename\',SENSOR=\'sensorname\', basepath=\'/base/path\',variablepath=\'/variable/path/\',content=c(\'what data is awailable? \'images\', \'metadata\'!',filename)	
    	write('  ', filename)	
 
    	a=0
    	for (i in grep(names(opt),pattern="^ftpstring.")) 
    	{
        	a = a+1
        	write(paste('ftpstring',a,' <- ',opt[i], sep=''), filename)
        	write('  ', filename)	
    	}
    	close(filename)
	} 
}



