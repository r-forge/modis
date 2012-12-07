
runGdal <- function(...)
{
     
    opts <- combineOptions(...)

    # absolutly needed
    opts$product <- getProduct(opts$product,quiet=TRUE)
    
    # optional and if missing it is added here:
    opts$product$CCC <- getCollection(opts$product,collection=opts$collection)
    tLimits          <- transDate(begin=opts$begin,end=opts$end)

    ################################
    # Some defaults:
    if (is.null(opts$quiet))    {opts$quiet <- FALSE} 

    #### settings with messages

    # output pixel size in output proj units (default is "asIn", but there are 2 chances of changing this argument: pixelSize, and if extent is a Raster object.
    
    opts$extent <- getTile(extent=opts$extent,tileH=opts$tileH,tileV=opts$tileV,buffer=opts$buffer)
    
    tr <- NULL
    
    if (!is.null(opts$extent$target$resolution[[1]]))
    {
        tr <- paste(" -tr", paste(opts$extent$target$resolution, collapse=" "))
        cat("Output pixelSize specified by raster* object:", paste(opts$extent$target$resolution,collapse=" "),"\n")            
    } else 
    {
        cat("pixelSize      = ",opts$pixelSize,"\n")
        tr <- paste(" -tr", opts$pixelSize, opts$pixelSize,collapse=" ")                      
    }
    
    opts$resamplingType <- checkResamplingType(opts$resamplingType, tool="gdal")
    cat("resamplingType = ", opts$resamplingType,"\n")
    rt <- paste(" -r",opts$resamplingType)
    
    # some support for mrt-style settings
    if (opts$outProj == "GEOGRAPHIC")
    {
        opts$outProj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    }
    
    if (opts$outProj == "asIn")
    {
        if (opts$product$SENSOR=="MODIS")
        {
            opts$outProj <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"        
        } else if (opts$product$SENSOR=="SRTM")
        {
            opts$outProj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
        } 
    }

    if (!is.null(opts$extent$target$t_srs))
    {
        opts$outProj <- opts$extent$target$t_srs
        cat("Output projection specified by raster* object: ")
    } else 
    {
        cat("outProj       = ")
    }
    opts$outProj <- checkOutProj(opts$outProj,tool="gdal")
    cat(opts$outProj,"\n")
        
    t_srs <- paste(' -t_srs \"',opts$outProj,'\"',sep='')
    
    if (opts$product$SENSOR=="MODIS")
    {
        s_srs <- ' -s_srs \"+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs\"'
    } else if (opts$product$SENSOR=="SRTM")
    {
        s_srs <- ' -s_srs \"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs\"'
    }
     
    for (z in 1:length(opts$product$PRODUCT))
    {
        todo <- paste(opts$product$PRODUCT[z],".",opts$product$CCC[[opts$product$PRODUCT[z]]],sep="")    
    
        for(u in 1:length(todo))
        {
            MODIS:::.getStruc(product=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],begin=tLimits$begin,end=tLimits$end)
            ftpdirs <- list()
            ftpdirs[[1]] <- read.table(file.path(opts$auxPath,"LPDAAC_ftp.txt",fsep="/"),stringsAsFactors=FALSE)
            
            prodname <- strsplit(todo[u],"\\.")[[1]][1] 
            coll     <- strsplit(todo[u],"\\.")[[1]][2]
    
            avDates <- ftpdirs[[1]][,todo[u]]
            avDates <- avDates[!is.na(avDates)]            
            sel <- as.Date(avDates,format="%Y.%m.%d")
            us  <- sel >= tLimits$begin & sel <= tLimits$end
    
            if (sum(us,na.rm=TRUE)>0)
            {
                avDates <- avDates[us]
    
                if (is.null(opts$job))
                {
                    opts$job <- paste(todo[u],"_",format(Sys.time(), "%Y%m%d%H%M%S"),sep="")    
                    cat("No 'job' name specified, generated (date/time based)):",paste(opts$outDirPath,opts$job,sep="/"),"\n")
                }
                outDir <- file.path(opts$outDirPath,opts$job,fsep="/")
                dir.create(outDir,showWarnings=FALSE,recursive=TRUE)
    
                for (l in 1:length(avDates))
                { 
                    files <- unlist(
                                getHdf(product=prodname, collection=coll, begin=avDates[l], end=avDates[l],
                                tileH=opts$extent$tileH, tileV=opts$extent$tileV, stubbornness=opts$stubbornness)
                             )
                    files <- files[basename(files)!="NULL"]
                    
        			w <- options()$warn
        			options("warn"= -1)
        			SDS <- list()
        			for (z in seq(along=files))
        			{ # get all SDS names for one chunk
        				SDS[[z]] <- getSds(HdfName=files[z], SDSstring=opts$SDSstring, method="gdal")
        			}
        			options("warn"= w)					
    
                    for (i in seq_along(SDS[[1]]$SDSnames))
                    {
                        outname <- paste(paste(strsplit(basename(files[1]),"\\.")[[1]][1:2],collapse="."),
                        ".", gsub(SDS[[1]]$SDSnames[i],pattern=" ",replacement="_"), ".tif",sep="")
                        
                        gdalSDS <- sapply(SDS,function(x){x$SDS4gdal[i]}) # get names of layer 'o' of all files (SDS)
                        
                        te <- NULL
                        if ( !is.null(opts$extent$extent) )
                        {
                            if ("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" != opts$outProj)
                            {   
                                if (!is.null(opts$extent$target$extent))
                                {
                                    te <- paste(" -te", opts$extent$target$extent@xmin, opts$extent$target$extent@ymin,
                                    opts$extent$target$extent@xmax, opts$extent$target$extent@ymax, collapse=" ") 
                        
                                } else 
                                {
                                    
                                    xy <- matrix(c(opts$extent$extent@xmin, opts$extent$extent@ymin, opts$extent$extent@xmin,
                                        opts$extent$extent@ymax, opts$extent$extent@xmax,
                                        opts$extent$extent@ymax, opts$extent$extent@xmax, opts$extent$extent@ymin),
                                        ncol=2, nrow=4, byrow=TRUE)
                                    colnames(xy) <- c("x","y")
				                    xy <- as.data.frame(xy)
				                    coordinates(xy) <- c("x","y")
				                    proj4string(xy) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
                                    outBB <- spTransform(xy,CRS(opts$outProj))@bbox
				                    te <- paste(" -te",outBB["x","min"],outBB["y","min"],outBB["x","max"],outBB["y","max"],collapse=" ")
                                
                                }
                            
                            } else
                            {
                                te <- paste(" -te", opts$extent$extent@xmin,opts$extent$extent@ymin,opts$extent$extent@xmax,opts$extent$extent@ymax,collapse=" ")  
                            }
                        }
                        
                        #### generate non-obligatory GDAL arguments
                        
                        # GeoTiff BLOCKYSIZE and compression. See: http://www.gdal.org/frmt_gtiff.html                          
                        if(is.null(opts$blockSize))
                        {
                            bs <- NULL
                        } else
                        {
                            opts$blockSize <- as.integer(opts$blockSize)
                            bs <- paste(" -co BLOCKYSIZE=",opts$blockSize,sep="")
                        }
                        
                        # compress output data
                        if(is.null(opts$compression))
                        {
                            cp <- " -co compress=lzw -co predictor=2"
                        } else if (isTRUE(opts$compression))
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

