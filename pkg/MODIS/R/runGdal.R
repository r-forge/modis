
runGdal <- function(...)
{

    if (MODIS:::.checkTools(what="GDAL",quiet=TRUE)$GDAL!=1)
    {
        if (.Platform$OS == "unix")
        {
            stop("GDAL path not set (properly) or GDAL not installed on your system!")
        } else {
            stop("'FWTools'/'OSGeo4W' (GDAL with hdf4 support on Windows) path not set (properly) or not installed on your system! see: 'http://fwtools.maptools.org/' or 'http://trac.osgeo.org/osgeo4w/'")
        }
    }
    
    pm <- list(...)

    if (is.null(pm$localArcPath))
    {
        pm$localArcPath <- MODISpackageOpts$localArcPath
    }
    
    # absolutly needed
    pm$product <- getProduct(pm$product,quiet=TRUE)
    
    # optional and if missing it is added here:
    pm$product$CCC <- getCollection(pm$product,collection=pm$collection)
    tLimits        <- transDate(begin=pm$begin,end=pm$end)

    ################################
    # Some defaults:
    if (is.null(pm$quiet))    {pm$quiet <- FALSE} 
    if (is.null(pm$dlmehtod)) {pm$dlmehtod <- "auto"} 
    if (is.null(pm$stubbornness)) {pm$stubbornness <- "high"} 


    # auxPath
    auxPATH <- file.path(pm$localArcPath,".auxiliaries",fsep="/")
    dir.create(auxPATH,recursive=TRUE,showWarnings=FALSE)
    #################

    if (is.null(pm$outDirPath))
    {
        pm$outDirPath <- MODISpackageOpts$outDirPath
    }
    pm$outDirPath <- normalizePath(path.expand(pm$outDirPath), winslash = "/",mustWork=FALSE)
    pm$outDirPath <- paste(strsplit(pm$outDirPath,"/")[[1]],collapse="/")
    dir.create(pm$outDirPath,showWarnings=FALSE,recursive=TRUE)
    # test local outDirPath
    try(testDir <- list.dirs(pm$outDirPath),silent=TRUE)
    if(!exists("testDir")) 
    {
        stop("'outDirPath' not set properly!")
    } 
    ##############

    #### settings with messages

    # output pixel size in output proj units (default is "asIn", but there are 2 chances of changing this argument: pixelSize, and if extent is a Raster object.
    
    pm$extent <- getTile(extent=pm$extent,tileH=pm$tileH,tileV=pm$tileV,buffer=pm$buffer)
    
    tr <- NULL
    
    # was wrong in doc and code!
    if (!is.null(pm$pixelsize)) 
    {
        pm$pixelSize <- pm$pixelsize
        warning("Please, next time use 'pixelSize' instead of 'pixelsize'")
    }
    
    if (is.null(pm$pixelSize))
    {

        if (!is.null(pm$extent$target$resolution[[1]]))
        {
            tr <- paste(" -tr", paste(pm$extent$target$resolution, collapse=" "))
            cat("Output pixelSize specified by raster* object:", paste(pm$extent$target$resolution,collapse=" "),"\n")            
        } else
        {
            cat("No output 'pixelSize' specified, input size used!\n")
        }
    
    } else 
    {
    
        cat("Output 'pixelSize' specified:",pm$pixelSize,"\n")
        tr <- paste(" -tr", pm$pixelSize, pm$pixelSize,collapse=" ")                      
    
    }

    if (is.null(pm$resamplingType))
    {
        pm$resamplingType <- MODIS:::.getDef("resamplingType")

        if (toupper(pm$resamplingType) == "NN")
        {
            rt <- "near"
        } else
        {
            rt <- tolower(pm$resamplingType)
        }
        
        if (!rt %in% c("near", "bilinear","cubic","cubicspline","lanczos"))  
        {
            stop('"resamplingType" must be one of: "near","bilinear","cubic","cubicspline","lanczos"')
        }
        
        cat("No 'resamplingType' specified, using default: ",rt,"\n",sep="")
    } else 
    {    

        if (toupper(pm$resamplingType) == "NN")
        {
            rt <- "near"
        } else
        {
            rt <- tolower(pm$resamplingType)
        }
        
        if (!rt %in% c("near", "bilinear", "cubic", "cubicspline", "lanczos"))
        {
            stop("'resamplingType' must be one of: 'near','bilinear','cubic','cubicspline','lanczos'")
        }
        cat("Resampling method: ", rt,"\n")
    }
    rt <- paste(" -r",rt)
    
    if (is.null(pm$outProj))
    {

        if (!is.null(pm$extent$target$t_srs))
        {
            pm$outProj <- pm$extent$target$t_srs
            cat("Output projection specified by raster* object: '", pm$outProj,"'\n",sep="")
        } else 
        {
            pm$outProj <- MODIS:::.getDef("outProj")
            cat("No 'outProj' specified, using ", pm$outProj,"\n",sep="")
        }

    }
    # some support of mrt setting
    if (pm$outProj=="GEOGRAPHIC")
    {
        pm$outProj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    }
    
    if (pm$outProj=="asIn")
    {
        if (pm$product$SENSOR=="MODIS")
        {
            pm$outProj <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"        
        } else if (pm$product$SENSOR=="SRTM")
        {
            pm$outProj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
        } 
    }
        
    if (length(grep(pm$outProj,pattern="^EPSG:",ignore.case=TRUE))==1 | is.numeric(pm$outProj))
    {
        require(rgdal)
        epsg <- make_EPSG()
        
        outProj <- strsplit(as.character(pm$outProj),":")[[1]]
        outProj <- as.numeric(outProj[length(outProj)])
        
        outProj <- epsg[grep(pattern=outProj, epsg$code),3]
        
        if (length(outProj)==0)
        {
            stop("Unknown EPSG code. Please check!")
        } 
           
        pm$outProj <- outProj
    }
    t_srs <- paste(' -t_srs \"',pm$outProj,'\"',sep='')
    
    if (pm$product$SENSOR=="MODIS")
    {
        s_srs <- ' -s_srs \"+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs\"'
    } else if (pm$product$SENSOR=="SRTM")
    {
        s_srs <- ' -s_srs \"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs\"'
    }
     
    for (z in 1:length(pm$product$PRODUCT))
    {
        
#        if (pm$product$TYPE[z]=="CMG") 
#        {
#            tileID <- "GLOBAL"
#            ntiles <- 1 
#        } else {
#            pm$extent <- getTile(extent=pm$extent,tileH=pm$tileH,tileV=pm$tileV,buffer=pm$buffer)
#            ntiles    <- length(pm$extent$tile)
#        }
    
        todo <- paste(pm$product$PRODUCT[z],".",pm$product$CCC[[pm$product$PRODUCT[z]]],sep="")    
    
        for(u in 1:length(todo))
        {
            MODIS:::.getStruc(product=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],begin=tLimits$begin,end=tLimits$end)
            ftpdirs <- list()
            ftpdirs[[1]] <- read.table(file.path(auxPATH,"LPDAAC_ftp.txt",fsep="/"),stringsAsFactors=FALSE)
            
            prodname <- strsplit(todo[u],"\\.")[[1]][1] 
            coll     <- strsplit(todo[u],"\\.")[[1]][2]
    
            avDates <- ftpdirs[[1]][,todo[u]]
            avDates <- avDates[!is.na(avDates)]            
            sel <- as.Date(avDates,format="%Y.%m.%d")
            us  <- sel >= tLimits$begin & sel <= tLimits$end
    
            if (sum(us,na.rm=TRUE)>0)
            {
                avDates <- avDates[us]
    
                if (is.null(pm$job))
                {
                    pm$job <- paste(todo[u],"_",format(Sys.time(), "%Y%m%d%H%M%S"),sep="")    
                    cat("No 'job' name specified, generated (date/time based)):",paste(pm$outDirPath,pm$job,sep="/"),"\n")
                }
                outDir <- file.path(pm$outDirPath,pm$job,fsep="/")
                dir.create(outDir,showWarnings=FALSE,recursive=TRUE)
    
                for (l in 1:length(avDates))
                { 
                    files <- unlist(
                                getHdf(product=prodname, collection=coll, begin=avDates[l], end=avDates[l],
                                tileH=pm$extent$tileH, tileV=pm$extent$tileV, stubbornness=pm$stubbornness)
                             )
                    files <- files[basename(files)!="NULL"]
                    
        			w <- options()$warn
        			options("warn"= -1)
        			SDS <- list()
        			for (z in seq(along=files))
        			{ # get all SDS names for one chunk
        				SDS[[z]] <- getSds(HdfName=files[z], SDSstring=pm$SDSstring, method="gdal")
        			}
        			options("warn"= w)					
    
                    for (i in seq_along(SDS[[1]]$SDSnames))
                    {
                        outname <- paste(paste(strsplit(basename(files[1]),"\\.")[[1]][1:2],collapse="."),
                        ".", gsub(SDS[[1]]$SDSnames[i],pattern=" ",replacement="_"), ".tif",sep="")
                        
                        gdalSDS <- sapply(SDS,function(x){x$SDS4gdal[i]}) # get names of layer 'o' of all files (SDS)
                        
                        te <- NULL
                        if ( !is.null(pm$extent$extent) )
                        {
                            if ("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" != pm$outProj)
                            {   
                                if (!is.null(pm$extent$target$extent))
                                {
                                    te <- paste(" -te", pm$extent$target$extent@xmin, pm$extent$target$extent@ymin,
                                    pm$extent$target$extent@xmax, pm$extent$target$extent@ymax, collapse=" ") 
                        
                                } else 
                                {
                                    
                                    xy <- matrix(c(pm$extent$extent@xmin, pm$extent$extent@ymin, pm$extent$extent@xmin,
                                        pm$extent$extent@ymax, pm$extent$extent@xmax,
                                        pm$extent$extent@ymax, pm$extent$extent@xmax, pm$extent$extent@ymin),
                                        ncol=2, nrow=4, byrow=TRUE)
                                    colnames(xy) <- c("x","y")
				                    xy <- as.data.frame(xy)
				                    coordinates(xy) <- c("x","y")
				                    proj4string(xy) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
                                    outBB <- spTransform(xy,CRS(pm$outProj))@bbox
				                    te <- paste(" -te",outBB["x","min"],outBB["y","min"],outBB["x","max"],outBB["y","max"],collapse=" ")
                                
                                }
                            
                            } else
                            {
                                te <- paste(" -te", pm$extent$extent@xmin,pm$extent$extent@ymin,pm$extent$extent@xmax,pm$extent$extent@ymax,collapse=" ")  
                            }
                        }
                        
                        #### generate non-obligatory GDAL arguments
                        
                        # GeoTiff BLOCKYSIZE and compression. See: http://www.gdal.org/frmt_gtiff.html                          
                        if(is.null(pm$blockSize))
                        {
                            bs <- NULL
                        } else
                        {
                            pm$blockSize <- as.integer(pm$blockSize)
                            bs <- paste(" -co BLOCKYSIZE=",pm$blockSize,sep="")
                        }
                        
                        # compress output data
                        if(is.null(pm$compression))
                        {
                            cp <- " -co compress=lzw -co predictor=2"
                        } else if (isTRUE(pm$compression))
                        {
                            cp <- " -co compress=lzw -co predictor=2"
                        } else
                        {
                            cp <- NULL
                        }
                        ####

                        if (.Platform$OS=="unix")
                        {

                            ifile <- paste(gdalSDS,collapse="' '")
                            ofile <- paste(outDir, '/', outname,sep='')
                            cmd <- paste(
                                    "gdalwarp",
                                    s_srs,
                                    t_srs,
                                    te,
                                    tr,
                                    cp,
                                    bs,
                                    rt,
                                    " -overwrite",
                                    " -multi",
                                    " \'", ifile,"\'",
                                    " ",
                                    ofile,
                                    sep="")
                            cmd <- gsub(x=cmd,pattern="\"",replacement="'")
#                           invisible(
                                system(cmd)
#                           )
                            
                        } else 
                        {
                            gdalPath <- MODIS:::.getDef()$GDALpath
                            if(!is.null(gdalPath))
                            {
                                cmd <- file.path(shortPathName(gdalPath),"gdalwarp",fsep="\\")
                            } else 
                            {
                                cmd <- "gdalwarp"
                            }

                            ifile <- paste(shortPathName(gdalSDS),collapse='\" \"',sep=' ')
                            ofile <- shortPathName(paste(normalizePath(outDir), '\\', outname,sep=''))
                            # GDAL < 1.8.0 doesn't support ' -overwrite' 
                            invisible(file.remove(ofile))
                            # 
                            
                            shell(
                               paste(cmd,
                                    s_srs,
                                    t_srs,
                                    te,
                                    tr,
                                    cp,
                                    bs,
                                    rt,
                                    ' -multi',
                                    ' \"', ifile,'\"',
                                    ' \"', ofile,'\"',
                                sep = '')
                            ) 
                        }
                    }
                }
            }
        }
    }
}

