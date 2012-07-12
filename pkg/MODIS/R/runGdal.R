
runGdal <- function(ParaSource=NULL,...)
{

    if (MODIS:::.checkTools(what="GDAL",quiet=TRUE)$GDAL!=1)
    {
        if (.Platform$OS == "unix")
        {
            stop("GDAL path not set (properly) or GDAL not installed on your system!")
        } else {
            stop("FWTools path not set (properly) or FWTools (GDAL with hdf4 support on Windows) not installed on your system! see: 'http://   fwtools.maptools.org/'")
        }
    }

    # Collect parameters from any possible source
    if (!is.null(ParaSource))
    {
        fe  <- new.env()
        eval(parse(ParaSource),envir=fe)
        sp <- as.list(fe)
        dp <- list(...)
         pm <- c(sp, dp[(!names(dp) %in% names(sp))])
    } else {
      pm <- list(...)
    } 

    if(length(pm)==0)
    {
        ParaEx <- file.path(find.package('MODIS'),'external','ParaExample.R')
        stop(paste("Provide a valid 'ParaSource' file, see or use: '",ParaEx,"'or insert the needed parameters directly.",sep=""))
    }

    pm$product     <- getProduct(pm$product,quiet=TRUE)
    pm$product$CCC <- getCollection(pm$product,collection=pm$collection)
    tLimits        <- transDate(begin=pm$begin,end=pm$end)

    ################################
    # Some defaults:
    if (is.null(pm$quiet))    {pm$quiet <- FALSE} 
    if (is.null(pm$dlmehtod)) {pm$dlmehtod <- "auto"} 
    if (is.null(pm$mosaic))   {pm$mosaic <- TRUE} 
    if (is.null(pm$stubbornness)) {pm$stubbornness <- "high"} 
    if (is.null(pm$anonym))   {pm$anonym <- TRUE} 

    if (is.null(pm$localArcPath))
    {
        pm$localArcPath <- MODIS:::.getDef('localArcPath')
    }

    pm$localArcPath <- paste(strsplit(pm$localArcPath,"/")[[1]],collapse="/")
    dir.create(pm$localArcPath,showWarnings=FALSE)
    # test local localArcPath
    try(testDir <- list.dirs(pm$localArcPath),silent=TRUE)
    if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 
    # auxPath
    auxPATH <- file.path(pm$localArcPath,".auxiliaries",fsep="/")
    dir.create(auxPATH,recursive=TRUE,showWarnings=FALSE)
    #################

    if (is.null(pm$outDirPath))
    {
        pm$outDirPath <- MODIS:::.getDef('outDirPath')
    }
    pm$outDirPath <- normalizePath(path.expand(pm$outDirPath), winslash = "/",mustWork=FALSE)
    pm$outDirPath <- paste(strsplit(pm$outDirPath,"/")[[1]],collapse="/")
    dir.create(pm$outDirPath,showWarnings=FALSE,recursive=TRUE)
    # test local outDirPath
    try(testDir <- list.dirs(pm$outDirPath),silent=TRUE)
    if(!exists("testDir")) {stop("'outDirPath' not set properly!")} 
    ##############

    if (is.null(pm$pixelsize))
    {
        cat("No output 'pixelsize' specified, input size used!\n")
        pm$pixelsize <- "asIn"
    } else {
        cat("Output pixelsize:", pm$pixelsize,"\n")
    }

    if (is.null(pm$resamplingType))
    {
        pm$resamplingType <- MODIS:::.getDef("resamplingType")

        if (toupper(pm$resamplingType) == "NN"){
            pm$resamplingType <- "near"
        }
        
        if (!pm$resamplingType %in% c("near","bilinear","cubic","cubicspline","lanczos")) 
        {
            stop('"resamplingType" must be one of: "near","bilinear","cubic","cubicspline","lanczos"')
        }
        
        cat("No resampling method specified, using ",pm$resamplingType,"!\n",sep="")
    } else {    

        if (toupper(pm$resamplingType) == "NN"){
            pm$resamplingType <- "near"
        }
        
        if (!pm$resamplingType %in% c("near","bilinear","cubic","cubicspline","lanczos")) 
        {
            stop('"resamplingType" must be one of: "near","bilinear","cubic","cubicspline","lanczos"')
        }
        cat("Resampling method:", pm$resamplingType,"\n")
    }

    if (is.null(pm$outProj))
    {
        pm$outProj <- MODIS:::.getDef("outProj")
        cat("No output projection specified, using ", pm$outProj,"!\n",sep="")
    }
    
    if (pm$outProj=="GEOGRAPHIC")
    {
        pm$outProj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    }
    
    if (pm$outProj=="asIn")
    {
        if (pm$product$SENSOR=="MODIS")
        {
            pm$outProj <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
        }
    }
    
    if (pm$outProj=="UTM")
    {
        if (is.null(pm$zone))
        {
            cat("No UTM zone specified, autodetecting.\n")            
        } else {
            cat("Using UTM zone:", pm$zone,"\n")
        }
    }

    for (z in 1:length(pm$product$PRODUCT))
    {
        
        if (pm$product$TYPE[z]=="CMG") {
            tileID="GLOBAL"
            ntiles=1 
        } else {
            if(!is.null(pm$extent)) {
                extentCall <- pm$extent
                pm$extent  <- getTile(extent=pm$extent,buffer=pm$buffer)
            } else {
                pm$extent <- getTile(tileH=pm$tileH,tileV=pm$tileV)
            }
            ntiles <- length(pm$extent$tile)
        }
    
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
                    cat("No 'job' name specified, generated (date/time based)):",pm$job,"\n")
                }
                outDir <- file.path(pm$outDirPath,pm$job,fsep="/")
                dir.create(outDir,showWarnings=FALSE,recursive=TRUE)
    
                outtemp <- paste(outDir, "/.temp/",sep="")
                dir.create(outtemp,recursive=TRUE,showWarnings=FALSE)
    
                for (l in 1:length(avDates))
                { 
                    files <- unlist(getHdf(product=prodname,collection=coll,begin=avDates[l],end=avDates[l],extent=pm$extent,stubbornness=pm$stubbornness,log=FALSE,localArcPath=pm$localArcPath))

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
                        outname <- paste(paste(strsplit(basename(files[1]),"\\.")[[1]][1:2],collapse="."),".",gsub(SDS[[1]]$SDSnames[i],pattern=" ",replacement="_"),".tif",sep="")
                        
                        gdalSDS <- sapply(SDS,function(x){x$SDS4gdal[i]}) # get names of layer 'o' of all files(SDS)
    
                        for(p in seq_along(gdalSDS))
                        {
                            if (length(seq_along(gdalSDS))==1)
                            {
                                random <- sample.int(10000000,length(gdalSDS))
                                mosaic <- paste(outtemp,"mosaic_",random,".tif",sep="")
    
                                invisible(system(paste("gdal_translate -a_nodata none -of GTiff \"",gdalSDS[p],"\" ",mosaic[p],sep=""),intern=TRUE))
                            } else {
                                random <- sample.int(10000000,length(gdalSDS)+1)
                                mosaic <- paste(outtemp,"mosaic_",random,".tif",sep="")
                                
                                for (p in seq_along(gdalSDS))
                                {
                                    invisible(system(paste("gdal_translate -a_nodata none -of GTiff \"",gdalSDS[p],"\" ",mosaic[p+1],sep=""),intern=TRUE))                      
                                }
                                invisible(system(paste("gdal_merge.py -of GTiff -o",paste(mosaic,collapse=" ")),intern=TRUE))
                            }
                            require(raster) 
                            timg  <- raster(mosaic[1])
                            s_srs <- projection(timg)
                            te <- paste(c(pm$extent$extent$xmin,pm$extent$extent$ymin,pm$extent$extent$xmax,pm$extent$extent$ymax),collapse=" ")                            
                            
                            if (pm$pixelsize=="asIn")
                            {
                                invisible(system(paste("gdalwarp -s_srs '",s_srs,"' -t_srs '",pm$outProj,"' -te ",te," -overwrite ",mosaic[1]," ",outDir,"/", outname,sep=""),intern=TRUE))
                            } else {
                                tr <- paste(pm$pixelsize,pm$pixelsize,collapse=" ")                   
                                invisible(system(paste("gdalwarp -s_srs '",s_srs,"' -t_srs '",pm$outProj,"' -te ",te," -tr ",tr," -overwrite ",mosaic[1]," ",outDir,"/", outname,sep=""),intern=TRUE))
                            }
                            unlink(c(mosaic,paste(mosaic,"aux.xml",sep=".")))
                        }
                    }
                }
                unlink(outtemp,recursive=TRUE)
            }
        }
    }
}

