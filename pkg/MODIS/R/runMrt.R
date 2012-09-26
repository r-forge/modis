# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

runMrt <- function(ParaSource=NULL,...)
{

    if (.checkTools(what="MRT",quiet=TRUE)$MRT!=1)
    {
        stop("MRT path not set or MRT not installed on your system!")
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
    if (is.null(pm$stubbornness)) {pm$stubbornness <- "extreme"} 
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
    } else 
    {
        cat("Resampling to pixelsize:", pm$pixelsize,"\n")
    }

    if (is.null(pm$resample)) 
    {
        cat("No resampling method specified, using ",.getDef('resamplingType'),"!\n",sep="")
        pm$resample <- .getDef("resamplingType")
    } else 
    {    
        cat("Resampling method:", pm$resample,"\n")
    }

    if (is.null(pm$outProj)) 
    {
        cat("No output projection specified, using ", .getDef("outProj"),"!\n",sep="")
        pm$outProj <- .getDef("outProj")
    } else 
    {
        cat("Output projection:", pm$outProj,"\n")
        if (pm$outProj=="UTM"){
            if (!is.null(pm$zone)) 
            {
                cat("No UTM zone specified used MRT autodetection.\n")            
            } else 
            {
                cat("Using UTM zone:", pm$zone,"\n")
            }
        }
    }

    if (is.null(pm$datum)) 
    {
        cat("No Datum specified, using WGS84!\n")
        pm$datum <- "WGS84"
    }
    if (is.null(pm$projPara)) 
    {
        cat("No output projection parameters specified. Reprojecting with no Parameters!\n")
        # pm$projPara <- "0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0"
    } else 
    {
        cat("Output projection parameters specified!\nUsing:",pm$projPara,"\n")
    }

    for (z in 1:length(pm$product$PRODUCT))
    {
            
        if (pm$product$TYPE[z]=="CMG") 
        {
            tileID="GLOBAL"
            ntiles=1 
        } else 
        {
            pm$extent <- getTile(extent=pm$extent,tileH=pm$tileH,tileV=pm$tileV,buffer=pm$buffer)
            ntiles    <- length(pm$extent$tile)
        }
    
        todo <- paste(pm$product$PRODUCT[z],".",pm$product$CCC[[pm$product$PRODUCT[z]]],sep="")    
    
        for(u in 1:length(todo))
        {
            if (is.null(pm$job))
            {
                pm$job <- paste(todo[u],"_",format(Sys.time(), "%Y%m%d%H%M%S"),sep="")    
                cat("No 'job' name specified, generated (date/time based)):",pm$job,"\n")
            }
            outDir <- file.path(pm$outDirPath,pm$job,fsep="/")
            dir.create(outDir)

            ######################## along platform (TerraAqua)

            MODIS:::.getStruc(product=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],begin=pm$begin,end=pm$end)
            ftpdirs <- list()
            ftpdirs[[1]] <- read.table(file.path(auxPATH,"LPDAAC_ftp.txt",fsep="/"),stringsAsFactors=FALSE)
    
            avDates <- ftpdirs[[1]][,todo[u]]
            avDates <- avDates[!is.na(avDates)]            
            sel <- as.Date(avDates,format="%Y.%m.%d")
            us  <- sel >= tLimits$begin & sel <= tLimits$end
    
            if (sum(us,na.rm=TRUE)>0)
            {
                avDates <- avDates[us]

            ######################### along begin -> end date
                for (l in 1:length(avDates))
                { 
                    files <- unlist(getHdf(product=pm$product$PRODUCT[z],collection=strsplit(todo[u],"\\.")[[1]][2],begin=avDates[l],end=avDates[l],tileH=pm$extent$tileH,tileV=pm$extent$tileV,stubbornness=pm$stubbornness,log=FALSE,localArcPath=pm$localArcPath))

                    if (length(files)!=0){
    
                        mos <- pm$mosaic
        
                        if (mos)
                        {
                            # if not all files available switch "off" mosaicing and process single files. Problematic in areas with tiles outside land!
                            if (sum(file.exists(files)) < length(pm$extent$tile))
                            {
                                mos <- FALSE
                            } else {
                                mos <- TRUE
                            }
            
                        } else { 
                            mos <-  FALSE
                        }
            
                        if (mos)
                        {
                            v <- 1
                        } else {
                            v <- 1:length(files)
                        }
            
                        for (q in v)
                        {
                            w <- options("warn")
                            options(warn=-1)
                            if (is.null(pm$SDSstring))
                            {
                                pm$SDSstring <- rep(1,length(getSds(HdfName=files[q],method="mrt")$SDSnames))
                            }    
                
                            SDSstringIntern <- getSds(HdfName=files[q],SDSstring=pm$SDSstring,method="mrt")
                            options(warn=w$warn)
                            
                            if (!pm$quiet && u == 1 && l == 1)
                            {
                                cat("\n#############################\nExtracing SDS:",SDSstringIntern$SDSnames,"#############################\n",sep="\n")
                            }
                            
                            if (mos)
                            {
                                TmpMosNam <- paste("TmpMosaic",round(runif(1,1,1000000)),".hdf",sep="")
                                ### in subset
                                paraname <- file.path(outDir,"/MRTgMosaic.prm",fsep="/") # create mosaic prm file
                                filename = file(paraname, open="wt")
                                write(paste(files,sep='',collapse=' '), filename)
                                close(filename)
                        
                                # run mosaic
                                if (.Platform$OS=="unix")
                                {
                                    system(paste("mrtmosaic -i ",paraname," -o ",outDir,"/",TmpMosNam," -s '",SDSstringIntern$SDSstring,"'" ,sep=""))
                                } else {
                                    shell(paste("mrtmosaic -i ",paraname," -o ",outDir,"\\\\",TmpMosNam," -s \"",SDSstringIntern$SDSstring,"\"" ,sep=""))
                                }
                                unlink(paraname)
                                Sys.sleep(1) # without wait the skript can break here. "wait" is a try but it seams to work!!!
                            }
            
                            basenam <- strsplit(files[q],"/")[[1]]
                            basenam <- basenam[length(basenam)]
        
                            if (mos)
                            {
                                basenam <- paste(strsplit(basenam,"\\.")[[1]][c(1,2,4)],collapse=".")
                            } else {
                                basenam <- paste(strsplit(basenam,"\\.")[[1]][c(1,2,3,4)],collapse=".")    
                            }
        
                            if (!pm$anonym)
                            {   
                                basenam <- paste(basenam,pm$job,sep=".")
                            }
    
                            #### Write prm File
                             paraname <- paste(outDir,"/MRTgResample.prm",sep="")
                            filename = file(paraname, open="wt")

                            if (mos)
                            {
                                write(paste('INPUT_FILENAME = ',outDir,"/",TmpMosNam,sep=''), filename)
                            } else {
                                write(paste('SPECTRAL_SUBSET = ( ',SDSstringIntern$SDSstring,' )',sep=''), filename)
                                write(paste('INPUT_FILENAME = ',files[q],sep=''), filename)
                            }
    
                            write('SPATIAL_SUBSET_TYPE = INPUT_LAT_LONG',filename)
    
                            if (!is.null(pm$extent$extent))
                            {
                                write(paste('SPATIAL_SUBSET_UL_CORNER = (',pm$extent$extent@ymax,' ',pm$extent$extent@xmin,')',sep=''),filename)
                                write(paste('SPATIAL_SUBSET_LR_CORNER = (',pm$extent$extent@ymin,' ',pm$extent$extent@xmax,')',sep=''),filename)
                            }
                            if (!is.null(pm$pixelSize))
                            {
                                write(paste('OUTPUT_PIXELSIZE = ',pm$pixelSize,sep=''),filename) 
                            }    
                            write(paste('OUTPUT_FILENAME = ',outDir,"/",basenam,'.tif',sep=''),filename) 
                            write(paste('RESAMPLING_TYPE = ',pm$resample,sep=''),filename)
                            write(paste('OUTPUT_PROJECTION_TYPE = ',pm$outProj,sep=''),filename)
    
                            if (pm$outProj=="UTM" && !is.null(pm$zone))
                            {
                                write(paste('UTM_ZONE = ',pm$zone,sep=''),filename)
                            }
        
                            if (!is.null(pm$projPara))
                            {
                                write(paste('OUTPUT_PROJECTION_PARAMETERS = ( ',pm$projPara,' )',sep=''),filename)
                            }
        
                            write(paste('DATUM =', pm$datum,sep=''),filename)
                            close(filename)
    
                            if (.Platform$OS=="unix")
                            {
                                system(paste("resample -p ",paraname,sep=""))
                            } else {
                                shell(paste("resample -p ",paraname,sep=""))
                            }
                            unlink(paraname)
    
                            if (mos)
                            {
                                unlink(paste(outDir,TmpMosNam,sep="/"))
                            }
                        }
                    } else {
                        cat("Missing files on",avDates[l],"jumping to the next date",sep="\n")
                    }
                } # l, avDates
            } else {
                cat("No files found for",todo[u],"within the date range\n")
            }
        } # u   
    }
}

