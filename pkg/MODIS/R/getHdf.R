# Author: Matteo Mattiuzzi, Anja Klisch, matteo.mattiuzzi@boku.ac.at
# Date : July 2011
# Licence GPL v3
  

getHdf <- function(HdfName,product,begin=NULL,end=NULL,tileH,tileV,extent,collection,dlmethod="auto",stubbornness="veryhigh",quiet=FALSE,wait=1,checkSize=FALSE,log=TRUE,localArcPath=.getDef("localArcPath")) {

serverList <- list() # Temporary! Thing to implement are alternative servers if datapool is down!
serverList[[1]] <- "ftp://e4ftl01.cr.usgs.gov/" # xml in? YES
serverList[[2]] <- "ftp://ladsweb.nascom.nasa.gov/allData/" # xml in? NO

localArcPath <- normalizePath(localArcPath,"/",mustWork=FALSE)
dir.create(localArcPath,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 

auxPATH <- file.path(localArcPath,".auxiliaries",fsep="/")

sturheit <- .stubborn(level=stubbornness)

# TODO HdfName as regex

if (!missing(HdfName)){ 

	HdfName <- unlist(HdfName)
	dates <- list()
	for (i in seq(along=HdfName)){
	
	fname <- basename(HdfName[i]) # separate name from path
	HdfName[i] <- fname
	rm(fname)
		
	secName <- strsplit(HdfName[i],"\\.")[[1]]
	
		if (secName[length(secName)]!= "hdf"){stop(HdfName[i],"is not a good HdfName")}
					
	product <- getProduct(x=secName[1])
  
	collection <- sprintf("%03d",as.numeric(secName[4]))
		if (getCollection(product=product,collection=collection)==FALSE) {stop(paste("The collection you have requested may doesn't exist run: 'getCollection(localArcPath='",localArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}

	fdate <- substr(secName[2],2,8)
	fdate <- format(as.Date(as.numeric(substr(fdate,5,7))-1,origin=paste(substr(fdate,1,4),"-01-01",sep="")),"%Y.%m.%d") # doy to date
	
	arcPath <- paste(product$PRODUCT,".",collection,"/",fdate,"/",sep="")
	dir.create(paste(localArcPath,"/",arcPath,sep=""),recursive=TRUE,showWarnings=FALSE) # this always generates the same structure as the original ftp (this makes sense if the local localArcPath becomes big!)
	
	if (!file.exists(paste(localArcPath,"/",arcPath,HdfName[i],sep=""))) {
		ftpPath <- list()
		ftpPath[[1]] <- paste(serverList[[1]],product$PF1,"/", product$PRODUCT,".",collection,"/",fdate,"/",HdfName[i],sep="")
		ftpPath[[2]] <- paste(serverList[[2]],as.numeric(collection),"/", product$PRODUCT,"/",substr(secName[2],2,5),"/",substr(secName[2],6,8),HdfName[i],sep="")

			
		g=1
		while(g <= sturheit) {

		if (g==1){qi <- quiet} else { qi <- TRUE}
	
		for (x in 1:length(serverList)){
			try(hdf <- download.file(
				ftpPath[[x]],
				destfile=paste(localArcPath,"/",arcPath,HdfName[i],sep=""),
				mode='wb', method=dlmethod, quiet=qi, cacheOK=FALSE)
			)
		if(hdf==0 & !quiet) {cat("Downloaded after:",g,"retries\n")}
		if(hdf==0) {break}	
		}
		g=g+1	
		Sys.sleep(0.3) # not proven that it works here! 
		}

		Sys.sleep(as.numeric(wait))

	}
		
	if(checkSize){
		g=1
		while(g <= sturheit) {
		
			if (g==1){qi <- quiet} else { qi <- TRUE}
	
			try(xml <- getXml(HdfName = HdfName[i],checkSize=TRUE,wait=wait,quiet=qi,dlmethod=dlmethod))
		if(sum(xml)==0) {break}
		g=g+1
		}
	}

dates[[i]] <- paste(localArcPath,"/",arcPath,HdfName[i],sep="")
	}
return(invisible(unlist(dates)))

} else { # if HdfName isn't provided:

if (is.null(begin)) {cat("No begin(-date) set, getting data from the beginning\n")} 
if (is.null(end))   {cat("No end(-date) set, getting up to the most actual data\n")} 
if (missing(product)){stop("Please provide the supported-'product'. See in: 'getProduct()'")}
#######
# check product
product <- getProduct(x=product)

# check collection
if (missing(collection)) {
		collection <- getCollection(product=product,quiet=quiet)
	} else {
		collection <- sprintf("%03d",as.numeric(collection))
			if (getCollection(product=product,collection=collection)==FALSE) { # can be FALSE or collection number
				stop(paste("The collection you have requested may doesn't exist run: 'getCollection(localArcPath='",localArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}
	}
#########
# tranform dates
tLimits <- transDate(begin=begin,end=end)
#########
# tileID
if (product$TYPE=="CMG") {
	tileID="GLOBAL"
	ntiles=1 
	} else {
	if (!missing(extent)) {
  	tileID <- getTile(extent=extent)$tile
 	 } else if (!missing(tileH) & !missing(tileV)) {
    tileID <- getTile(tileH=tileH,tileV=tileV)$tile
 	 } else {stop("Please provide eighter a 'tileH' plus 'tileV' or an 'extent'")}
	ntiles <- length(tileID)
}


dates  <- list()
output <- list() # path info for the invisible output
l=0

for(z in 1:length(product$PF1)){ # Platforms MOD/MYD

	productName <- product$PRODUCT[z]

		ftp <- paste(serverList[[1]], product$PF1[z],"/", product$PRODUCT[z],".",collection,"/",sep="")
		
	ftpdirs <- unlist(.getStruc(localArcPath=localArcPath,product=product$PRODUCT[z],collection=collection,begin=tLimits$begin,end=tLimits$end,wait=0))
	
	sel <- as.Date(ftpdirs,format="%Y.%m.%d") # convert to date
	us  <- sel >= tLimits$begin & sel <= tLimits$end

	if (sum(us,na.rm=TRUE)>0){ 

	dates[[z]] <- ftpdirs[us]

	dates[[z]] <- cbind(dates[[z]],matrix(rep(NA, length(dates[[z]])*ntiles),ncol=ntiles,nrow=length(dates[[z]])))
	colnames(dates[[z]]) <- c("date",tileID)

	for (i in 1:nrow(dates[[z]])){

		year <- format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%Y")
		doy  <- as.integer(format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%j"))
		doy  <- sprintf("%03d",doy)
		datu <- paste("A",year,doy,sep="")
		mtr  <- rep(1,ntiles) # for file availability flaging

# creates local directory (HDF file container)
arcPath <- paste(localArcPath,"/",product$PF2[z],product$PD,".",collection,"/",dates[[z]][i,1],"/",sep="")
dir.create(arcPath,showWarnings=FALSE,recursive=TRUE)

for(j in 1:ntiles){

dates[[z]][i,j+1] <- paste(product$PF2[z],product$PD,".",datu,".",if (tileID[j]!="GLOBAL") {paste(tileID[j],".",sep="")},collection,".*.hdf$",sep="") # create pattern
	
	if (length(dir(arcPath,pattern=dates[[z]][i,j+1]))>0){ # if available locally
		
		HDF <- dir(arcPath,pattern=dates[[z]][i,j+1])  # extract HDF file
		
		if (length(HDF)>1) { # in very recent files sometimes there is more than 1 file/tile/date if so get the last
			select <- list()
			for (d in 1:length(HDF)){ 
			select[[d]]<- strsplit(HDF[d],"\\.")[[1]][5]
			}
			HDF <- HDF[which.max(unlist(select))]		
			}
	dates[[z]][i,j+1] <- HDF
	mtr[j] <- 0
	}
}


if (sum(mtr)!=0) { # if one or more of the tiles in date is missing, its necessary to go on ftp

	if(exists("ftpfiles")) {rm(ftpfiles)}
	require(RCurl)
	for (g in 1:sturheit){
		try(ftpfiles <- getURL(paste(ftp,dates[[z]][i,1],"/",sep="")),silent=TRUE)
		if(exists("ftpfiles")){break}
	}
	ftpfiles <- strsplit(ftpfiles, if(.Platform$OS.type=="unix"){"\n"} else{"\r\n"})[[1]]
		if (wait > 0){Sys.sleep(as.numeric(wait))}

	if (ftpfiles[1] != "total 0") {
    
    ftpfiles <- unlist(lapply(strsplit(ftpfiles," "),function(x){x[length(x)]})) # found empty dir!
	
		for(j in 1:ntiles){
		
		if(mtr[j]==1){ # if tile is missing get it
			onFtp <- grep(ftpfiles,pattern=dates[[z]][i,j+1],value=TRUE)
			HDF   <- grep(onFtp,pattern=".hdf$",value=TRUE)

			if(length(HDF)>0){
					
				if (length(HDF)>1) { # in very recent files sometimes there is more than 1 file/tile/date if so get the last
				select <- list()
				for (d in 1:length(HDF)){
				select[[d]]<- strsplit(HDF[d],"\\.")[[1]][5]
				}
				HDF <- HDF[which.max(unlist(select))]		
				}
			dates[[z]][i,j+1] <- HDF
				

			g=1
			while(g <= sturheit) {
			
				if (g==1){qi <- quiet} else {qi <- TRUE}
			
				try(hdf <- download.file(paste(ftp, dates[[z]][i,1], "/", HDF,sep=""),
					destfile=paste(arcPath, HDF, sep=""), mode='wb', method=dlmethod, quiet=qi, cacheOK=FALSE),silent=TRUE)
				if(hdf==0 & !quiet) {
					if (g==1) {
						cat("Downloaded by the first try!\n\n")
					} else {
						cat("Downloaded after",g,"retries!\n\n")
					}
				}
				if(hdf==0) {break}
			g=g+1
			}
				
			mtr[j] <- hdf
				if (wait > 0){Sys.sleep(as.numeric(wait))}
			} else { 
				dates[[z]][i,j+1] <- "No tile for location" 
			}
		} # if mtr==1
	
		}
	} else {
	dates[[z]][i,(j+1):ncol(dates[[z]])] <- "No files for that date on FTP"
	} # on ftp is possible to find empty folders!
}

	if (log) {
		dir.create(file.path(localArcPath,"LOGS",fsep="/"),showWarnings=FALSE)	
		write.csv(dates[[z]],file=file.path(localArcPath,"LOGS",paste(product$PF2[z],product$PD,".",collection,"_LOG.csv",sep=""),fsep="/"))
	}
	
	if(checkSize){
		g=1
		while(g <= sturheit) {
			if (g==1){qi <- quiet} else { qi <- TRUE}
			try(xmlIn <- getXml(HdfName = as.list(paste(arcPath,dates[[z]][i,-1],sep="")),wait=wait,quiet=qi,dlmethod=dlmethod),silent=TRUE)
		if(sum(xmlIn)==0) {break}
		g=g+1
		}
	} # as.list() should not be needed but but but...

l=l+1
output[[l]] <- paste(arcPath,grep(dates[[z]][i,-1],pattern=".hdf$",value=TRUE),sep="")
} # end dates i 

}else{
#		if (!quiet){
	cat(paste("No files on ftp in date range for: ",product$PF2[z],product$PD,".",collection,"\n\n",sep=""))
#		}
	}
} # if no files are avalaible for product in date AND end platform z
return(invisible(paste(unlist(output),sep="")))
} # end if not HdfName
} ## END: FTP vs ARC check and download 



