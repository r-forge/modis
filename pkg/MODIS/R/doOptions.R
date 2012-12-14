# setPath for localArcPath and outDirPath
setPath <- function(path)
{
    path <- normalizePath(path, "/", mustWork = FALSE)
    if(!file.exists(path)) 
    {
        stopifnot(dir.create(path, recursive = TRUE, showWarnings = TRUE))
        warning(path," does not exists, it will be created!")
    }
    normalizePath(path,"/")
}

# this function handles the parameter resamplingTpye and must be placed inside runMrt() and runGdal()
checkResamplingType <- function(resamplingType,tool,quiet=FALSE) 
{
    if (missing(resamplingType))
    {
        resamplingType <- "near"
    }   
    
    resamplingType <- trim(tolower(as.character(resamplingType)))
    tool           <- toupper(tool)
    if (!tool %in% c("GDAL","MRT"))
    {
        stop("Unknown 'tool'. Allowed are 'MRT' or 'GDAL'")
    }
    
    if (resamplingType %in% c("nn","cc","bil") & tool=="GDAL")
    {
        if(resamplingType=="nn")
        {
            resamplingType <- "near"
        }
        if(resamplingType=="cc")
        {
            resamplingType <- "cubic"
        }
        if(resamplingType=="bil")
        {
            resamplingType <- "bilinear"
        }
    }
    
    if (tool=="MRT")
    {
        if(resamplingType %in% c("near","nn"))
        {
            resamplingType <- "nn"
        } else if(resamplingType %in% c("cc","cubic"))
        {
            resamplingType <- "cc"
        } else if(resamplingType %in% c("bil","bilinear"))
        {
            resamplingType <- "bil"
        } else if (resamplingType %in% c("cubicspline","lanczos"))
        {
            if(!quiet)
            {
                warning(resamplingType," resamling is only supported by GDAL, not by MRT tool. If you use MRT 'near' is used insead")
            }
            resamplingType='nn'
        } else
        {
            if(!quiet)
            {
                warning(resamplingType," not supported by 'MRT' using 'NN'")
            }
            resamplingType='nn'
        }
    }
    if (resamplingType %in% c("cc","bil","bilinear","cubic","cubicspline","lanczos"))
    {    
        if(!quiet)
        {
            warning("By not using resamplingType='near'/'nn' some SDS become useless (ie all bit encoded Quality SDS's, or 'day of the year' SDS's). It is strongly recommanded to use resamplingType='near'!")
        }
    }
    
    if (tool=="MRT")
    {
        toupper(resamplingType)
    } else
    {
        tolower(resamplingType)
    }    
    return(resamplingType)
}

# checks validity of outProj and returns for tool="MRT" the short name (see mrt manual) and in case of "GDAL" the prj4 string!
checkOutProj <- function(outProj, tool, quiet=FALSE)
{
    tool <- toupper(tool)
    if (!tool %in% c("GDAL", "MRT"))
    {
        stop("checkOptProj Error: Unknown 'tool'. Allowed are 'MRT' or 'GDAL'")
        
    }
    if(outProj=="asIn") # lot of troubles because of this!
    {
        return(outProj)
    }
    # this is here because we could think in a conversoin between GDAL and MRT inputs! (the possible once)
    MRTprojs <- matrix(byrow=T,ncol=2,
        c("AEA", "Albers Equal Area", "ER", "Equirectangular", "GEO", "Geographic", 
          "IGH", "Interrupted Goode Homolosine", "HAM", "Hammer", "ISIN", "Integerized Sinusoidal", 
          "LA", "Lambert Azimuthal Equal Area", "LCC", "Lambert Conformal Conic", 
          "MERCAT", "Mercator", "MOL", "Molleweide", "PS", "Polar Stereographic", 
          "SIN", "Sinusoidal", "TM", "Transverse Mercator", "UTM", "Universal Transverse Mercator"),
          dimnames=list(NULL,c("short","long")))
    
    if (tool=="GDAL") # EPRS:xxxx or xxxx or "+proj=sin...." 
    { # EPSGinfo is lazy loaded (see: minorFuns.R)
        if(!inherits(outProj,"CRS"))
        {
            outProj <- CRS(gsub(outProj,pattern="^EPSG:",replacement="+init=epsg:"))@projargs
            return(outProj)
        }    
    }
    
    if (tool == "MRT")
    {
        ind <- grep(MRTprojs,pattern=paste("^",outProj,"$",sep=""),ignore.case=TRUE)
        
        if(length(ind)==0)
        {
            cat("'outProj' must be one of:\n")
            return(MRTprojs)
        } else
        {
            
            if(ind > nrow(MRTprojs)) # catch short name
            {
                indL <- ind
                ind  <- ind-nrow(MRTprojs)
            } else
            {
                indL <- ind+nrow(MRTprojs)
            }
            
            return(list(short = MRTprojs[ind],long = MRTprojs[indL]))
        }
    }
}



