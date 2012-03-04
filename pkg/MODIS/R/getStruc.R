# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3


.getStruc <- function(product,begin=NULL,end=NULL,wait=1,localArcPath=.getDef("localArcPath")) {


localArcPath <- normalizePath(localArcPath,"/",mustWork=FALSE)
dir.create(localArcPath,recursive=TRUE,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 

auxPATH <- file.path(localArcPath,".auxiliaries",fsep="/")
dir.create(auxPATH,recursive=TRUE,showWarnings=FALSE)

# Check Platform and product
product <- getProduct(x=product,quiet=TRUE)
# Check collection
if (length(product$CCC)==0) {
product$CCC <- getCollection(product=product) # if collection isn't provided, this gets the newest for the selected products.
}
dates <- transDate(begin=begin,end=end)

# load aux
if (file.exists(file.path(auxPATH,"ftpdir.txt",fsep="/"))) {
	ftpdirs   <- read.table(file.path(auxPATH,"ftpdir.txt",fsep="/"),stringsAsFactors=FALSE)
} else {
	ftpdirs   <- data.frame()
}

for (i in 1:length(product$PRODUCT)){

	todo <- paste(product$PRODUCT[i],".",product$CCC[[i]],sep="")
	
	for(u in 1:length(todo)){
		createNew <- TRUE

		if (todo[u] %in% names(ftpdirs)) {
			
			createNew <- FALSE
			ind <- which(names(ftpdirs)==todo[u])

				avDates <- as.Date(ftpdirs[,ind],format="%Y.%m.%d")
		
				if (!is.null(begin)){
					if (dates$begin < min(avDates,na.rm=TRUE)) {
						getIT <- TRUE
					} else {
						getIT <- FALSE
					}
				} else {
					getIT <- TRUE
				}
	
				if (!is.null(end) & !getIT) {
					if (dates$end > max(avDates,na.rm=TRUE)) {
						getIT <- TRUE
					} else {
						getIT <- FALSE
					}
				} else {
					getIT <- TRUE
				}
		} else {
			getIT     <- TRUE
		}


	if (getIT) { # the return is 'FtpDayDirs' of the requested product

		path <- MODIS:::.genString(x=product$PRODUCT[i],collection=product$CCC[[which(names(product$CCC)==product$PRODUCT[i])]][u],local=FALSE)
		cat("Getting structure in: ", names(path$remotePath)[1],", for ",todo[u],"\n",sep="")
		
		require(RCurl)
		
		thePath <- gsub(path$remotePath$LPDAAC,pattern="DATE",replacement="")

		if(exists("FtpDayDirs")) {
			rm(FtpDayDirs)
		}
		for (g in 1:MODIS:::.stubborn()){
			cat("Try:",g,"\r")
			try(FtpDayDirs <- getURL(thePath),silent=TRUE)
			
			if(exists("FtpDayDirs")){
			cat("")			
			break
			}
			if (wait > 0 && i < length(product$PRODUCT)) {
				Sys.sleep(wait)
			}
		}
		if(!exists("FtpDayDirs")) {stop("Could not connect to FTP!")}

		FtpDayDirs <- unlist(strsplit(FtpDayDirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"})) # ok for Mac/Solaris?
		FtpDayDirs <- FtpDayDirs[substr(FtpDayDirs, 1, 1)=='d'] 
		FtpDayDirs <- unlist(lapply(strsplit(FtpDayDirs, " "), function(x){x[length(x)]}))
		
	if (!createNew){
		FtpDayDirs <- matrix(FtpDayDirs) 
		mtr <- matrix(NA,ncol=ncol(ftpdirs),nrow=max(length(FtpDayDirs),dim(ftpdirs)[1])) # creates a matrix with maximum dim()
		colnames(mtr) <- colnames(ftpdirs)	
	
		for(j in 1:ncol(ftpdirs)){
			mtr[,j] <- replace(mtr[,j], 1:nrow(ftpdirs),ftpdirs[,j])
		}
		
		mtr[,which(names(ftpdirs)==todo[u])] <- replace(mtr[,which(names(ftpdirs)==todo[u])], 1:length(FtpDayDirs),FtpDayDirs) 
		ftpdirs <- mtr

	} else { # creates a new "ftpdir.txt"
		FtpDayDirs <- matrix(FtpDayDirs)
		mtr <- matrix(NA,ncol=ncol(ftpdirs)+1,nrow=max(length(FtpDayDirs),dim(ftpdirs)[1]))
		colnames(mtr) <- if(ncol(ftpdirs)>0){c(colnames(ftpdirs),todo[u])} else {todo[u]}	
			
		if (ncol(ftpdirs)!=0){ # relevant only for the first time
			for(j in 1:ncol(ftpdirs)){
				mtr[,j] <- replace(mtr[,j], 1:nrow(ftpdirs),ftpdirs[,j])
			}
		}
		mtr[,ncol(mtr)] <- replace(mtr[,ncol(mtr)], 1:length(FtpDayDirs),FtpDayDirs) 
		ftpdirs <- mtr
	}
}
}
}
write.table(ftpdirs,file.path(auxPATH,"ftpdir.txt",fsep="/"))
}



