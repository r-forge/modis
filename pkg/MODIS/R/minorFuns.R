
tiletable <- read.table(system.file("external", "tiletable.txt", package="MODIS"), header=TRUE)

# save(MODIS_Products,file="~/MODIS_Products.RData") # in chase of changes
load(system.file("external", "MODIS_Products.RData", package="MODIS"))

# lazy load gdal EPSG
EPSGinfo <- rgdal:::make_EPSG()

# central setting for stubbornness 
.stubborn <- function(level="high")
{
    if (is.numeric(level)) 
    {
        sturheit <- level    
    } else 
    {
        sturheit <- c(5,50,100,1000,10000)[which(level==c("low","medium","high","veryhigh","extreme"))]
    }
}

file.size <- function(file,units="B")
{
    units <- toupper(units)
    unit <- c(1,1024,1048576,1073741824,1073741824*1024) 
    names(unit) <- c("B","KB", "MB", "GB","TB")
        
    if (!units %in% names(unit))
    {
        stop('unit must be one of: "B", "KB", "MB", "GB" or "TB"')
    } 
    
    file <- file.info(file)
    file <- file[!file$isdir,"size"]
    
    res <- file/unit[toupper(units)]
    return(res)
}

.checksizefun <- function(file,sizeInfo=NULL,flexB=0)
{
    # determine reference size
    if (is.null(sizeInfo))
    {

        if (!require(XML)) 
        {
            stop("You need to install the 'XML' package: install.packages('XML')")
        }
        xmlfile  <- paste(file,".xml",sep="")
        xmlfile  <- xmlParse(xmlfile)
        MetaSize <- getNodeSet(xmlfile, "/GranuleMetaDataFile/GranuleURMetaData/DataFiles/DataFileContainer/FileSize" )
        MetaSize <- as.numeric(xmlValue(MetaSize[[1]])) # expected filesize

    } else 
    {
        MetaSize <- as.numeric(sizeInfo[which(sizeInfo[,1]==basename(file)),2])
    }
    
    if(length(MetaSize)==0)
    {
        res  <- list(MetaSize=NULL,FileSize=NULL,isOK=NULL)    
        return(res)    
    }
    
    FileSize <- as.numeric(file.size(file))
    if (flexB!=0)
    {
        isOK <- (MetaSize >= FileSize-flexB & MetaSize <= FileSize+flexB)     
    } else 
    {
        isOK <- (MetaSize == FileSize)
    }
    res  <- list(MetaSize=MetaSize,FileSize=FileSize,isOK=as.logical(isOK))    
return(res)    
}


search4map <- function(pattern="",database='worldHires',plot=FALSE)
{
    if (!require(mapdata))
    {
        stop("This function requires 'mapdata', please install it first: install.packages('mapdata')")
    }

    areas <- grep(x=map(database,plot=FALSE)$names,pattern=pattern,value=TRUE,ignore.case=TRUE)

    if (length(areas)==0)
    {
        cat("No country (region or island) found! please change your pattern!\n")
        return(invisible(NULL))
    } else 
    {

    if (plot)
    {
        map(database,areas)
        map.axes() 
        box()
        grid(36,18,col="blue",lwd=0.5)
    
        if(length(areas)>4) 
        {
            subareas <- paste(areas[1:3],collapse=", ") 
            title(c(paste(subareas,"and",(length(areas)-3),"other")))
        } else 
        {
            title(areas)
        }
    }
    return(areas=areas)
    }
}