# returns 0 if a given GDAL supports HDF4 else 1 
checkGdalDriver <- function(path=NULL)
{
  inW <- options("warn")$warn
  
  if(.Platform$OS=="windows")
    {
        if(!is.null(path))
        {
            path <- paste(normalizePath(path,"\\",mustWork=FALSE),sep="")
            path <- paste(paste(strsplit(path,"\\\\")[[1]],sep="",collapse="\\"),"\\",sep="")
            path <- shortPathName(path)
        }
        options(warn=-1)
        try(driver <- shell(paste(path,'gdalinfo.exe --formats',sep=""),intern=TRUE),silent=TRUE)
        if(length(grep(driver,pattern="HDF4"))==0)
        {
        #    test file from HDF group http://www.hdfgroup.org/tutorial4.html 
        #    try(test <- shell(paste(path,'gdalinfo.exe ',shortPathName(system.file("external", "sdunl.hdf", package="MODIS")),sep=""),intern=TRUE),silent=TRUE) 
        #    if (test[1]!="Driver: HDF4Image/HDF4 Dataset")
        #    {
              out <- FALSE
        #    } else 
        #    {
        #      out <- TRUE    
        #    }
        } else 
        {
          out <- TRUE
        }
    } else
    { # Linux...should always work with any GDAL... but so it is schecked if it is on path or not installed!
        if (is.null(path))
        {
            try(driver <- system('gdalinfo --formats',intern=TRUE),silent=TRUE)
        } else
        {
            try(driver <- system(paste(file.path(path,'gdalinfo'),' --formats',sep=""),intern=TRUE), silent=TRUE)
        }
        
        if(length(grep(driver,pattern="HDF4"))==0)
        {
          out <- FALSE
        } else
        {
          out <- TRUE
        }
    }
  options(warn=inW)
  out
}        
 
combineOptions <- function(...) 
{
    opts <- options() # collects all defaults
    opts <- opts[grep(names(opts),pattern="^MODIS_*.")] # isolate MODIS_opts
    
    if(length(opts)==0)
    {
        if(!file.exists("~/.MODIS_Opts.R"))
        {
            cat("MODIS_Opts file not found, run '?MODISoptions' to see and set permanent package defaults!\n")
        }
        MODISoptions(save=FALSE,quiet=TRUE)    
        opts <- options() # collects all defaults
        opts <- opts[grep(names(opts),pattern="^MODIS_*.")] # isolate MODIS_opts
    }
    
    names(opts) <- gsub(names(opts),pattern="MODIS_",replacement="") # convert names to function arg style 

    Fopts <- list(...) # collects fun args
    
    # overwrite 'opts' with 'Fopts'
    if (!is.null(Fopts))
    {
        opts <- c(Fopts, opts[(!names(opts) %in% names(Fopts))])
    }
return(opts)
}


