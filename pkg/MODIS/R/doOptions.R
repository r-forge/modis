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
            warning("By not using resamplingType='near' some SDS become useless (ie all bit encoded Quality SDS's, or 'day of the year' SDS's). It is strongly recommanded to use resamplingType='near'!")
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
        return("asIn")    
    }
    # this is here becaus we could think in a conversoin between GDAL and MRT inputs!
    MRTprojs <- matrix(byrow=T,ncol=2,
        c("AEA", "Albers Equal Area", "ER", "Equirectangular", "GEO", "Geographic", 
          "IGH", "Interrupted Goode Homolosine", "HAM", "Hammer", "ISIN", "Integerized Sinusoidal", 
          "LA", "Lambert Azimuthal Equal Area", "LCC", "Lambert Conformal Conic", 
          "MERCAT", "Mercator", "MOL", "Molleweide", "PS", "Polar Stereographic", 
          "SIN", "Sinusoidal", "TM", "Transverse Mercator", "UTM", "Universal Transverse Mercator"),
          dimnames=list(NULL,c("short","long")))
    
    if (tool=="GDAL") # EPRS:xxxx or xxxx or "+proj=sin...." 
    { # EPSGinfo is lazy loaded (see: minorFuns.R)
        if (substring(outProj,1,1)=="+") 
        {
            if(length(grep(EPSGinfo$prj4,pattern=outProj))==0)
            {
                stop("'EPSG' code is not valid, plesae check!")
            } else
            {
                return(outProj)
            }
        }
        outProj <- as.numeric(gsub(outProj,pattern="EPSG:",replacement=""))
        ind <- which(EPSGinfo$code==outProj) 
        
        if (length(ind)==0)
        {
            stop("checkOptProj Error: 'EPSG' information is not valid, please check CRS string!")
        } else
        {
            return(EPSGinfo$prj4[ind])
        }    
    }
    if (tool == "MRT")
    {
        ind <- grep(MRTprojs,pattern=outProj,ignore.case=TRUE)
        
        if(length(ind)==0)
        {
            cat("'outProj' must be one of:\n")
            return(MRTprojs)
        } else
        {
            if(ind > nrow(MRTprojs)) # catch short name
            {
                ind <- ind-nrow(MRTprojs)
            }
            return(MRTprojs[ind])
        }
    }
}



# returns 0 if a given GDAL supports HDF4 else 1 
checkGdalDriver <- function(path=NULL)
{
    if(.Platform$OS=="windows")
    {
        if(!is.null(path))
        {
            path <- paste(normalizePath(path,"\\",mustWork=FALSE),sep="")
            path <- paste(paste(strsplit(path,"\\\\")[[1]],sep="",collapse="\\"),"\\",sep="")
            path <- shortPathName(path)
        }
        
        driver <- shell(paste(path,'gdalinfo.exe --formats',sep=""),intern=TRUE)
        if(length(grep(driver,pattern="HDF4"))==0)
        {
            # test file from HDF group http://www.hdfgroup.org/tutorial4.html 
            try(test <- shell(paste(path,'gdalinfo ',shortPathName(system.file("external", "sdunl.hdf", package="MODIS")),sep=""),intern=TRUE),silent=TRUE) 
            if (test[1]!="Driver: HDF4Image/HDF4 Dataset")
            {
                FALSE
            } else 
            {
                TRUE    
            }
        } else 
        {
            TRUE
        }
    } else
    { # Linux...should always work with any GDAL... but so it is schecked it it is on path or not installed!
        if (is.null(path))
        {
            try(driver <- system('gdalinfo --formats',intern=TRUE),silent=TRUE)
        } else
        {
            try(driver <- system(paste(file.path(path,'gdalinfo'),' --formats',sep=""),intern=TRUE), silent=TRUE)
        }
        
        if(length(grep(driver,pattern="HDF4"))==0)
        {
            FALSE
        } else
        {
            TRUE
        }
    }
}        
 
combineOptions <- function(...) 
{
    opts <- options() # collects all defaults
    opts <- opts[grep(names(opts),pattern="^MODIS_*.")] # isolate MODIS_opts
    if(length(opts)==0)
    {
        MODISoptions()    
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


