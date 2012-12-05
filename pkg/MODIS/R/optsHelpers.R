# Adapion of the options handling functions used in the raster package by Robert J. Hjimans 

modisOptions <- function(localArcPath, outDirPath, gdalpath, outProj, pixelSize, resamplingType, reset=FALSE, save=FALSE) 
{

    
    # setPath for localArcPath and outDirPath
    setPath <- function(path)
    {
        path <- normalizePath(path, "/", mustWork = FALSE)
        if(length(dir(path))==0) 
        {
            warning(path,"does not exists, it will be created!")
            dir.create(path, recursive = TRUE, showWarnings = TRUE)
        }
        path
    }
    
    setLocalArcPath <- function(localArcPath)
    {
        options(MODIS_localArcPath <- setPath(localArcPath)
    }

    setOutDirPath <- function(outDirPath)
    {
        options(MODIS_outDirPath <- setPath(outDirPath)
    }
    
    setoutProj <- function(outProj)
    {
        
        options(MODIS_optProj <- )
    }
    
    setResamplingType <- function(resamplingType) 
    {
            
        if (missing(resamplingType))
        {
            resamplingType <- "near"
        }
        
        resamplingType <- trim(tolower(as.character(resamplingType)))
        
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

        if (resamplingType %in% c("cubicspline","lanczos"))
        {
            warning(resamplingType," is only supported by GDAL, not by MRT tool. If you use MRT 'near' is used insead")
        }
        
        if (resamplingType %in% c("near", "bilinear","cubic","cubicspline","lanczos"))
        {    
            if(resamplingType != "near")
            {
                warning("Not using 'near' makes some SDS useless (ie all bit encoded Quality SDS's, or 'day of the year' SDS's. It is strongly recommanded to use 'near'!")
            }
            options(MODIS_resamplingType = resamplingType)
        } else 
        {
            options(MODIS_resamplingType = 'near')
            warning("Could not find ",resamplingType,", using: 'near'")
        }
    }

    setGdalPath <- function(path="auto")
    {
        GDAL <- 0
        
        if (.Platform$OS=="unix")
        {    
            gdal <- try(system("gdalinfo --version",intern=TRUE),silent=TRUE)
            if (inherits(gdal,"try-error"))
            {
                cat("   GDAL not found, install it or check path settings in order to use related functionalities!\n")
            } else 
            {
                gdal <- system("which gdalinfo",intern=TRUE) # is not really needed...
                gdal <- dirname(gdal)
                options(MODIS_gdalPath = gdal)                
                GDAL <- 1
            }    
            
        } else 
        {
            # if GDALpath is not set manually, try if it is already in the system settings
            if (is.null(MODIS:::MODISpackageOpts$GDALpath))
            {
                cmd <- 'gdalinfo --version'
            } else
            {
                cmd <- file.path(shortPathName(MODIS:::MODISpackageOpts$GDALpath),'gdalinfo --version',fsep="\\")            
            }
            gdal <- shell(cmd,intern=TRUE)
            
            if (length(grep(x=gdal,pattern="GDAL"))==0)
            {
                cat("'FWTools/OSGeo4W' installation not found or path not set.\nIf you don't have installed one of them you can get it from 'http://fwtools.maptools.org/' or 'http://trac.osgeo.org/osgeo4w/' (recommanded)\n")

                if(tolower(path)=="auto")
                {
                    cat("Trying to autodetect path to 'FWTools/OSGeo4W' (this may takes some time):\n")    
                    gdal <- dirname(list.files(path="c:/",pattern="^gdalinfo.exe$", full.names=TRUE, recursive=TRUE,include.dirs=TRUE))

                    fwt <- gdal[grep(gdal,pattern="FWTools")]
                    osg <- gdal[grep(gdal,pattern="OSGeo4W")]
                    
                    if (length(fwt)==1 & length(osg)==1)
                    {
                        cat("Found 'FWTools' and 'OSGeo4W' installation, trying to fetch the newer GDAL verison\n")
                        
                        fwtP <- shQuote(shortPathName(normalizePath(paste(fwt,"/gdalinfo.exe",sep=""),winslash="/")))
                        fwtV <- shell(paste(fwtP, "--version"),intern=TRUE)
                        fwtV <- strsplit(strsplit(fwtV,",")[[1]][1]," ")[[1]][2]
                        
                        osgP <- shQuote(shortPathName(normalizePath(paste(osg,"/gdalinfo.exe",sep=""),winslash="/")))
                        osgV <- shell(paste(osgP, "--version"),intern=TRUE)
                        osgV <- strsplit(strsplit(osgV,",")[[1]][1]," ")[[1]][2]
                        
                        for (ug in 1:max(nchar(osgV),nchar(fwtV)))
                        {
                            osgT <- substr(osgV,ug,ug)
                            fwtT <- substr(fwtV,ug,ug)
                            
                            if (osgT!="." | fwtT!=".")
                            {
                                if(isTRUE(osgT>fwtT))
                                {
                                    gdal <- normalizePath(osg,winslash="/") 
                                    break   
                                }
                            }
                            if (ug==max(nchar(osgV),nchar(fwtV)))
                            {
                                gdal <- normalizePath(osg,winslash="/")                         
                            }
                        }                 
                        if (length(gdal)==0)
                        {
                            cat("Could not determine the versions, using 'OSGeo4W' installation.\n")
                            gdal <- osg
                        }
                    }
                    
                #  'manual' suggested by Steven Mosher
                } else if (tolower(path) == manual) 
                {
                    cat("Manual search, pleace navigate to your 'gdalinfo.exe' file.")
                    if(require(require(tcltk))) # is tcltk in the base R?
                    {
                        gdal <- as.character(tkgetOpenFile(filetypes = "{{Gdal Info exe} {gdalinfo.exe}} "))
                    } else
                    {
                        gdal <- file.choose() 
                    }
                    gdal <- dirname(normalizePath(gdal,"/"))
                }
                
                if (length(gdal)==0)
                {
                    stop("No 'FWTools/OSGeo4W' installation(s) found! In order to use related function please solve this problem first.\n")
                }
                options(MODIS_gdalPath <- gdal)                
        }
        
    } 
    
    
    if (.isSupportedFormat(format))
    {	
            options(rasterFiletype = format)	
        } else { 
            warning(paste('Cannot set filetype to unknown or unsupported file format:', format, '. See writeFormats()'))
        }
    }
    
    setOverwrite <- function(overwrite) {
        if (is.logical(overwrite)) { 
            options(rasterOverwrite = overwrite)
        } else { 
            warning(paste('Could not set overwrite. It must be a logical value'))
        }
    }
    
    setDataType <- function(datatype) {
        if (datatype %in% c('LOG1S', 'INT1S', 'INT2S', 'INT4S', 'INT4U', 'INT1U', 'INT2U', 'FLT4S', 'FLT8S')) {	
            options(rasterDatatype = datatype)
        } else { 
            warning(paste('Cannot set datatype to unknown type:',datatype))	
        }
    }
    
    setTmpdir <- function(tmpdir) {
        if (!missing(tmpdir)) {
            tmpdir <- trim(tmpdir)
            if (tmpdir != '') {
                lastchar = substr(tmpdir, nchar(tmpdir), nchar(tmpdir))
                if (lastchar != "/" & lastchar != '\\') {
                    tmpdir <- paste(tmpdir, '/', sep='')
                }		
                res <- file.exists(substr(tmpdir, 1, nchar(tmpdir)-1))
                if (!res) { 
                    res <- dir.create(tmpdir, recursive=TRUE, showWarnings = FALSE) 
                }
                if (res) { 
                    options(rasterTmpDir = tmpdir) 
                } else { 
                    warning(paste('could not create tmpdir:',tmpdir))	
                }
            }
        }
    }
    
    setTmpTime <- function(tmptime) {
        if (is.numeric(tmptime)) {
            if (tmptime > 1) {
                options(rasterTmpTime = tmptime)
            } else {
                warning(paste('Could not set tmptime. It must be > 1'))	
            }
        } else {
            warning(paste('Could not set tmptime. It must be a numerical value'))	
        }
    }
    
    setProgress <- function(progress) {
        if (is.character(progress)) {
            progress <- tolower(trim(progress))
            if (progress %in% c('window', 'tcltk', 'windows')) { progress <- 'window' }
            if (! progress %in% c('text', 'window', '')) { 
                warning('invalid value for progress. Should be "window", "text", or ""')
            } else {
                options(rasterProgress = progress )
            }
        } else {
            warning('progress must be a character value')
        }
    }
    
    setTimer <- function(timer) {
        if (is.logical(timer)) {
            options(rasterTimer = timer )
        } else {
            warning(paste('timer must be a logical value'))	
        }
    }
    
    
    setToDisk <- function(todisk) {
        if (is.logical(todisk)) { 
            options(rasterToDisk = todisk )
        } else {
            warning(paste('todisk argument must be a logical value'))	
        }
    }
    
    setChunksize <- function(chunksize) {
        chunksize <- max(1, round(chunksize[1]))
        chunksize <- min(chunksize, 10^9)
        options(rasterChunkSize = chunksize )
    }
    
    setFileExt <- function(setfileext) {
        options(rasterSetFileExt = as.logical(setfileext) )
    }
    
    setMaxMemorySize <- function(maxmemory) {
        maxmemory = max(10000, round(maxmemory[1]))
        options(rasterMaxMemory = maxmemory )
    }
    
    setTolerance <- function(x) {
        x <- max(0.000000001, min(x, 0.5))
        options(rasterTolerance = x)
    }
    
    setStandardNames <- function(x) {
        if (is.logical(x)) {
            if (is.na(x)) {
                x <- TRUE
            }
            options(rasterStandardNames = x)
        }
    }
    
    depracatedWarnings <- function(x) {
        if (is.logical(x)) {
            if (is.na(x)) {
                x <- TRUE
            }
            options(rasterDepracatedWarnings = x)
        }
    }
    
    cnt <- 0
    if (reset) 
    {
        cnt <- 1
        options(MODIS_localArcPath = '~/MODIS_ARC')
        options(MODIS_outDirPath = '~/MODIS_ARC/PROCESSED')
        options(MODIS_gdalPath = 'auto')
        options(MODIS_pixelSize = 'asIn')
        options(MODIS_resamplingType = 'near')
        options(MODIS_outProj = 'asIn')

    }
        
    if (!missing(localArcPath)) { setlocalArcPath(localArcPath); cnt <- cnt+1 }
    if (!missing(outDirPath)) { setoutDirPath(outDirPath); cnt <- cnt+1 }
    if (!missing(gdalPath)) { setGdalPath(datatype); cnt <- cnt+1 }
    if (!missing(pixelSize)) { setpixelSize(pixelSize); cnt <- cnt+1 }
    if (!missing(resamplingType)) { setresamplingType(resamplingType); cnt <- cnt+1 }
    if (!missing(outProj)) { setoutProj(outProj); cnt <- cnt+1 }
    
    lst <- list(
        format=.filetype(),
        overwrite=.overwrite(),
        datatype=.datatype(),
        tmpdir=.tmpdir(),
        tmptime=.tmptime(),
        progress=.progress(),
        timer=.timer(),
        chunksize=.chunksize(),
        maxmemory=.maxmemory(),
        todisk=.toDisk(),
        setfileext=.setfileext(),
        tolerance=.tolerance(),
        standardnames=.standardnames(),
        depwarning=.depracatedwarnings()
    )
    
    if (save==global) 
    {
        
        fn <- paste(R.home(component="etc"), '/', 'MODIS_opts.site', sep='')
        if (file.exists(fn)) {
            oplst <- readLines(fn)
            if (length(oplst) == 0) { 
                oplst <- "" 
            }
            oplst <- removeMODISoptions(oplst)
            if (oplst[length(oplst)] != "") { 
                oplst <- c(oplst, "") 
            }
        } else {
            oplst <- ""
        }
        
        cnt <- 1
        oplst <- c(oplst, "# Options for the 'MODIS' package")
        oplst <- c(oplst, paste("options(MODIS_localArcPath='", lst$localArcPath, "')", sep='')) 
        oplst <- c(oplst, paste("options(MODIS_outDirPath=", lst$outDirPath, ')', sep=''))
        oplst <- c(oplst, paste("options(MODIS_gdalPath='", lst$gdalPath, "')", sep=''))
        oplst <- c(oplst, paste("options(MODIS_pixelSize='", lst$pixelSize, "')", sep=''))
        oplst <- c(oplst, paste("options(MODIS_outProj='", lst$outProj, "')", sep=''))
        oplst <- c(oplst, paste("options(MODIS_resamplingType='", lst$resamplingType, "')", sep=''))
        
        r <- try( write(unlist(oplst), fn), silent = TRUE )
        if (class(r) == "try-error") { 
            warning('Cannot save options. No write access to: ', fn, '\n')	
        }
    } else if (save="user")	
    
    
    if (cnt == 0) {
        cat('localArcPath  :', lst$localArcPath, '\n' )
        cat('outDirPath    :', lst$outDirPath, '\n')
        cat('gdalPath      :', lst$gdalPath, '\n')
        cat('pixelSize     :', lst$pixelSize, '\n')
        cat('outProj       :', lst$outProj, '\n')
        cat('resamplingType:', lst$resamplingType, '\n')
    }
    
    invisible(lst)
}

removeMODISoptions <- function(x) 
{
    y <- list()
    for (i in seq(along=x)) {
        if (!trim(x[[i]]) == "# Options for the 'MODIS' package" & !substr(trim(x[[i]]),1,14) == 'options(MODIS_') {
            y <- c(y, x[[i]])
        }
    }
    return(y)
}
