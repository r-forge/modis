MODISoptions <- function(localArcPath, outDirPath, pixelSize, outProj, resamplingType, gdalPath, dlmethod, stubbornness, systemwide = FALSE, print=TRUE)
{
    # This function collects the package options from 3 sites and creates the /.MODIS_opts.R file (location depending on systemwide=T/F, see below):
    # 1. package installation directory (factory defaults); 
    # 2. /R/etc/.MODIS_opts.R for system wide settings (all users of a machine) and 
    # 3. user home "~/.MODIS_opts.R", for user specific settings. 
    # settings are collected in direction 1-3 and each time overwritten if available
    # The final settings are written in to the user specific file 3.
    # options are not tested here! only generated!
    
    # container for all options
    opts  <- new.env()
    
    ##################################
    # 1. factory defaults
    eval(parse(file.path(find.package("MODIS"), "external", "MODIS_Opts.R")),envir=opts) 
    
    # 2. system wide
    sysopts <- paste(R.home(component="etc"), '/', 'MODIS_opts.R', sep='')
    so      <- FALSE
    
    if (file.exists(sysopts))
    {
        eval(parse(sysopts),envir=opts) 
        so <- TRUE
    }
 
    # 3. user specific
    optfile <- file.path("~/.MODIS_Opts.R",fsep="/")
    uo      <- FALSE
    
    if(systemwide)
    {
        if(!file.create(sysopts,showWarnings=FALSE))
        {
            stop("You do not have write permission in ",R.home(component="etc")," to create/change 'systemwide' MODIS options. Set systemwide=FALSE for single user settings or start R as root/admin and run the function again!")
        }
        optfile <- sysopts
        whose   <- 'system wide'
    } else
    {
        if (file.exists(optfile))
        {   
            eval(parse(optfile),envir=opts)
            whose <- 'user'
            uo <- TRUE
        }
    } 
    
    if(!uo)
    {
        if(!so)
        {
            warning("No user nor system settings found for the MODIS package please consult ?MODISoptions before continuing!\n")
        }
    }
    #################################
    opt <- as.list(opts)	
    
    
    # create the '.MODIS_opts.R' file
    filename <- file(optfile, open="wt")
  
    write(paste('# This file contains ', whose,' default values for the R package \'MODIS\'.',sep=""), filename)
    write('# version 0.6-25', filename)
    write('#########################', filename)
  
    write('# 1.) Path and archive structure defaults. (USE FOR SEPARATOR EIGHTER SINGLE FORWARD "/" OR DOUBLE BACKWARD SLASHES "\\\\"):', filename)	
    write('  ', filename)
  
    write('# set path. All data will be stored below this directory. If it doesn\'t exist it is created. Should work also with a remote path like a samba share!',filename)	
    
    if(!missing(localArcPath))
    {
        opt$localArcPath < localArcPath
    }
    write(paste('localArcPath <- \'',opt$localArcPath,'\' # If you already have downloaded some files, don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)    
    write('  ', filename)
          
    write('# set path, default output location for GDAL, FWTools/OSGeo4W, SSOAP, MRT processing results. If it doesn\'t exist it is created.',filename)
    
    if(!missing(outDirPath))
    {
        opt$outDirPath <- outDirPath    
    }
    write(paste('outDirPath   <- \'',opt$outDirPath,'\'',sep=''),filename)
          
    write('  ', filename)
  
    write('#########################', filename)
    
    write('# 2.) download defaults:', filename)
    write('  ', filename)

    if(!missing(dlmethod))
    {
        opt$dlmethod <- dlmethod
    } else 
    {
        opt$dlmethod <- "auto"
    }
    write(paste('dlmethod     <- \'',opt$dlmethod,'\' # Method passed to ?download.file, "auto" is always a good choice' ,sep=''), filename)

    if(!missing(stubbornness))
    {
        opt$stubbornness <- stubbornness
    } else 
    {
        opt$stubbornness <- "high"
    }
    write(paste('stubbornness <- \'',opt$stubbornness,'\' # How stubborn shoud MODIS re-try to connect to ftp? See ?getHdf'  ,sep=''), filename)
    write('  ', filename)
    
    write('#########################', filename)
  
    write('# 3.) Processing defaults:', filename)
    write('  ', filename)
    
    if(!missing(resamplingType))
    {
        opt$resamplingType <- resamlingType    
    } 
    write(paste('resamplingType <- \'',opt$resamplingType,'\' # There are several layers that require "near" (i.e. VI_Quality, Day of the year,...)!',sep=''), filename)
    
    if(!missing(outProj))
    {
        opt$outProj <- outProj
    }
    write(paste('outProj        <- \'',opt$outProj,'\'',sep=''),filename)
    
    if(!missing(pixelSize))
    {
        opt$pixelSize <- pixelSize
    }

    write(paste('pixelSize      <- \'',opt$pixelSize,'\'',sep=''),filename)

          
    write('  ', filename)	
    write('#########################', filename)
  
    write('# 4.) Windows specific section:', filename)
    write('# Set path to "OSGeo4W" (recommanded) or "FWTools" _bin_ directory; (USE FOR SEPARATOR EIGHTER SINGLE FORWARD "/" OR DOUBLE BACKWARD SLASHES "\\\\")', filename)
    write('# Or run: "MODIS:::.checkTools()" for autodetection.', filename)
    write('# Example :', filename)
    write('# gdalPath <- "C:/OSGeo4W/bin"', filename)
    write('  ', filename)
    
    if (!missing(gdalPath))
    {
        opt$gdalPath <- gdalPath
    } 
    if(!is.null(opt$gdalPath))
    {
        write(paste('gdalPath <- "',opt$gdalPath,'"',sep=''), filename)
    } else if (!is.null(opt$GDALpath)) # old style
    {
        opt$gdalPath <- opt$GDALpath
        write(paste('gdalPath <- "',opt$gdalPath,'"',sep=''), filename)
    }
    
    write('  ', filename)	
    close(filename)
    
    if (print) 
    {
        cat('localArcPath  :', opt$localArcPath, '\n' )
        cat('outDirPath    :', opt$outDirPath, '\n')
        cat('auxPath       :', paste(opt$localArcPath,"/.auxiliaries",sep=""), '\n')
        cat('dlmethod      :', opt$dlmethod,'\n')
        cat('stubbornness  :', opt$stubbornness,'\n')
        cat('gdalPath      :', opt$gdalPath, '\n')
        cat('pixelSize     :', opt$pixelSize, '\n')
        cat('outProj       :', opt$outProj, '\n')
        cat('resamplingType:', opt$resamplingType, '\n')
    }
}   



MODISoptions()
