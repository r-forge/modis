# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : July 2011
# Licence GPL v3

getXml <- function(HdfName,checkSize=TRUE,wait=1,dlmethod="auto",quiet=FALSE,stubbornness="extreme",localArcPath=.getDef('localArcPath')){

localArcPath <- paste(strsplit(localArcPath,"/")[[1]],collapse="/")# removes "/" or "\" on last position (if present)
dir.create(localArcPath,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath,recursive=FALSE), silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 
#################

sturheit <- .stubborn(level=stubbornness)


if(!missing(HdfName)) {
	
	HdfName <- unlist(HdfName)
	avFiles <- list()
	
	for (i in seq(length(HdfName))){
		if (file.exists(HdfName[i])) { # if exists than HdfName is a path+File+itexists
			avFiles[[i]] <- HdfName[i] 
		} else {
			avFiles[[i]] <- list.files(localArcPath,pattern=HdfName[i],recursive=TRUE,full.names=TRUE)
			avFiles[[i]] <- grep(avFiles[[i]], pattern=".hdf$",value=TRUE) # no ".hdf.xml" files, only ".hdf" 
		}
	}
	 
avFiles <- unlist(avFiles)
} else {
avFiles <- list.files(localArcPath,pattern=".hdf$",recursive=TRUE,full.names=TRUE) # all hdf under 'localArcPath'
}

data(MODIS_Products)
# tests if it is a MODIS-grid file(s) (TODO proper function that checks that)
doit <- .isSupported(avFiles)
avFiles <- avFiles[doit]

if(length(avFiles)==0) {
	return(cat("No MODIS grid files found.\n"))
	} else {

islocal <- rep(NA,length(avFiles))

    for (u in seq(along=avFiles)){

	if (
		!file.exists(paste(avFiles[u],".xml",sep=""))
		|
		if (file.exists(paste(avFiles[u],".xml",sep=""))){
			if (.Platform$OS.type == "unix") {
				resu <- as.numeric(system(paste("stat -c %s ",avFiles[u],".xml",sep=""), intern=TRUE)) < 2000	
			} else { #.Platform$OS.type == "windows"
				resu <- as.numeric(shell(paste("for %I in (",avFiles[u],".xml) do @echo %~zI",sep=""),intern=TRUE)) < 2000 # should work with win2000 and later...	
			}
		} else {
			resu <- FALSE
		}
	) {
		
	fname   <- basename(avFiles[u]) # separate filename from path
	secName <- strsplit(fname,"\\.")[[1]] # decompose filename
	product <- getProduct(x=secName[1])	
	fdate <- substr(secName[2],2,8)
	fdate <- format(as.Date(as.numeric(substr(fdate,5,7))-1,origin=paste(substr(fdate,1,4),"-01-01",sep="")),"%Y.%m.%d")

	collection <- if (product$TYPE=="Tile") {
				secName[4]
			} else if (product$TYPE=="CMG") {
				secName[3]	
			} else {
				stop(product$TYPE," not supported yet!")			
			}

	g=1
	while(g <= sturheit) {
		if (g==1){qi <- quiet} else { qi <- TRUE}
		try(isin <- download.file( #xml file
		paste("ftp://e4ftl01.cr.usgs.gov/", product$PF1,"/",product$PRODUCT,".",collection,"/",fdate,"/",fname,".xml",sep=""),
		destfile=paste(avFiles[u],".xml",sep=""),
		mode='wb', method=dlmethod, quiet=quiet, cacheOK=FALSE),silent=TRUE)
	if(sum(isin)==0) {break}
	g=g+1
	}
	islocal[u] <- isin
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
		cat("\nSize Error detected: ",avFiles[u],"\nFileSize is ",FileSize,", but should be: ",MetaSize,"\n",sep="")
		}
		
# get the hdf file if size fails
	g=1
	while(g <= sturheit) {
		if (g==1){qi <- quiet} else { qi <- TRUE}
		try(hdf <- 	download.file( ##hdf file
			paste("ftp://e4ftl01.cr.usgs.gov/", product$PF1,"/",product$PRODUCT,".",collection,"/",fdate,"/",fname,sep=""),
			destfile=paste(avFiles[u],sep=""),
			mode='wb', method=dlmethod, quiet=quiet, cacheOK=FALSE),silent=TRUE)
	if(hdf==0) {break}
	g=g+1
	}

	} else {
		if(!quiet){
			cat("\nSize check done for: ",avFiles[u], "\n\n")
		}
	}
}

}
invisible(length(islocal))
} # if avFiles > 0
}

