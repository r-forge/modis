# setPath for localArcPath and outDirPath
setPath <- function(path)
{
    path <- normalizePath(path, "/", mustWork = FALSE)
    if(!file.exists(path)) 
    {
        stopifnot(dir.create(path, recursive = TRUE, showWarnings = TRUE))
        warning(path," does not exists, it will be created!")
    }
    path
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
        stop("Unknown 'tool'. Allowed are 'MRT' or 'GDAL'")
        
    }
    if(outProj=="asIn") # lot of troubles because of this!
    {
        return("asIn")    
    }
    
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
            stop("'EPSG' code is not valid, please check!")
        } else
        {
            return(EPSGinfo$prj4[ind])
        }    
    }
    if (tool == "MRT")
    {
        MRTprojs <- matrix(byrow=T,ncol=2,c("AEA", "Albers Equal Area", "ER", "Equirectangular", "GEO", "Geographic", 
                                            "IGH", "Interrupted Goode Homolosine", "HAM", "Hammer", "ISIN", "Integerized Sinusoidal", 
                                            "LA", "Lambert Azimuthal Equal Area", "LCC", "Lambert Conformal Conic", 
                                            "MERCAT", "Mercator", "MOL", "Molleweide", "PS", "Polar Stereographic", 
                                            "SIN", "Sinusoidal", "TM", "Transverse Mercator", "UTM", "Universal Transverse Mercator"),
                                            dimnames=list(NULL,c("short","long")))
        
        ind <- which(MRTprojs==outProj)
        
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

# well doOptions() would do the entire job, maybe it is somehow redundant processing to do it like that. Maybe it makes more sense to put the single funs (setPath,...) in the parameter retrieval/generation part in the function itself (getHdf,runGdal,runMrt,...) so only required argumetns are checked.
 
doOptions <- function(tool, quiet=FALSE,...) 
{
    opts  <- MODIS:::.getDef()
    Fopts <- list(...)
    
    # overwrite 'opts' with 'Fopts'
    if (!is.null(Fopts))
    {
        opts <- c(Fopts, opts[(!names(opts) %in% names(Fopts))])
    }
    
    opts$localArcPath   <- MODIS:::setPath(opts$localArcPath)
    opts$outDirPath     <- MODIS:::setPath(opts$outDirPath)
    opts$auxPath        <- dir.create(paste(opts$localArcPath,"/.auxiliaries",sep=""),showWarnings=FALSE)
    opts$resamplingType <- MODIS:::checkResamplingType(opts$resamplingType,tool=tool,quiet=quiet)  
    opts$pixelSize      <- opts$pixelSize 
    opts$outProj        <- MODIS:::checkOutProj(opts$outProj,tool=tool,quiet=quiet)
return(opts)
}


