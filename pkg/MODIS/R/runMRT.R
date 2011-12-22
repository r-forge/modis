# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

runMRT <- function(ParaSource=NULL,...){ #, mosaic=TRUE, anonym=TRUE, MRTpath="check", quiet=FALSE, dlmethod="auto", stubbornness="low"

if (!is.null(ParaSource)) {
		fe  <- new.env()
		eval(parse(ParaSource),env=fe)
    sp <- as.list(fe)
    dp <- list(...)
 		pm <- c(sp, dp[(!names(dp) %in% names(sp))])
	} else {
	  pm <- list(...)
	} 
	
	if(length(pm)==0) {
		ParaEx <- file.path(find.package('MODIS'),'external','ParaExample.R')
		stop(paste("Provide a valid 'ParaSource' file, see or use: '",ParaEx,"'or insert the needed parameters directly.",sep=""))
	}
	
	pm$product <- getPRODUCT(pm$product)
	
	if (substr(pm$product$PD,3,nchar(pm$product$PD))=="CMG") {
		tileID="GLOBAL"
		ntiles=1 
	} else {
		if(!is.null(pm$extent)) {
			extentCall <- pm$extent
			pm$extent <- getTILE(extent=pm$extent,buffer=pm$buffer)
 		 } else {
			pm$extent <- getTILE(tileH=pm$tileH,tileV=pm$tileV)
 		 }
		ntiles <- length(pm$extent$tile)
	}
	
	
	if (is.null(pm$collection)){
		pm$collection <- getCOLLECTION(product=pm$product)	
		
	} else if (getCOLLECTION(product=pm$product, collection=pm$collection)==FALSE) {
	
		cat(paste("The collection you have spezified doesn't exist for the given product.\nTry: 'getCOLLECTION(product='",pm$product$productName,"',newest=FALSE,forceCheck=TRUE)'\n",sep=""))
	} else {
	
		pm$collection <- getCOLLECTION(product=pm$product, collection=pm$collection)
	
	}


	if (is.null(pm$job)) {
		r <- paste(sample(c(0:9, letters, LETTERS),6, replace=TRUE),collapse="")
		pm$job <- paste(pm$product$request,"_",pm$collection,"_",r,sep="")	
		cat("No 'job' name spezified, generated:",pm$job,"\n")
	}

	
	if (all(is.null(pm$startdate), is.null(pm$enddate))) {
		period <- transDATE()
		cat("No dates spezified, getting all available data for: ", pm$product$productName, ", collection: ",pm$collection,"\n",sep="")
	} else if (is.null(pm$startdate)) {
		period <- transDATE(end=pm$enddate)
		cat("No 'startdate' dates spezified, getting data for: ", pm$product$productName, ", collection: ",pm$collection," form the beginning\n",sep="")
	} else if (is.null(pm$enddate)) {
		period <- transDATE(begin=pm$startdate)
		cat("No 'endddate' spezified, getting data for: ", pm$product$productName, ", collection: ",pm$collection," to the most actual\n",sep="")
	} else {
		period <- transDATE(begin=pm$startdate,end=pm$enddate)
	}	
	pm$startdate <- period$begin
	pm$enddate   <- period$end
		
		
################################
# Some defaults:
if (is.null(pm$quiet))    {pm$quiet <- FALSE} 
if (is.null(pm$dlmehtod)) {pm$dlmehtod <- "auto"} 
if (is.null(pm$mosaic))   {pm$mosaic <- TRUE} 
if (is.null(pm$stubbornness)) {pm$stubbornness <- "extreme"} 
if (is.null(pm$anonym))   {pm$anonym <- TRUE} 
if (is.null(pm$MRTpath))  {pm$MRTpath <- "check"} 

fsep <- .Platform$file.sep

if (is.null(pm$LocalArcPath)) {
	pm$LocalArcPath <- normalizePath("~", winslash = fsep)
	pm$LocalArcPath <- file.path(pm$LocalArcPath,"MODIS_ARC",fsep=fsep)
		if(!pm$quiet){
		cat(paste("No archive path set, using/creating standard archive in: ",pm$LocalArcPath,"\n",sep=""))
		flush.console()
		}
}

pm$LocalArcPath <- paste(strsplit(pm$LocalArcPath,fsep)[[1]],collapse=fsep) # removes "/" or "\" on last position (if present)
dir.create(pm$LocalArcPath,showWarnings=FALSE)
# test local LocalArcPath
try(testDir <- list.dirs(pm$LocalArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'LocalArcPath' not set properly!")} 
#################

if (is.null(pm$outDir)) {
	pm$outDir <- "~/"
	pm$outDir <- normalizePath(path.expand(pm$outDir), winslash = fsep)
	pm$outDir <- paste(strsplit(pm$outDir,fsep)[[1]],collapse=fsep) # removes "/" or "\" on last position (if present)
	pm$outDir <- file.path(pm$outDir,"MRTresults",pm$job,fsep=fsep)
	}
	
dir.create(pm$outDir,recursive=TRUE,showWarnings=FALSE)
# test local LocalArcPath
try(testDir <- list.dirs(pm$outDir),silent=TRUE)
if(!exists("testDir")) {stop("'outDir' not set properly!")} 
##############

if (is.null(pm$pixelsize)) {
	cat("No output 'pixelsize' specified, input size used!\n")
	pm$pixelsize <- "asIn"
	} else {
	cat("Resampling to pixelsize:", pm$pixelsize,"\n")
	}

if (is.null(pm$resample)) {
	cat("No resampling method specified, using nearest neighbor!\n")
	pm$resample <- "NN"
	} else {
	cat("Resampling method:", pm$resample,"\n")
	}

if (is.null(pm$outProj)) {
	cat("No output projection specified, using WGS84!\n")
	pm$outProj <- "GEOGRAPHIC"
	} else {
	cat("Output projection:", pm$outProj,"\n")
		if (pm$outProj=="UTM"){
			if (!exists("ZONE")) {
			cat("No UTM zone spezified used MRT autodetection.\n")			
			} else {
			cat("Using UTM zone:", pm$zone,"\n")
			}
		}
	}

if (is.null(pm$datum)) {
	cat("No Datum spezified, using WGS84!\n")
	pm$datum <- "WGS84"
}

if (is.null(pm$projPara)) {
	cat("No output projection parameters specified. Reprojecting with no Parameters!\n")
# pm$projPara <- "0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0"
	} else {
	cat("Output projection parameters specified!\nUsing:",pm$projPara,"\n")
	}

######
if (pm$MRTpath=="check") {
	pm$MRTpath <- getPATH(quiet=TRUE)
	}
if (!file.exists(pm$MRTpath)) {stop("'MRTpath' is wrong. Provide a good path, leave empty or run 'getPATH()'")}


# after getSTRUC is called, getHDF can easily be called on single files...
# getSTRUC garants that all needed dir structure information is made avalable offline
ftpdirs <- getSTRUC(product=pm$product$request,collection=pm$collection,startdate=pm$startdate,enddate=pm$enddate)

######################## along platform (TerraAqua)
for(i in 1:length(pm$product$PF1)) { 

avDates <- ftpdirs[[i]]
avDates <- avDates[!is.na(avDates)]
avDates <- as.Date(avDates,format="%Y.%m.%d")

	us  <- avDates >= pm$startdate & avDates <= pm$enddate
	if (sum(us,na.rm=TRUE)>0){

avDates <- avDates[us]

######################### along start-end-date
for (l in 1:length(avDates)){ 

files <- getHDF(LocalArcPath=pm$LocalArcPath,product=pm$product$productName[i],collection=pm$collection,startdate=avDates[l],enddate=avDates[l],extent=pm$extent,stubbornness=pm$stubbornness,log=FALSE)

if (length(files)!=0){

	mos <- pm$mosaic

	if (mos) {
	
		if (sum(file.exists(files)) < length(pm$extent$tile)){ # if not all files available switch "off" mosaicing and process single files
			mos <- FALSE
		} else {
			mos <- TRUE
		}
	
	} else { 
			mos <-  FALSE
	}
	
	if (mos) {
		v <- 1
	} else {
		v <- 1:length(files)
	}
	
	for (q in v) {
	
		if (is.null(pm$SDSstring)) {
			pm$SDSstring <- rep(1,length(getSDS(HdfName=files[q],MRTpath=pm$MRTpath)))
		}
		
	SDSstringIntern <- getSDS(HdfName=files[q],SDSstring=pm$SDSstring,MRTpath=pm$MRTpath)

	if (!pm$quiet && i == 1 && l == 1) {cat("\nExtracing SDS:",SDSstringIntern$SDSnames,sep="\n ")}

	if (mos) {
		TmpMosNam <- paste("TmpMosaic",round(runif(1,1,1000000)),".hdf",sep="")
		### in subset
		paraname <- file.path(pm$outDir,"MRTgMosaic.prm",fsep=fsep) # create mosaic prm file
		filename = file(paraname, open="wt")
		write(paste(files,sep='',collapse=' '), filename)
		close(filename)

	# run mosaic
		if (.Platform$OS=="unix") {
				system(paste(pm$MRTpath,"/mrtmosaic -i ",paraname," -o ",pm$outDir,"/",TmpMosNam," -s '",SDSstringIntern$SDSstring,"'" ,sep=""))
			} else {
				shell(paste(pm$MRTpath,fsep,"mrtmosaic -i ",paraname," -o ",pm$outDir,fsep,TmpMosNam," -s \"",SDSstringIntern$SDSstring,"\"" ,sep=""))
			}
		unlink(paraname)

		Sys.sleep(1) # without wait the skript can break here. "wait" is a try but it seams to work!!!
	}
		
	basenam <- strsplit(files[q],fsep)[[1]]
	basenam <- basenam[length(basenam)]
	
	if (mos){
		basenam <- paste(strsplit(basenam,"\\.")[[1]][c(1,2,4)],collapse=".")
	} else {
		basenam <- paste(strsplit(basenam,"\\.")[[1]][c(1,2,3,4)],collapse=".")	
	}
	
	if (!pm$anonym) {
		basenam <- paste(basenam,pm$job,sep=".")
	}

#### Write prm File
	paraname <- paste(pm$outDir,"MRTgResample.prm",sep="")
	filename = file(paraname, open="wt")

	if (mos){
		write(paste('INPUT_FILENAME = ',pm$outDir,fsep,TmpMosNam,sep=''), filename)
	} else {
		write(paste('SPECTRAL_SUBSET = ( ',SDSstringIntern$SDSstring,' )',sep=''), filename)
		write(paste('INPUT_FILENAME = ',files[q],sep=''), filename)
	}

	write('SPATIAL_SUBSET_TYPE = INPUT_LAT_LONG',filename)

	if (pm$extent$extent[1]!=""){
		write(paste('SPATIAL_SUBSET_UL_CORNER = (',pm$extent$extent$ymax,' ',pm$extent$extent$xmin,')',sep=''),filename)
		write(paste('SPATIAL_SUBSET_LR_CORNER = (',pm$extent$extent$ymin,' ',pm$extent$extent$xmax,')',sep=''),filename)
	}
	if (!is.null(pm$pixelSize)) {
		write(paste('OUTPUT_PIXELSIZE = ',pm$pixelSize,sep=''),filename) 
	}	
	write(paste('OUTPUT_FILENAME = ',pm$outDir,fsep,basenam,'.tif',sep=''),filename) 
	write(paste('RESAMPLING_TYPE = ',pm$resample,sep=''),filename)
	write(paste('OUTPUT_PROJECTION_TYPE = ',pm$outProj,sep=''),filename)

	if (pm$outProj=="UTM" && !is.null(pm$zone)) {
		write(paste('UTM_ZONE = ',pm$zone,sep=''),filename)
	}
	
	if (!is.null(pm$projPara)) {
		write(paste('OUTPUT_PROJECTION_PARAMETERS = ( ',pm$projPara,' )',sep=''),filename)
	}
	
	write(paste('DATUM =', pm$datum,sep=''),filename)
	close(filename)

if (.Platform$OS=="unix") {
		system(paste(pm$MRTpath,"/resample -p ",paraname,sep=""))
	} else {
		shell(paste(pm$MRTpath,fsep,"resample -p ",paraname,sep=""))
	}
unlink(paraname)

if (mos) {
	unlink(paste(pm$outDir,TmpMosNam,sep="/"))
}

}

} else {
	cat("Missing files?",files,"jumping to the next date",sep="\n")
}

} # l, avDates
} else {cat("No files found for that product within the date range\n")}
} # i, Platform
}
