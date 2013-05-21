MODISoptions <- function(localArcPath, outDirPath, pixelSize, outProj, resamplingType, gdalPath, dlmethod, stubbornness, systemwide = FALSE, quiet=FALSE, save=TRUE, checkPackages=TRUE)
{
    # This function collects the package options from up to 3 files and creates the .MODIS_opts.R file (location depending on systemwide=T/F, see below):
    # 1. package installation directory (factory defaults); 
    # 2. /R/etc/.MODIS_opts.R for system wide settings (all users of a machine) and 
    # 3. user home "~/.MODIS_opts.R", for user specific settings. 
    # settings are collected in direction 1-3 and each time overwritten if available
    # The final settings are written in to the user specific file 3.
    # options are not tested here! only generated!
    
    if(checkPackages)
    {
        # check if all suggested packages are installed:
        suggestedPackages <- MODIS:::checkDeps()
    } else
    {
        suggestedPackages <- "run 'MODISoptions(checkPackages=TRUE)' for further details"
    }
    # container for all options
    opts  <- new.env()
    
    ##################################
    # 1. factory defaults
    eval(parse(file.path(find.package("MODIS"), "external", "MODIS_Opts.R")),envir=opts) 
    
    # 2. system wide
    sysopts <- paste(R.home(component="etc"), '/', '.MODIS_opts.R', sep='')
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
            stop("You do not have write permission in ",R.home(component="etc")," to create/change 'systemwide' MODIS options. Set 'systemwide=FALSE' for single user settings or start R as root/admin and run again 'MODISoptions'!")
        }
        optfile <- sysopts
        whose   <- 'systemwide'
    } else
    {
        if (file.exists(optfile))
        {   
            eval(parse(optfile),envir=opts)
            uo <- TRUE
        }
        whose <- 'user'
    } 
    
    if(!uo)
    {
        if(!so & save)
        {
            warning("No MODIS 'user' nor 'systemwide' settings file found. File is created for '",whose,"'-settings in: ",normalizePath(optfile,'/',mustWork=FALSE),sep="")
        } else if (!save)
        {
            warning("No MODIS 'user' nor 'systemwide' settings file found, using default settings. Use '?MODISoptions' to configure the 'MODIS' package and make settings permanent!")
        }
    }
    #################################
    opt <- as.list(opts)	
    
    # localArcPath
    opt$localArcPath <- path.expand(opt$localArcPath)
    
    if(!missing(localArcPath))
    {
        localArcPath <- path.expand(localArcPath) 
                   
        if (!file.exists(opt$localArcPath))
        {
            message("'localArcPath' does not exist, it will be created in '",localArcPath,"'")               
        } else if (opt$localArcPath != localArcPath)
        {
            message("Changing 'localArcPath' from '",opt$localArcPath, "' to '", localArcPath,"'\nIf you already have downloaded some HDF-files, you can use '?orgStruc()' to re-arrange your HDF-data!")
        }
        opt$localArcPath <- localArcPath
    } else
    {
        if (!file.exists(opt$localArcPath))
        {
            message("'localArcPath' does not exist, it will be created in '",opt$localArcPath,"'. Consult '?MODISoptions' if you want to change it!")               
        }    
    }
    
    # outDirPath
    opt$outDirPath <- path.expand(opt$outDirPath)
        
    if(!missing(outDirPath))
    {
        outDirPath <- path.expand(outDirPath)
        
        if (!file.exists(opt$outDirPath))
        {
            message("'outDirPath' does not exist and will be created in '",outDirPath,"'")               
        } else if (opt$outDirPath != outDirPath)
        {
            message("'outDirPath' has been changed from '",opt$outDirPath,"' to '",outDirPath,"'")
        }
        opt$outDirPath <- outDirPath
    } else
    {
        if (!file.exists(opt$outDirPath))
        {
            message("'outDirPath' does not exist, it will be created in '",opt$outDirPath,"'. Consult '?MODISoptions' if you want to change it!")               
        }    
    }
    
    # auxPath (hard coded)
    opt$auxPath <- path.expand(paste(opt$outDirPath,"/.auxiliaries",sep=""))
       
    if(!missing(dlmethod))
    {
        dlmethod <- tolower(dlmethod)
        stopifnot(dlmethod %in% c("auto","internal","wget","curl","lynx"))
        opt$dlmethod <- dlmethod
    }
    
    if(!missing(stubbornness))
    {
        opt$stubbornness <- stubbornness
    }
    
    if(!missing(resamplingType))
    {
        stopifnot(tolower(resamplingType) %in% c('nn', 'cc', 'bil','near', 'bilinear', 'cubic','cubicspline','lanczos', 'average', 'mode'))
        MODIS:::checkResamplingType
        
        opt$resamplingType <- resamplingType    
    } 

    if(!missing(outProj))
    {
        opt$outProj <- outProj
    }

    if(!missing(pixelSize))
    {
        opt$pixelSize <- pixelSize
    }
   
    if (!missing(gdalPath))
    {
        if(!exists("gdalPath")) # this can happen on Windows by using single backslash...I hope this solves the problem! 
        {
            if(.Platform$OS=="unix")
            {
                stop("Your 'gdalPath' is not ok. Use single forward slash!")
            } else
            {
                stop("Your 'gdalPath' is not ok. Use single forward or double backward slash!")
            }
        } else
        {
            if(.Platform$OS=="windows")
            {
                gdalPath <- normalizePath(shortPathName(normalizePath(gdalPath,winslash="/")),winshlash"/")
            } else
            {
                gdalPath <- path.expand(gdalPath)
            }
        
        }
        opt$gdalPath <- gdalPath
    }
    
    if (save)
    {    
        #  create the '.MODIS_opts.R' file
        filename <- file(optfile, open="wt")
  
        write(paste('# This file contains ', whose,' default values for the R package \'MODIS\'.',sep=""), filename)
        write('# version 0.8-13', filename)
        write('# consult \'?MODISoptions\' for details and explanations', filename)
        write('  ', filename)
        write('#########################', filename)
        write('# 1.) Path and archive structure defaults.', filename)
        write('# consult \'?MODISoptions\' for more details', filename)
        write('# USE SINGLE FORWARD SLASH "/" (also on WINDOWS)', filename)
        write('# If path does not exist it is created!', filename)
        write('# Work also with network share!', filename)
        write('  ', filename)
        
        write('# All HDF-data will be (properly) stored in this directory.',filename)	
        write(paste('localArcPath <- \'',opt$localArcPath,'\'', sep=''), filename)    
        write('  ', filename)
        
        write('# Default output location for MODIS package processing results.',filename)
        write(paste('outDirPath   <- \'',opt$outDirPath, '\'',sep=''),filename)
        write('  ', filename)
        
        write('#########################', filename)
        write('# 2.) download defaults:', filename)
        write('# consult \'?MODISoptions\' for more details', filename)
        write('  ', filename)
        write(paste('dlmethod     <- \'',opt$dlmethod,'\'' ,sep=''), filename)
        write(paste('stubbornness <- \'',opt$stubbornness,'\'',sep=''), filename)
        write('  ', filename)
        
        write('#########################', filename)
        write('# 3.) Processing defaults:', filename)
        write('# It is highly recommended to not modify here, at least not \'resamplingType\' as there are several layers that require NN (i.e. VI_Quality, Day of the year,...)!', filename)
        write('# consult \'?MODISoptions\' for more details', filename)
        write('  ', filename)
        write(paste('resamplingType <- \'',opt$resamplingType,'\'',sep=''), filename)
        write(paste('outProj        <- \'',opt$outProj,'\'',sep=''),filename)
        write(paste('pixelSize      <- \'',opt$pixelSize,'\'',sep=''),filename)
        write('  ', filename)	
        write('#########################', filename)
        write('# 4.) Set path to GDAL _bin_ directory', filename)
        write('# More related to Windows, but also to other OS in case of a non standard location of GDAL', filename)
        write('# ON WINDOWS install \'OSGeo4W\' (recommanded) or \'FWTools\'', filename)
        write('# consult \'?MODISoptions\' for more details', filename)        
        write('# Run: \'MODIS:::.checkTools()\' to try to autodetect.', filename)
        write('# Example (USE SINGLE FORWARD SLASH \'/\'!):', filename)
        write('# gdalPath <- \'C:/OSGeo4W/bin\'', filename)
        write('  ', filename)

        if (!is.null(opt$gdalPath))
        {
            write(paste("gdalPath <- '",opt$gdalPath,"'",sep=''), filename)
        }
       
        write('  ', filename)	
        close(filename)
    }    
    
    # checks if the pointed GDAL supports HDF4 
    if(checkPackages)
    {
        # GDAL
        isOk <- MODIS:::checkGdalDriver(path=opt$gdalPath)
        if (isOk) 
        {
            gdal <- list(GDAL = TRUE, version = MODIS:::checkTools(tool="GDAL",quiet=TRUE)$GDAL$version)
        } else
        {    
            gdal <- list(GDAL = FALSE, version = "Not available. Use 'MODIS:::checkTools('GDAL')' for more information!")
        }
        
        # MRT
        MRT <- MODIS:::checkTools(tool="MRT",quiet=TRUE)$MRT
        
        if(MRT$MRT)
        {
            mrt <- MRT$version
            opt$mrtPath <- TRUE
        } else
        {
            mrt <- "Not available. Use 'MODIS:::checkTools('MRT')' for more information!"
            opt$mrtPath <- FALSE
        }
    } else
    {
        gdal <- list()
        gdal$version <- "Not checked, run 'MODISoptions(checkPackages=TRUE)'"
        mrt          <- "Not checked, run 'MODISoptions(checkPackages=TRUE)'"
        opt$mrtPath  <- FALSE
    }
 
    if (!quiet) 
    {
        cat('\nSTORAGE:\n')
        cat('_______________\n')
        cat('localArcPath  :', opt$localArcPath, '\n' )
        cat('outDirPath    :', opt$outDirPath, '\n\n\n')
        
        cat('DOWNLOAD:\n')
        cat('_______________\n')
        cat('dlmethod      :', opt$dlmethod,'\n')
        cat('stubbornness  :', opt$stubbornness,'\n\n\n')
        
        cat('PROCESSING:\n')
        cat('_______________\n')
        cat('GDAL          :', gdal$version, '\n')
        cat('MRT           :', mrt, '\n')
        cat('pixelSize     :', opt$pixelSize, '\n')
        cat('outProj       :', opt$outProj, '\n')
        cat('resamplingType:', opt$resamplingType, '\n\n\n')
        
        cat('DEPENDENCIES:\n')
        cat('_______________\n')
        cat(suggestedPackages,'\n\n')
    }
    
    # remove ftpstring* from opt (old "~/.MODIS_Opts.R" style)
    oldftp <- grep(names(opt),pattern="^ftpstring*")
    
    if(length(oldftp)>1)
    {
        opt <- opt[-oldftp]
    }
        
    # set the options
    for (i in seq_along(opt))
    {
        if (is.character(opt[[i]]))
        {

            eval(parse(text=paste("options(MODIS_",names(opt[i]),"='",opt[[i]],"')",sep="")))
        } else
        {
            eval(parse(text=paste("options(MODIS_",names(opt[i]),"=",opt[[i]],")",sep="")))
        }
    }
    # this is fix
    options(MODIS_arcStructure='/SENSOR/PRODUCT.CCC/DATE')
}   


