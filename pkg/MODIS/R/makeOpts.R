makeOpts <- function(changeStruc=FALSE)
{
    opts  <- new.env()
    # first load package default settings (originary settings)
    eval(parse(file.path(find.package("MODIS"), "external","MODIS_Opts.R")),envir=opts) # if we need to add an option, this makes it possible
    # then load user default settings and overrule the originary

	if (!file.exists("~/.MODIS_Opts.R"))
	{
        stop("#################################\n IMPORTANT PLEASE READ!\n#################################\n\nThe file containing package defaults doesn't exist!\nOpen \'",file.path(find.package("MODIS"), "external","MODIS_Opts.R") ,"\' with an editor, check/modify the values in that file and save it to: \'", normalizePath("~/.MODIS_Opts.R","/",mustWork=FALSE),"\'\nIf settings are fine as they are, just run the following command:\n\'file.copy('",file.path(find.package('MODIS'), 'external','MODIS_Opts.R'),"','",normalizePath("~/.MODIS_Opts.R","/",mustWork=FALSE),"')",sep="")
	} 

    eval(parse(file.path("~/.MODIS_Opts.R",fsep="/")),envir=opts) # user options are overruling the defaults
    opt <- as.list(opts)	
    
    optfile  <- file.path("~/.MODIS_Opts.R", fsep = "/")
    filename <- file(optfile, open="wt")
    
    write('# This file contains default values for the R package \'MODIS\'.', filename)
    write('# version 0.6-23', filename)
    write('#########################', filename)
    
    write('# 1.) Path and archive structure defaults. Use single forward slashes "/"):', filename)	
    write('  ', filename)
    
    write('# set path. All data will be stored below this directory. If it doesn\'t exist it is created. Should work also with a remote path like a samba share!',filename)	
    write(paste('localArcPath <- \'',opt$localArcPath,'\' # Don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)    
    write('  ', filename)
            
    write('# set path, default output location for GDAL, FWTools/OSGeo4W, SSOAP, MRT processing results. If it doesn\'t exist it is created.',filename)
    write(paste('outDirPath   <- \'',opt$outDirPath,'\'',sep=''),filename)
    write('  ', filename)
    
    write('#########################', filename)
    
    write('# 2.) Processing defaults:', filename)
    write('  ', filename)
    
    write(paste('resamplingType <- \'',opt$resamplingType,'\' # there are several layers that require NN (i.e. VI_Quality, Day of the year,...)!',sep=''), filename)
    write(paste('outProj        <- \'',opt$outProj,'\'',sep=''),filename)
    write(paste('pixelSize      <- \'',opt$pixelSize,'\'',sep=''),filename)
    write('  ', filename)	
    write('#########################', filename)
    
    write('# Windows specific section:', filename)
    write('# Set path to "OSGeo4W" (recommanded) or "FWTools" _bin_ directory; (USE EIGHTER SINGLE FORWARD "/" OR DOUBLE BACKWARD SLASHES "\\\\")', filename)
    write('# Or run: "MODIS:::.checkTools()" for autodetection.', filename)
    write('  ', filename)
    write('# Example :', filename)
    write('# GDALpath <- "C:/OSGeo4W/bin"', filename)
    
    if (!is.null(opt$GDALpath))
    {
        write(paste('GDALpath <- "',opt$GDALpath,'"',sep=''), filename)
    }
    write('  ', filename)	
    
    write('#########################', filename)
    write('# PLEASE DON\'T MODIFY BELOW HERE, NOT IMPLEMENTED FOR CHANGING (YET).', filename)
    write('#########################', filename)
    write('# define, local archive structure. USE \'placeholdes\'!!',filename)
    
    write('# This file uses codified \'placeholders\' for the creation of the local archive structure, or to define the path on an remote location. This \'placeholders\' are than substituted from internal functions using the name of a EOS-file. Use \'placeholders\' only for \'arcStructure\'!!! Don\'t substitute the \'placeholdes\' with a specific value.\n', filename)
    write('# Placeholders are:\n# PLATFORM = "Terra","Aqua", "Combined", "SRTM", or "ENVISAT"\n# PF1 = "MOLT","MOLA" or "MOTA"\n# PF2 = "MOD",MYD" or "MCD"\n# YYYY = year (i.e. \'2009\')\n# DDD  = doy of the year (i.e. \'003\')\n# DATE = YYYY.MM.DD (i.e. \'2009.01.03\')\n# SENSOR = the sensor name (i.e. \'MODIS\')\n# CCC = collection (if applicable) as 3 digits character (i.e. \'005\')\n# C   = collection (if applicable) as numeric value  (i.e. 5)\n# PRODUCT = the product name (i.e. \'MOD13Q1\')\n# TIME = HHMM (MODIS Swath data style don\'t use it for now)\n# "/" = new subdirectory  (i.e. PRODUCT/DATE)\n# "." = internal separator (i.e. PRODUCT.CCC)\n', filename)
    write('# Example: The file \'MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\', the localArcPath<- \'~/MODIS_ARC\' and arcStructure <-\'/SENSOR/PRODUCT.CCC/DATE\' on a UNIX system will generate the following structure: \'/home/YOURUSER/MODIS_ARC/MODIS/MOD13Q1.005/2009.01.17/MOD13Q1.A2009017.h18v04.005.2009036150230.hdf\'\n\n#########################', filename)
    
    if (changeStruc)
    {     
        write(paste('arcStructure <- "/SENSOR/PRODUCT.CCC/DATE" # Don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)
    } else
    {
        write(paste('arcStructure <- \'',opt$arcStructure,'\' # Don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)
    }

    write('################', filename)    	 
    write('  ', filename)
    
    a=0
    for (i in grep(names(opt),pattern="^ftpstring.")) 
    {
        a = a+1
        write(paste('ftpstring',a,' <- ',opt[i], sep=''), filename)
        write('  ', filename)	
    }
    close(filename)
    
    if (changeStruc & opt$arcStructure != "/SENSOR/PRODUCT.CCC/DATE")
    {
        warning("'arcStructure' has been removed from user settings and has been changed to the package default ('/SENSOR/PRODUCT.CCC/DATE'). Please just run 'orgStruc()' to re-organise your MODIS archive accordingly!")
    }
}   