.checkTools <- function(what=c("MRT","GDAL"), quiet=FALSE)
{
    what<-toupper(what)
    iw <- options()$warn 
    options(warn=-1)
    
    MRT  <- NULL
    GDAL <- NULL
        
    if ("MRT" %in% what)
    {
        MRT <- 0
        mrtH  <- normalizePath(Sys.getenv("MRT_HOME"), winslash="/", mustWork = FALSE)
        mrtDD <- normalizePath(Sys.getenv("MRT_DATA_DIR"), winslash="/", mustWork = FALSE)
        
        if (!quiet)
        {
            cat("Checking availabillity of MRT:\n")
        }
    
        if(mrtH=="") 
        {
            cat("  'MRT_HOME' not set/found! MRT is NOT enabled! See: 'https://lpdaac.usgs.gov/tools/modis_reprojection_tool'\n")
        } else 
        {
            if (!quiet)
            {
                cat("  'MRT_HOME' found:", mrtH,"\n")
            }
            if (mrtDD=="") 
            {
               cat("  'MRT_DATA_DIR' not set/found! MRT is NOT enabled! You need to set the path, read in the MRT manual! 'https://lpdaac.usgs.gov/tools/modis_reprojection_tool'\n")
            } else 
            {
                if (!quiet)
                {
                    cat("  'MRT_DATA_DIR' found:",mrtDD,"\n")
                    cat("   MRT enabled, settings are fine!\n")
                }
                MRT <- 1 
            }
        }
    }

    if ("GDAL" %in% what)
    {
        GDAL <- 0
 
        if (.Platform$OS=="unix")
        {    
            if (!quiet)
            {
                cat("Checking availabillity of GDAL:\n")
            }
            gdal <- try(system("gdalinfo --version",intern=TRUE),silent=TRUE)
            if (inherits(gdal,"try-error"))
            {
                cat("   GDAL not found, install it or check path settings in order to use related functionalities!\n")
            } else 
            {
                if (!quiet)
                {
                    cat("   OK,",gdal,"found!\n")
                }
                GDAL <- 1
            }    
        
        } else 
        {
            if (!quiet)
            {
                cat("Checking availabillity of 'FWTools/OSGeo4W' (GDAL with HDF4 support for Windows):\n")    
            }
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
                cat("'FWTools/OSGeo4W' installation not found or path not set.\nIf you don't have installed one of them you can get it from 'http://fwtools.maptools.org/' or 'http://trac.osgeo.org/osgeo4w/' (recommanded)\n
                    \n")
                   
                #Trying to autodetect path to 'FWTools/OSGeo4W' (this may takes some time):
                a <- dirname(list.files(path="c:/",pattern="^gdalinfo.exe$", full.names=TRUE, recursive=TRUE,include.dirs=TRUE))

                if (length(a)==0)
                {
                    stop("No 'FWTools/OSGeo4W' installation(s) found! In order to use related function please solve this problem first.\n")
                }

                fwt <- a[grep(a,pattern="FWTools")]
                osg <- a[grep(a,pattern="OSGeo4W")]
                
                # which is newer?
                if (!is.null(fwt) & !is.null(osg))
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
                                a <- normalizePath(osg,winslash="/") 
                                break   
                            }
                        }
                        if (ug==max(nchar(osgV),nchar(fwtV)))
                        {
                            a <- normalizePath(osg,winslash="/")                         
                        }
                    }                 
                    if (length(a)==0)
                    {
                        cat("Could not determine the versions, using 'OSGeo4W' installation.\n")
                        a <- osg
                    }
                }
                
                cat("Please copy the following line in the MODIS options file ('", normalizePath("~/.MODIS_Opts.R", winslash="/"), "', section: Windows specific):\n GDALpath <- '", normalizePath(a,winslash="/"), "'\n",sep="")
                
            } else 
            {
                if (!quiet)
                {
                    cat("   OK,",gdal,"found!\n")
                }
                GDAL <- 1
            }
        }
    }
    return(invisible(list(GDAL=GDAL,MRT=MRT)))        
}


.isSupported <- function(x) 
{
    fname   <- basename(x)
    
    warn <- options("warn")
    options(warn=-1)
    on.exit(options(warn=warn$warn))
    
    res <- sapply(fname,function(y) 
    {
        product <- getProduct(y,quiet=TRUE)
    
        if (is.null(product))
        {
            return(FALSE)
        } else 
        {
            secName <- MODIS:::.defineName(product$request)
        
            if (product$SENSOR[1] == "MODIS") 
            {
                if (product$TYPE[1] == "Tile") 
                {
                    Tpat    <- "h[0-3][0-9]v[0-1][0-9]" # to enhance
                    return(all((grep(secName["TILE"],pattern=Tpat)) + (substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
            
                } else if (product$TYPE[1] == "CMG") 
                {
                    return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==5)))
            
                } else if (product$TYPE[1] == "Swath")  # actually no support for Swath data!
                {
#                  return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
#                } else {
                    return(FALSE)
                }
            } else 
            {
                return(FALSE)
            }
        }
    })
return(unlist(res))
}

# TODO enhancement of SENSOR/PRODUCT detection capabilities! 
# the methods below are based on the results of strsplit().

