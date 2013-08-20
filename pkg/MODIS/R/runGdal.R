
runGdal <- function(product, collection=NULL, begin=NULL,end=NULL, extent=NULL, tileH=NULL, tileV=NULL, buffer=0, SDSstring=NULL, job=NULL, checkIntegrity=TRUE, wait=0.5, quiet=FALSE,...)
{
    opts    <- MODIS:::combineOptions(...)
    funOpts <- list(...)
    
    if(!opts$gdalOk)
    {
        stop("GDAL not installed or configured, read in '?MODISoptions' for help")
    }
    # absolutly needed
    product <- getProduct(product,quiet=TRUE)
    
    # optional and if missing it is added here:
    product$CCC <- getCollection(product,collection=collection)
    tLimits     <- transDate(begin=begin,end=end)
    
    dataFormat <- toupper(opts$dataFormat) 
    if (dataFormat == 'RAW BINARY')
    {
        stop('in argument dataFormat=\'raw binary\', format not supported by GDAL (it is MRT specific) type: \'options("MODIS_gdalOutDriver")\' (column \'name\') to list available inputs')
    }
  
    if(dataFormat == 'HDF-EOS')
    {
        dataFormat <- "HDF4IMAGE"
    } else if(dataFormat == 'GEOTIFF')
    {
        dataFormat <- "GTIFF"
    }
    
    if(is.null(opts$gdalOutDriver))
    {
        opts$gdalOutDriver <- gdalWriteDriver()
        options("MODIS_gdalOutDriver"=opts$gdalOutDriver) # save for current session
    }
    
    if(dataFormat %in% toupper(opts$gdalOutDriver$name))
    {
        dataFormat <- grep(opts$gdalOutDriver$name, pattern=paste("^",dataFormat,"$",sep=""),ignore.case = TRUE,value=TRUE)
        of <- paste0(" -of ",dataFormat)
        extension  <- MODIS:::getExtension(dataFormat)
    } else 
    {
        stop('in argument dataFormat=\'',opts$dataFormat,'\', format not supported by GDAL type: \'MODIS:::gdalWriteDriver()\' (column \'name\') to list available inputs')
    }
    
    #### settings with messages
    # output pixel size in output proj units (default is "asIn", but there are 2 chances of changing this argument: pixelSize, and if extent comes from a Raster* object.
    
    if (product$TYPE[1]=="Tile")
    {
        extent <- getTile(extent=extent, tileH=tileH, tileV=tileV, buffer=buffer)
    } else
    {
        extent <- NULL
    }

    #### outProj
    t_srs <- NULL
    cat("########################\n")
    if(!is.null(extent$target$outProj))
    {
      outProj <- MODIS:::checkOutProj(extent$target$outProj,tool="GDAL")
      cat("outProj          = ",outProj ," (Specified by raster*/spatial* object)\n")
    } else
    {
      outProj <- MODIS:::checkOutProj(opts$outProj,tool="GDAL")
      cat("outProj          = ",outProj,"\n")
    }
    if (outProj == "asIn")
    {
        if (product$SENSOR[1]=="MODIS")
        {
            if (product$TYPE[1]=="Tile")
            {
                outProj <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
            } else 
            {
                outProj <- "+proj=longlat +ellps=clrk66 +no_defs" # CMG proj
            }
        } else if (product$SENSOR[1]=="SRTM")
        {
            outProj <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
        } 
    }
    t_srs <- paste0(' -t_srs ',shQuote(outProj))
    
    #### pixelSize
    if(!is.null(extent$target$pixelSize))
    {
      pixelSize <- extent$target$pixelSize
      cat("pixelSize        = ",pixelSize ," (Specified by raster* object)\n")
    } else 
    {
      pixelSize <- opts$pixelSize
      cat("pixelSize        = ",pixelSize,"\n")
    } 

    tr <- NULL
    if (pixelSize[1]!="asIn")
    {
      if (length(pixelSize)==1)
      {
        tr <- paste(" -tr",pixelSize,pixelSize)
      } else
      {
        tr <- paste0(" -tr ", paste0(pixelSize,collapse=" "))
      }
    }
    
    #### resamplingType
    opts$resamplingType <- MODIS:::checkResamplingType(opts$resamplingType, tool="gdal")
    cat("resamplingType   = ", opts$resamplingType,"\n")
    rt <- paste0(" -r ",opts$resamplingType)
    
    #### inProj (s_srs)    
    if (product$SENSOR[1]=="MODIS")
    {
      if (product$TYPE[1]=="Tile")
      {
        s_srs <- paste0(' -s_srs ',shQuote("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"))
      } else 
      {
        s_srs <- paste0(' -s_srs ',shQuote("+proj=longlat +ellps=clrk66 +no_defs"))
      }
    } else if (product$SENSOR[1]=="SRTM")
    {
      s_srs <- paste0(' -s_srs ',shQuote("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
    }
    #### te (target extent)
    te <- NULL # if extent comes from tileV/H
    if (!is.null(extent$target$extent)) # all extents but not tileV/H
    {
      if (is.null(extent$target$outProj)) # map or list extents (always LatLon)
      {
        rx <- raster(extent$target$extent,crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") 
        rx <- projectExtent(rx,outProj)
        rx <- extent(rx) 
      } else
      {
        rx <- extent$target$extent
      }
      te <- paste(" -te", rx@xmin, rx@ymin, rx@xmax, rx@ymax)  
    }
    
    #### generate non-obligatory GDAL arguments
    # GeoTiff BLOCKYSIZE and compression. See: http://www.gdal.org/frmt_gtiff.html            
    if(is.null(opts$blockSize))
    {
      bs <- NULL
    } else
    {
      opts$blockSize <- as.integer(opts$blockSize)
      bs <- paste0(" -co BLOCKYSIZE=",opts$blockSize)
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
    if (quiet)
    {
      q <- " -q"
    } else
    {
      q <- NULL
    }
    
    for (z in 1:length(product$PRODUCT))
    {
      todo <- paste(product$PRODUCT[z],".",product$CCC[[product$PRODUCT[z]]],sep="")    
      
      if(z==1)
      {
        if (is.null(job))
        {
          job <- paste0(todo[1],"_",format(Sys.time(), "%Y%m%d%H%M%S"))    
          cat("Output directory = ",paste0(normalizePath(opts$outDirPath,"/",mustWork=FALSE),job)," (no 'job' name specified, generated (date/time based))\n")
        } else
        {
          cat("Output Directory = ",paste0(normalizePath(opts$outDirPath,"/",mustWork=FALSE),job),"\n")
        }
        cat("########################\n")
        
        outDir <- file.path(opts$outDirPath,job,fsep="/")
        dir.create(outDir,showWarnings=FALSE,recursive=TRUE)
      }
      
      for(u in 1:length(todo))
      {
        MODIS:::getStruc(product=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],begin=tLimits$begin,end=tLimits$end)
        ftpdirs      <- list()
        ftpdirs[[1]] <- read.table(paste0(opts$auxPath,"LPDAAC_ftp.txt"),stringsAsFactors=FALSE)
        
        prodname <- strsplit(todo[u],"\\.")[[1]][1] 
        coll     <- strsplit(todo[u],"\\.")[[1]][2]
        
        avDates <- ftpdirs[[1]][,todo[u]]
        avDates <- avDates[avDates!=FALSE]
        avDates <- avDates[!is.na(avDates)]        
        
        sel     <- as.Date(avDates,format="%Y.%m.%d")
        us      <- sel >= tLimits$begin & sel <= tLimits$end
        
        if (sum(us,na.rm=TRUE)>0)
        {
          avDates <- avDates[us]
                      
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
          
            if (l==1)
            {
              NAS <- MODIS:::getNa(SDS[[1]]$SDS4gdal)
            }
             
             for (i in seq_along(SDS[[1]]$SDSnames))
             {
              outname <- paste(paste(strsplit(basename(files[1]),"\\.")[[1]][1:2],collapse="."),
                 ".", gsub(SDS[[1]]$SDSnames[i],pattern=" ",replacement="_"), extension,sep="")
                
              gdalSDS <- sapply(SDS,function(x){x$SDS4gdal[i]}) # get names of layer 'o' of all files (SDS)
              
              if(sum(names(NAS) %in% SDS[[1]]$SDSnames) > 0)
              {
                srcnodata <- paste0(" -srcnodata ",NAS[[SDS[[1]]$SDSnames[i]]])
                dstnodata <- paste0(" -dstnodata ",NAS[[SDS[[1]]$SDSnames[i]]])
              } else
              {
                srcnodata <- NULL
                dstnodata <- NULL 
              }
                
              if (.Platform$OS=="unix")
              {
                ifile <- paste0(gdalSDS,collapse="' '")
                ofile <- paste0(outDir, '/', outname)
                cmd   <- paste0(opts$gdalPath,
                      "gdalwarp",
                          s_srs,
                          t_srs,
                          of,
                          te,
                          tr,
                          cp,
                          bs,
                          rt,
                          q,
                          srcnodata,
                          dstnodata,
                          " -overwrite",
                          " -multi",
                          " \'", ifile,"\'",
                          " ",
                          ofile
                          )
                cmd <- gsub(x=cmd,pattern="\"",replacement="'")
                system(cmd)
                    
              } else # windows
              {
                  cmd <- paste0(opts$gdalPath,"gdalwarp")
               
                  # ifile <- paste(shortPathName(gdalSDS),collapse='\" \"',sep=' ')
                  # ofile <- shortPathName(paste0(normalizePath(outDir), '\\', outname))
                  ofile <- paste0(outDir, '/', outname)      
                  ifile <- paste0(gdalSDS,collapse='" "')
                  
                  # GDAL < 1.8.0 doesn't support ' -overwrite' 
                  if(file.exists(ofile))
                  {
                    invisible(file.remove(ofile))
                  }
                        
                        shell(
                           paste(cmd,
                            s_srs,
                                    t_srs,
                                    of,
                                    te,
                                    tr,
                                    cp,
                                    bs,
                                    rt,
                                    q,
                                    srcnodata,
                                    dstnodata,
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

