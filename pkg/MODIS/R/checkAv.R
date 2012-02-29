# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : November 2011
# Licence GPL v3
  
checkAv <- function(product,begin=NULL,end=NULL,tileH,tileV,extent,collection,quiet=FALSE,localArcPath=.getDef("localArcPath")){

localArcPath <- normalizePath(localArcPath,"/",mustWork=FALSE)
dir.create(localArcPath,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 

auxPATH <- file.path(localArcPath,".auxiliaries",fsep="/")

#################
if (missing(product)){stop("Please provide the MODIS-'product'")}
product <- getProduct(x=product)

# check collection
if (missing(collection)) {
	collection <- getCollection(product=product)
		if (!quiet){
	cat("No Collection specified used the newest for",product$request,":", collection,"\n")
		}
	} else {
	collection <- sprintf("%03d",as.numeric(collection))
	if (getCollection(product=product,collection=collection)==FALSE) {stop(paste("The collection you have requested may doesn't exist run: 'getCollection(localArcPath='",localArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}
	}

#### convert dates 
tLimits <- transDate(begin=begin,end=end)
begin   <- tLimits$begin
end     <- tLimits$end
####

# tileID
if (product$TYPE=="CMG") {
	tileID="GLOBAL"
	ntiles=1 
	} else {
	if (!missing(extent)) {
  	tileID <- getTile(extent=extent)$tile
 	 } else if (!missing(tileH) & !missing(tileV)) {
    tileID <- getTile(tileH=tileH,tileV=tileV)$tile
 	 } else {stop("Please provide eighter a 'tileH(s)' plus tileV(s) or an extent")}
	ntiles <- length(tileID)
}

dates  <- list()
output <- list() # path info for the invisible output
availableFiles <-list()
l=0

for(z in 1:length(product$PF1)){ # Platforms MOD/MYD

	productName <- product$PRODUCT[z]

	ftpdirs <- unlist(.getStruc(localArcPath=localArcPath, product=product$PRODUCT[z], collection=collection, begin=begin, end=end, wait=0))
	
	sel <- as.Date(ftpdirs,format="%Y.%m.%d") # convert to date
	us  <- sel >= begin & sel <= end

	if (sum(us,na.rm=TRUE)>0){ 

	dates[[z]] <- ftpdirs[us]
	dates[[z]] <- cbind(dates[[z]],matrix(rep(NA, length(dates[[z]])*ntiles), ncol=ntiles, nrow=length(dates[[z]])))
	colnames(dates[[z]]) <- c("date",tileID)
	
	availableFiles[[z]] <- matrix(NA,ncol=ntiles, nrow=length(ftpdirs[us]))
	colnames(availableFiles[[z]]) <- tileID

	for (i in 1:nrow(dates[[z]])){

		year <- format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%Y")
		doy  <- as.integer(format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%j"))
		doy  <- sprintf("%03d",doy)
		datu <- paste("A",year,doy,sep="")

# creates local directory (HDF file container)
arcPath <- paste(localArcPath,"/",product$PF2[z],product$PD,".",collection,"/",dates[[z]][i,1],"/",sep="")
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