.defineName <- function(x) # "x" is a MODIS,SRTM or culture-MERIS filename
{
    
    if(missing(x)) 
    {
        stop("Error in function 'MODIS:::.defineName', x is missing, must be a MODIS, SRTM or culture-MERIS filename!")
    } else 
    {
    fname   <- basename(x)
    secName <- strsplit(fname,"\\.")[[1]] # for splitting with more signes "[._-]"
    
    if (toupper(substring(secName[1],1,4))=="CULT") 
    {
        sensor="MERIS"
    } else if (tolower(substring(secName[1],1,4))=="srtm")
    {
        sensor = "C-Band-RADAR"
        secName <- strsplit(secName[1],"_")[[1]]
    } else 
    {
        sensor="MODIS"
    }
    ###################################
    # NAME definitions (is File-specific!)
    #########################
    # MODIS
    if (sensor=="MODIS")
    {
        product <- getProduct(x=secName[1],quiet=TRUE)
        if (product$TYPE=="Tile") 
        {
            names(secName) <- c("PRODUCT","DATE","TILE","CCC","PROCESSINGDATE","FORMAT")
        } else if (product$TYPE=="CMG") 
        {
            names(secName) <- c("PRODUCT","DATE","CCC","PROCESSINGDATE","FORMAT")
        } else if (product$TYPE=="Swath") 
        { 
            names(secName) <- c("PRODUCT","DATE","TIME","CCC","PROCESSINGDATE","FORMAT")
        } else 
        {
            stop("Not a MODIS 'Tile', 'CMG' or 'Swath'!")
        }
    # MERIS
    } else if (sensor=="MERIS") 
    {
        product  <- getProduct(x="culture-MERIS",quiet=TRUE)
        secName  <- strsplit(fname,MODIS_Products[MODIS_Products$PRODUCT==product$PRODUCT,]$INTERNALSEPARATOR)[[1]]
        lastpart <- strsplit(secName[length(secName)],"\\.")[[1]]
        secName  <- secName[-length(secName)]
        secName  <- c(secName,lastpart)
        if (length(secName)==6) 
        {
            names(secName) <- c("PRODUCT","CCC","DATE1DATE2","TILE","FORMAT","COMPRESSION")
        } else if (length(secName)==5) 
        {
            names(secName) <- c("PRODUCT","CCC","DATE1DATE2","TILE","FORMAT")
        }

    # SRTM
    } else if (sensor=="C-Band-RADAR") 
    {
        product  <- getProduct(x=secName[1],quiet=TRUE)
        secName  <- strsplit(fname,MODIS_Products[MODIS_Products$PRODUCT==product$PRODUCT,]$INTERNALSEPARATOR)[[1]]
        lastpart <- strsplit(secName[length(secName)],"\\.")[[1]]
        secName  <- secName[-length(secName)]
        secName  <- c(secName,lastpart)
        names(secName) <- c("PRODUCT","tileH","tileV","COMPRESSION") 

    } # XXX else if .... add Products here
}
##
return(secName)
}

#### install dependencies and suggested

checkDeps <- function()
{
    needed <- c('RCurl', 'rgeos', 'XMLSchema', 'rgdal', 'maps', 'mapdata','maptools', 'snow', 'ptw', 'SSOAP', 'XML','plotrix')
    if (all(needed %in% installed.packages()[,1]))
    {
        cat("Ok all suggested packages are installed!\n")
    } else {
        missingP <- !needed %in% installed.packages()[,1]
        missingP <- paste(needed[missingP],sep="",collapse="', '")

        cat("\nTo install all suggested and required packages run:\n  setRepositories() # activate CRAN, R-forge, and Omegahat\n  install.packages(c('",missingP,"'))\n",sep="")
    }
}

# this function selects elements of a list by "row".
listPather <- function(x,index)
{
    x   <- as.list(x)
    res <- list()
    
    for (i in seq_along(x))
    {
        res[[i]] <- x[[i]][index]
    }
    names(res) <- names(x)
    return(res)
}

# list files in a Url
filesUrl <- function(url)
{
    require(RCurl)
    if (substr(url,nchar(url),nchar(url))!="/")
    {
       url <- paste(url,"/",sep="") 
    }
    getlist <- getURL(url) 
    getlist <- strsplit(getlist, if(.Platform$OS.type=="unix"){"\n"} else{"\r\n"})[[1]]
    
    getlist <- strsplit(getlist," ")
    elim    <- grep(getlist,pattern="total")
    if(length(elim)==1)
    {
        getlist <- getlist[-elim]
    }
    fnames  <- sapply(getlist,function(x){x[length(x)]})
    size    <- sapply(getlist,
                    function(x)
                    { # filesize is one befor month info
                        x[
                        which(x %in% c("Jan", "Feb", "Mar", "Apr", "May",
                        "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")==TRUE)-1
                        ]
                    })
    return(data.frame(fileNames=basename(fnames),fileSize=size))
}

#http://ryouready.wordpress.com/2008/12/18/generate-random-string-name/
makeRandomString <- function(n=1, lengh=12)
{
    randomString <- c(1:n) # initialize vector
    for (i in 1:n)
    {
        randomString[i] <- paste(sample(c(0:9, letters, LETTERS),
        lengh, replace=TRUE),collapse="")
    }   
    return(randomString)
}


