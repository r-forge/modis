# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : November 2011
# Licence GPL v3
  
checkAV <- function(LocalArcPath,product,startdate,enddate,tileH,tileV,extent,collection,quiet=FALSE){

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

auxPATH <- file.path(LocalArcPath,".auxiliaries",fsep=fsep)

#################
if (missing(extent) & (missing(tileH) | missing(tileV))){stop("Please provide eighter a 'tileH(s)' plus tileV(s) or an extent")} 
if (missing(product))   {stop("Please provide the MODIS-'product'")}

product <- getPRODUCT(product=product)

# check collection
if (missing(collection)) {
	collection <- getCOLLECTION(product=product)
		if (!quiet){
	cat("No Collection spezified used the newest for",product$productName,":", collection,"\n")
		}
	} else {
	collection <- sprintf("%03d",as.numeric(collection))
	if (getCOLLECTION(product=product,collection=collection)==FALSE) {stop(paste("The collection you have requested may doesn't exist run: 'getCOLLECTION(LocalArcPath='",LocalArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}
	}

#### convert dates 
tLimits <- transDATE(begin=startdate,end=enddate)
begin   <-tLimits$begin
end     <-tLimits$end
####

# tileID
if (substr(product$PD,3,nchar(product$PD))=="CMG") {
	tileID="GLOBAL"
	ntiles=1 
	} else {
	if(!missing(extent)) {
  	tileID <- getTILE(extent=extent)$tile
 	 } else {
 	 tileID <- getTILE(tileH=tileH,tileV=tileV)$tile
 	 }
	ntiles <- length(tileID)
}


dates  <- list()
output <- list() # path info for the invisible output
availableFiles <-list()
l=0

for(z in 1:length(product$PF1)){ # Platforms MOD/MYD

	productName <- product$productName[z]

	ftp <- paste("ftp://e4ftl01.cr.usgs.gov/", product$PF1[z],"/", product$productName[z],".",collection,"/",sep="")
	#ftp <- paste("ftp://e4ftl01u.ecs.nasa.gov/", product$PF1[z],"/", product$productName[z],".",collection,"/",sep="")

	ftpdirs <- getSTRUC(LocalArcPath=LocalArcPath,product=product$productName[z],collection=collection,startdate=begin,enddate=end,wait=0)
		
	ftpdirs <- ftpdirs[,which(colnames(ftpdirs)==paste(product$productName[z],".",collection,sep=""))] 
	ftpdirs <- ftpdirs[!is.na(ftpdirs)]
	
	sel <- as.Date(ftpdirs,format="%Y.%m.%d") # convert to date
	us  <- sel >= begin & sel <= end

	if (sum(us,na.rm=TRUE)>0){ 

	dates[[z]] <- ftpdirs[us]

	dates[[z]] <- cbind(dates[[z]],matrix(rep(NA, length(dates[[z]])*ntiles),ncol=ntiles,nrow=length(dates[[z]])))
	colnames(dates[[z]]) <- c("date",tileID)
	
	availableFiles[[z]] <- matrix(NA,ncol=ntiles,nrow=length(ftpdirs[us]))
	colnames(availableFiles[[z]]) <- tileID

	for (i in 1:nrow(dates[[z]])){

		year <- format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%Y")
		doy  <- as.integer(format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%j"))
		doy  <- sprintf("%03d",doy)
		datu <- paste("A",year,doy,sep="")

# creates local directory (HDF file container)
arcPath <- paste(LocalArcPath,fsep,product$PF2[z],product$PD,".",collection,fsep,dates[[z]][i,1],fsep,sep="")
dir.create(arcPath,showWarnings=FALSE,recursive=TRUE)

for(j in 1:ntiles){

fileC <- paste(product$PF2[z],product$PD,".",datu,".",if (tileID[j]!="GLOBAL") {paste(tileID[j],".",sep="")},collection,".*.hdf$",sep="") # create pattern
	
	if (length(list.files(path=arcPath,pattern=fileC))>0){
		availableFiles[[z]][i,j] <- 1
	} else {
		availableFiles[[z]][i,j] <- 0
	}
}
}
}
}
result <- unlist(availableFiles)
return(list(requested=length(result),available=sum(result)))
}




