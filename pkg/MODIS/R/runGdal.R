
runGdal <- function(product, collection=NULL, begin=NULL,end=NULL, extent=NULL, tileH=NULL, tileV=NULL, buffer=0, SDSstring=NULL, job=NULL, checkIntegrity=TRUE, wait=0.5, quiet=FALSE,...)
{
     
    opts <- combineOptions(...)

    # absolutly needed
    product <- getProduct(product,quiet=TRUE)
    
    # optional and if missing it is added here:
    product$CCC <- getCollection(product,collection=collection)
    tLimits     <- transDate(begin=begin,end=end)

    #### settings with messages

    # output pixel size in output proj units (default is "asIn", but there are 2 chances of changing this argument: pixelSize, and if extent is a Raster object.
    
    extent <- getTile(extent=extent,tileH=tileH,tileV=tileV,buffer=buffer)
    
    tr <- NULL
    
    if (!is.null(extent$target$resolution[[1]]))
    {
        tr <- paste(" -tr", paste(extent$target$resolution, collapse=" "))
        cat("\nOutput pixelSize specified by raster* object:", paste(extent$target$resolution,collapse=" "),"\n")            
    } else 
    {
        cat("\npixelSize        = ",opts$pixelSize,"\n")
        
        if(opts$pixelSize=="asIn")
        {
            tr <- NULL
        } else
        {
            tr <- paste(" -tr", opts$pixelSize, opts$pixelSize,collapse=" ")                      
        }
    }
    
    opts$resamplingType <- MODIS:::checkResamplingType(opts$resamplingType, tool="gdal")
    cat("resamplingType   = ", opts$resamplingType,"\n")
    rt <- paste(" -r",opts$resamplingType)
    
    # some support for mrt-style settings
    if (toupper(opts$outProj) == "GEOGRAPHIC")
    {
        opts$outProj <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
    }
    
    if (opts$outProj == "asIn")
    {
        if (product$SENSOR=="MODIS")
        {
            opts$outProj <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"        
        } else if (product$SENSOR=="SRTM")
        {
            opts$outProj <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
        } 
    }

    if (!is.null(extent$target$t_srs))
    {
        opts$outProj <- extent$target$t_srs
        cat("Output projection specified by raster* object: ")
    } else 
    {
        cat("outProj          = ")
    }
    opts$outProj <- MODIS:::checkOutProj(opts$outProj,tool="gdal")
    cat(opts$outProj,"\n")
        
    t_srs <- paste(' -t_srs \"',opts$outProj,'\"',sep='')
    
    if (product$SENSOR=="MODIS")
    {
        s_srs <- ' -s_srs \"+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs\"'
    } else if (product$SENSOR=="SRTM")
    {
        s_srs <- ' -s_srs \"+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0\"'
    }
     
    for (z in 1:length(product$PRODUCT))
    {
        todo <- paste(product$PRODUCT[z],".",product$CCC[[product$PRODUCT[z]]],sep="")    
    
        for(u in 1:length(todo))
        {
            MODIS:::getStruc(product=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],begin=tLimits$begin,end=tLimits$end)
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
    
                if (is.null(job))
                {
                    job <- paste(todo[u],"_",format(Sys.time(), "%Y%m%d%H%M%S"),sep="")    
                    cat("No 'job' name specified, generated (date/time based)) output directory = ")
                } else
                {
                    cat("Output Directory = ")
                }
                cat(paste(opts$outDirPath,job,sep="/"),"\n\n")
                
                outDir <- file.path(opts$outDirPath,job,fsep="/")
                dir.create(outDir,showWarnings=FALSE,recursive=TRUE)
    
                for (l in 1:length(avDates))
                { 
                    files <- unlist(
                                getHdf(product=prodname, collection=coll, begin=avDates[l], end=avDates[l],
                                tileH=extent$tileH, tileV=extent$tileV, checkIntegrity=checkIntegrity, stubbornness=opts$stubbornness)
                             )
                    files <- files[basename(files)!="NA"]
                    
        			w <- options()$warn
        			options("warn"= -1)
        			SDS <- list()
        			for (z in seq_along(files))
        			{ # get all SDS names for one chunk
        				SDS[[z]] <- getSds(HdfName=files[z], SDSstring=SDSstring, method="GDAL")
        			}
        			options("warn"= w)					
    
                    for (i in seq_along(SDS[[1]]$SDSnames))
                    {
                        outname <- paste(paste(strsplit(basename(files[1]),"\\.")[[1]][1:2],collapse="."),
                        ".", gsub(SDS[[1]]$SDSnames[i],pattern=" ",replacement="_"), ".tif",sep="")
                        
                        gdalSDS <- sapply(SDS,function(x){x$SDS4gdal[i]}) # get names of layer 'o' of all files (SDS)
                        
                        te <- NULL
                        if ( !is.null(extent$extent) )
                        {
                            if ("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0" != opts$outProj)
                            {   
                                if (!is.null(extent$target$extent))
                                {
                                    te <- paste(" -te", extent$target$extent@xmin, extent$target$extent@ymin,
                                    extent$target$extent@xmax, extent$target$extent@ymax, collapse=" ") 
                        
                                } else 
                                {
                                    xy <- matrix(c(extent$extent@xmin, extent$extent@ymin, extent$extent@xmin,
                                        extent$extent@ymax, extent$extent@xmax,
                                        extent$extent@ymax, extent$extent@xmax, extent$extent@ymin),
                                        ncol=2, nrow=4, byrow=TRUE)
                                    colnames(xy) <- c("x","y")
				                            xy <- as.data.frame(xy)
				                            coordinates(xy) <- c("x","y")
				                            proj4string(xy) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
                                    outBB <- spTransform(xy,CRS(opts$outProj))@bbox
				                            te <- paste(" -te",outBB["x","min"],outBB["y","min"],outBB["x","max"],outBB["y","max"],collapse=" ")
                                }
                            
                            } else
                            {
                                te <- paste(" -te", extent$extent@xmin, extent$extent@ymin, extent$extent@xmax, extent$extent@ymax,collapse=" ")  
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
                            
                        } else # windows
                        {
                            if(!is.null(opts$gdalPath))
                            {
                                cmd <- file.path(shortPathName(opts$gdalPath),"gdalwarp",fsep="\\")
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

