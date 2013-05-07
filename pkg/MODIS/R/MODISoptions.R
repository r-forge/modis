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
            stop("You do not have write permission in ",R.home(component="etc")," to create/change 'systemwide' MODIS options. Set systemwide=FALSE for single user settings or start R as root/admin and run again 'MODISoptions'!")
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
            warning("No MODIS 'user' nor 'systemwide' settings file found. File is created for '",whose,"' options in: ",normalizePath(optfile,'/',mustWork=FALSE)
                    ,".\nPlease consult ?MODISoptions before continuing!",sep="")
        } else if (!save)
        {
            warning("No MODIS 'user' nor 'systemwide' settings file found. File is _not_ created since 'save=FALSE'. Run 'MODISoptions' with 'save=TRUE' if you want to make make settings permanent!")
        }
    }
    #################################
    opt <- as.list(opts)	
    
    if(!missing(localArcPath))
    {

        if(opt$localArcPath != localArcPath)
        {
            cat("Changing 'localArcPath' from",opt$localArcPath, "to", localArcPath,"\n")
        }
        opt$localArcPath <- localArcPath
    }

    opt$localArcPath <- MODIS:::setPath(opt$localArcPath)
    
    if(!missing(outDirPath))
    {
        if(opt$outDirPath != outDirPath)
        {
            cat("Changing 'outDirPath' from",opt$outDirPath, "to", outDirPath,"\n")
        }
        opt$outDirPath <- outDirPath    
    }
    opt$outDirPath <- MODIS:::setPath(opt$outDirPath)

    if(!missing(dlmethod))
    {
        opt$dlmethod <- dlmethod
    }
    
    if(!missing(stubbornness))
    {
        opt$stubbornness <- stubbornness
    }
    
    if(!missing(resamplingType))
    {
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
        gp <- gdalPath
        if(!exists("gp"))
        {
            if(.Platform$OS=="unix")
            {
                stop("Your 'gdalpath' is not ok. Use single forward slash!")
            } else
            {
                stop("Your 'gdalpath' is not ok. Use single forward or double backward slash!")
            }
        } else
        {
            if(.Platform$OS=="windows")
            {
                gp <- shortPathName(normalizePath(gdalPath,winslash="/"))
            } else
            {
                gp <- path.expand(gdalPath)
            }
        
        }
               
        opt$gdalPath <- gp
    }
    
    if (save)
    {    
        #  create the '.MODIS_opts.R' file
        filename <- file(optfile, open="wt")
  
        write(paste('# This file contains ', whose,' default values for the R package \'MODIS\'.',sep=""), filename)
        write('# version 0.7-10', filename)
        write('#########################', filename)
        write('# 1.) Path and archive structure defaults. (USE FOR SEPARATOR EIGHTER SINGLE FORWARD "/" OR DOUBLE BACKWARD SLASHES "\\\\"):', filename)	
        write('  ', filename)
        write('# set path. All data will be stored below this directory. If it doesn\'t exist it is created. Should work also with a remote path like a network directory!',filename)	
        write(paste('localArcPath <- \'',opt$localArcPath,'\' # If you already have downloaded some files, don\'t forget to call the function \'orgStruc()\' after changing here!!', sep=''), filename)    
        write('  ', filename)
        write('# set path, default output location for GDAL, FWTools/OSGeo4W, SSOAP, MRT processing results. If it doesn\'t exist it is created.',filename)
        write(paste('outDirPath   <- \'',opt$outDirPath, '\'',sep=''),filename)
        write('  ', filename)
        write('#########################', filename)
        write('# 2.) download defaults:', filename)
        write('  ', filename)
        write(paste('dlmethod     <- \'',opt$dlmethod,'\' # Method passed to ?download.file, "auto" is always a good choice, if you encouter problems (like "file not found") consider using "wget"' ,sep=''), filename)
        write(paste('stubbornness <- \'',opt$stubbornness,'\' # How stubborn should MODIS re-try to connect to ftp/http? See ?getHdf'  ,sep=''), filename)
        write('  ', filename)
        write('#########################', filename)
        write('# 3.) Processing defaults:', filename)
        write('  ', filename)
        write(paste('resamplingType <- \'',opt$resamplingType,'\' # There are several layers that require "near" (i.e. VI_Quality, Day of the year,...)!',sep=''), filename)
        write(paste('outProj        <- \'',opt$outProj,'\'',sep=''),filename)
        write(paste('pixelSize      <- \'',opt$pixelSize,'\'',sep=''),filename)
        write('  ', filename)	
        write('#########################', filename)
        write('# 4.) Windows specific section (could also be used in Linux if you want to point to an alternative GDAL installation not in the default search path. Point ".../gdal-x.x.x/apps" directory!):', filename)
        write('# Set path to "OSGeo4W" (recommanded) or "FWTools" _bin_ directory or any HDF4 supporting GDAL instllation (location of "gdalinfo"); (USE FOR SEPARATOR _SINGLE FORWARD_ "/")', filename)
        write('# Or run: "MODIS:::checkTools()" for autodetection.', filename)
        write('# Example :', filename)
        write('# gdalPath <- "C:/OSGeo4W/bin"', filename)
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
      isOk <- MODIS:::checkGdalDriver(path=opt$gdalPath)
      if (isOk) 
      {
          gdal <- list(GDAL = TRUE, version = "enabled")
      } else
      {    
          gdal <- list(GDAL = FALSE, version = "Not available. Use 'MODIS:::checkTools('GDAL')' for more information!")
      }
    
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
      mrt <- "Not checked, run 'MODISoptions(checkPackages=TRUE)'"
      opt$mrtPath <- FALSE
    }
    opt$auxPath <- MODIS:::setPath(paste(opt$localArcPath,"/.auxiliaries",sep=""))
    
    if (!quiet) 
    {
        cat('\nSTORAGE\n')
        cat('localArcPath  :', opt$localArcPath, '\n' )
        cat('outDirPath    :', opt$outDirPath, '\n\n')
        # cat('auxPath       :', opt$auxPath , '\n\n')
        
        cat('DOWNLOAD\n')
        cat('dlmethod      :', opt$dlmethod,'\n')
        cat('stubbornness  :', opt$stubbornness,'\n\n')
        
        cat('PROCESSING\n')
        cat('GDAL          :', gdal$version, '\n')
        cat('MRT           :', mrt, '\n')
        cat('pixelSize     :', opt$pixelSize, '\n')
        cat('outProj       :', opt$outProj, '\n')
        cat('resamplingType:', opt$resamplingType, '\n\n')
        
        cat('DEPENDENCIES\n')
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
    # this is fixed
    options(MODIS_arcStructure='/SENSOR/PRODUCT.CCC/DATE')
}   


