# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : July 2011
# Licence GPL v3

getXML <- function(LocalArcPath,HdfName,checkSize=TRUE,wait=1,dlmethod="auto",quiet=FALSE,stubbornness="extreme"){

fsep <- .Platform$file.sep

if (missing(LocalArcPath)) {
	LocalArcPath <- normalizePath("~", winslash = fsep)
	LocalArcPath <- file.path(LocalArcPath,"MODIS_ARC",fsep=fsep)
		if(!quiet){
		cat(paste("No archive path set, using/creating standard archive in: ",LocalArcPath,"\n",sep=""))
		flush.console()
		}
}

LocalArcPath <- paste(strsplit(LocalArcPath,fsep)[[1]],collapse=fsep)# removes "/" or "\" on last position (if present)
dir.create(LocalArcPath,showWarnings=FALSE)
# test local LocalArcPath
try(testDir <- list.dirs(LocalArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'LocalArcPath' not set properly!")} 
#################
if (is.numeric(stubbornness)) {
	sturheit <- stubbornness	
	} else {
	sturheit <- c(1,3,8,50,500)[which(stubbornness==c("low","medium","high","veryhigh","extreme"))]
	}


if(!missing(HdfName)) {
	
	HdfName <- unlist(HdfName)
	avFiles <- list()
	
	for (i in seq(length(HdfName))){
		if (file.exists(HdfName[i])) { # if exists than HdfName is a path+File+itexists
		avFiles[[i]] <- HdfName[i] 
		} else {
		avFiles[[i]] <- list.files(LocalArcPath,pattern=HdfName[i],recursive=TRUE,full.names=TRUE)
		avFiles[[i]] <- grep(avFiles[[i]], pattern=".hdf$",value=TRUE) # removes xml files from list 
		}
	}
	 
avFiles <- unlist(avFiles)
} else {
avFiles <- list.files(LocalArcPath,pattern=".hdf$",recursive=TRUE,full.names=TRUE) # all hdf under the 'LocalArcPath'
}

# tests if it is a MODIS-grid file(s) (TODO function that checks that)
doit <- sapply(avFiles,function(x) {
	fname <- strsplit(x,"/")[[1]] # separate name from path
	fname <- fname[length(fname)] # select filename
	secName  <- strsplit(fname,"\\.")[[1]] # decompose filename
	PF <- substr(secName[1],1,3)
	Tpat <- "h[0-3][0-9]v[0-1][0-9]" # to enhance

	if (sum((grep(secName[3],pattern=Tpat)) + (substr(secName[2],1,1) == "A") + (PF %in% c("MOD","MYD","MCD")) + (length(secName)==6)) == 4){
		res <- TRUE
	} else {
		res <- FALSE
	}

	return(res)}
	)
doit <- unlist(doit) # ??
avFiles <- avFiles[doit]

if(length(avFiles)==0) {
	return(cat("No MODIS grid files found.\n"))
	} else {

islocal <- rep(NA,length(avFiles))

    for (u in seq(along=avFiles)){

	if (
		!file.exists(paste(avFiles[u],".xml",sep=""))
		| 
		if (.Platform$OS.type == "unix" & file.exists(paste(avFiles[u],".xml",sep=""))) { # limited size control for xml files
		as.numeric(system(paste("stat -c %s ",avFiles[u],".xml",sep=""), intern=TRUE)) < 2000
		} else if (.Platform$OS.type == "windows" & file.exists(paste(avFiles[u],".xml",sep=""))) {
		as.numeric(shell(paste("for %I in (",avFiles[u],") do @echo %~zI",sep=""),intern=TRUE)) < 2000 # should work with win2000 and later...
		}else{
		FALSE
		} 
	){
	fname <- strsplit(avFiles[u],"/")[[1]] # separate filename from path
	fname <- fname[length(fname)]
	secName  <- strsplit(fname,"\\.")[[1]] # decompose filename
	product <-  getPRODUCT(product=secName[1])	

	fdate <- substr(secName[2],2,8)
	fdate <- format(as.Date(as.numeric(substr(fdate,5,7))-1,origin=paste(substr(fdate,1,4),"-01-01",sep="")),"%Y.%m.%d")

	collection <- if (product$raster_type=="Tile") {
				secName[4]
			} else if (product$raster_type=="CMG") {
				secName[3]	
			} else {
			stop(product$raster_type," not supported yet!")			
			}

	require(RCurl) # is it good here?

	g=1
	while(g <= sturheit) {
		if (g==1){qi <- quiet} else { qi <- TRUE}
		try(xml <- download.file(
		paste("ftp://e4ftl01.cr.usgs.gov/", product$PF1,"/",product$productName,".",collection,"/",fdate,"/",fname,".xml",sep=""),
		destfile=paste(avFiles[u],".xml",sep=""),
		mode='wb', method=dlmethod, quiet=quiet, cacheOK=FALSE),silent=TRUE)
	if(sum(xml)==0) {break}
	g=g+1
	}
	islocal[u] <- xml
	} else {
	islocal[u] <- 0
	}

# XML based checksum for HDF files
if (checkSize) {
	xml <- paste(avFiles[u],".xml",sep="")
	require(XML)
	xml    <- xmlParse(xml) # removed "try()". T think it was just forgotten after a test!
	MetaSize <- getNodeSet( xml, "/GranuleMetaDataFile/GranuleURMetaData/DataFiles/DataFileContainer/FileSize" )
	MetaSize <- as.numeric(xmlValue(MetaSize[[1]]))

	if (.Platform$OS.type == "unix") {
		FileSize <- as.numeric(system(paste("stat -c %s ",avFiles[u],sep=""), intern=TRUE))
	} else if (.Platform$OS.type == "windows") {
		FileSize <- as.numeric(shell(paste("for %I in (",avFiles[u],") do @echo %~zI",sep=""),intern=TRUE))
	} else {
	stop("Only Unix based and Windows supported, please tell me which system you use!")
	}
	
	if (MetaSize != FileSize) {
		if(!quiet){
			cat("\nMETA check for file:",avFiles[u],"\nFileSize:",FileSize,"but expected:",MetaSize,"\n")
		}
	fname <- strsplit(avFiles[u],"/")[[1]] # separate filename from path
	fname <- fname[length(fname)]
	secName  <- strsplit(fname,"\\.")[[1]] # decompose filename
	product <-  getPRODUCT(product=secName[1])	

	fdate <- substr(secName[2],2,8)
	fdate <- format(as.Date(as.numeric(substr(fdate,5,7))-1,origin=paste(substr(fdate,1,4),"-01-01",sep="")),"%Y.%m.%d")

	collection <- if (product$raster_type=="Tile") {
				secName[4]
			} else if (product$raster_type=="CMG") {
				secName[3]	
			} else {
			stop(product$raster_type," not supported yet!")			
			}
	g=1
	while(g <= sturheit) {
		if (g==1){qi <- quiet} else { qi <- TRUE}
		try(hdf <- 	download.file(
			paste("ftp://e4ftl01.cr.usgs.gov/", product$PF1,"/",product$productName,".",collection,"/",fdate,"/",fname,sep=""),
			destfile=paste(avFiles[u],sep=""),
			mode='wb', method=dlmethod, quiet=quiet, cacheOK=FALSE),silent=TRUE)
	if(hdf==0) {break}
	g=g+1
	}

	} else {
		if(!quiet){
			cat("\nSize check for: ",avFiles[u], "done!\n\n")
		}
	}
}

}
invisible(islocal)
} # if avFiles > 0
}

