# Author: Matteo Mattiuzzi, Anja Klisch, matteo.mattiuzzi@boku.ac.at
# Date : July 2011
# Licence GPL v3
  

getHDF <- function(LocalArcPath,HdfName,product,startdate,enddate,tileH,tileV,extent,collection,dlmethod="auto",stubbornness="low",quiet=FALSE,wait=1,checkSize=FALSE,log=TRUE) {

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

if (is.numeric(stubbornness)) {
	sturheit <- subbornness	
	} else {
	sturheit <- c(1,3,8,50,500)[which(stubbornness==c("low","medium","high","veryhigh","extreme"))]
	}

#################

# TODO HdfName as regex

if (!missing(HdfName)){ 

	HdfName <- unlist(HdfName)
	dates <- list()
	for (i in seq(along=HdfName)){
	
	#remove path from filename
#	if (file.exists(HdfName[i])) { # 
	fname <- strsplit(HdfName[i],fsep)[[1]] # separate name from path
	fname <- fname[length(fname)] # select filename
	HdfName[i] <- fname
	rm(fname)
#	}
		
	secName <- strsplit(HdfName[i],"\\.")[[1]]
	
		if (secName[length(secName)]!= "hdf"){stop(HdfName[i],"is not a good hdf HdfName")}
					
	product <- getPRODUCT(product=secName[1])
  
	collection <- sprintf("%03d",as.numeric(secName[4]))
		if (!getCOLLECTION(product=product,collection=collection)) {stop(paste("The collection you have requested may doesn't exist run: 'getCOLLECTION(LocalArcPath='",LocalArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}

	fdate <- substr(secName[2],2,8)
	fdate <- format(as.Date(as.numeric(substr(fdate,5,7))-1,origin=paste(substr(fdate,1,4),"-01-01",sep="")),"%Y.%m.%d") # doy to date
	
	arcPath <- paste(product$productName,".",collection,fsep,fdate,fsep,sep="")
	dir.create(paste(LocalArcPath,fsep,arcPath,sep=""),recursive=TRUE,showWarnings=FALSE) # this always generates the same structure as the original ftp (this makes sense if the local LocalArcPath becomes big!)
	
	if (!file.exists(paste(LocalArcPath,fsep,arcPath,HdfName[i],sep=""))) {
		  require(RCurl)
		  ftpPath <- paste("ftp://e4ftl01.cr.usgs.gov/",product$PF1,"/", product$productName,".",collection,"/",fdate,"/",HdfName[i],sep="")
#			ftpPath <- paste("ftp://e4ftl01u.ecs.nasa.gov/",product$PF1,"/", product$productName,".",collection,"/",fdate,"/",HdfName[i],sep="")
		
		g=1
		hdf=1
		while(g <= sturheit) {

			if (g==1){qi <- quiet} else { qi <- TRUE}

			try(hdf <- download.file(
				ftpPath,
				destfile=paste(LocalArcPath,fsep,arcPath,HdfName[i],sep=""),
				mode='wb', method=dlmethod, quiet=qi, cacheOK=FALSE)
			)
		if(hdf==0) {break}	
		g=g+1		
		}

		if (wait>0) {
			Sys.sleep(as.numeric(wait))
		}
	}
		
	if(checkSize){
		g=1
		xml=1
		while(g <= sturheit | xml != 0) {
		
			if (g==1){qi <- quiet} else { qi <- TRUE}
	
			try(xml <- getXML(HdfName = HdfName[i],checkSize=TRUE,wait=wait,quiet=qi,dlmethod=dlmethod))
		if(xml==0) {break}
		g=g+1
		}
	}

dates[[i]] <- paste(LocalArcPath,fsep,arcPath,HdfName[i],sep="")
	}
return(invisible(unlist(dates)))

} else { # if HdfName isn't provided:

if (missing(startdate)) {cat("No startdate set, getting data from the beginning\n")} 
if (missing(enddate))   {cat("No enddate set, getting up to the most actual data\n")} 
if (missing(extent) & (missing(tileH) | missing(tileV))){stop("Please provide eighter a 'tileH(s)' plus tileV(s) or an extent")} 
if (missing(product))   {stop("Please provide the MODIS-'product'")}
#######
# check product
product <- getPRODUCT(product=product)

# check collection
if (missing(collection)) {
	collection <- getCOLLECTION(product=product)
		if (!quiet){
	cat("No Collection spezified used the newest for ",product$productName,":", collection,"\n",sep="")
		}
	} else {
	collection <- sprintf("%03d",as.numeric(collection))
	if (!getCOLLECTION(product=product,collection=collection)) {stop(paste("The collection you have requested may doesn't exist run: 'getCOLLECTION(LocalArcPath='",LocalArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}
	}
#########
# tranform dates
tLimits <- transDATE(begin=startdate,end=enddate)
begin   <- tLimits$begin
end     <- tLimits$end
#########
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
l=0

for(z in 1:length(product$PF1)){ # Platforms MOD/MYD

	productName <- product$productName[z]

	ftp <- paste("ftp://e4ftl01.cr.usgs.gov/", product$PF1[z],"/", product$productName[z],".",collection,"/",sep="")
	#ftp <- paste("ftp://e4ftl01u.ecs.nasa.gov/", product$PF1[z],"/", product$productName[z],".",collection,"/",sep="")

	ftpdirs <- getSTRUC(LocalArcPath=LocalArcPath,product=product$productName[z],collection=collection,startdate=startdate,enddate=enddate,wait=0)
		
	ftpdirs <- ftpdirs[,which(colnames(ftpdirs)==paste(product$productName[z],".",collection,sep=""))] 
	ftpdirs <- ftpdirs[!is.na(ftpdirs)]
	
	sel <- as.Date(ftpdirs,format="%Y.%m.%d") # convert to date
	us  <- sel >= begin & sel <= end

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
arcPath <- paste(LocalArcPath,fsep,product$PF2[z],product$PD,".",collection,fsep,dates[[z]][i,1],fsep,sep="")
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

	ftpfiles <- getURL(paste(ftp,dates[[z]][i,1],"/",sep=""))
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
			hdf=1
			while(g <= sturheit) {
			
				if (g==1){qi <- quiet} else { qi <- TRUE}
			
				try(hdf <- download.file(paste(ftp, dates[[z]][i,1], "/", HDF,sep=""), destfile=paste(arcPath, HDF, sep=""), mode='wb', method=dlmethod, quiet=qi, cacheOK=FALSE),silent=TRUE)
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
		dir.create(paste(LocalArcPath,fsep,"LOGS",fsep,sep=""),showWarnings=FALSE)	
		write.csv(dates[[z]],file=paste(LocalArcPath,fsep,"LOGS",fsep,product$PF2[z],product$PD,"_",collection,"_CHECK.csv",sep=""))
	}
	
	if(checkSize){
		g=1
		xml=1
		while(g <= sturheit) {
			if (g==1){qi <- quiet} else { qi <- TRUE}
			try(xml <- getXML(HdfName = as.list(paste(arcPath,dates[[z]][i,-1],sep="")),wait=wait,quiet=qi,dlmethod=dlmethod),silent=TRUE)
		if(xml==0) {break}
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



