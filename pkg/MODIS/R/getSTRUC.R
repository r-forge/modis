# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3


getSTRUC <- function(LocalArcPath,product,collection,startdate=NULL,enddate=NULL,wait=1) {

fsep <- .Platform$file.sep

if (missing(LocalArcPath)) {
	LocalArcPath <- normalizePath("~", winslash = fsep)
	LocalArcPath <- file.path(LocalArcPath,"MODIS_ARC",fsep=fsep)
} 
LocalArcPath <- paste(strsplit(LocalArcPath,fsep)[[1]],collapse=fsep)# removes "/" or "\" on last position (if present)
dir.create(LocalArcPath,showWarnings=FALSE)
# test local LocalArcPath
try(testDir <- list.dirs(LocalArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'LocalArcPath' not set properly")} 

auxPATH <- file.path(LocalArcPath,".auxiliaries",fsep=fsep)
dir.create(auxPATH,showWarnings=FALSE)

# Check Platform and product
product <- getPRODUCT(product=product)
#####
# Check collection
if (missing(collection)) {
	collection <- getCOLLECTION(product=product)
	} else {
	collection <- sprintf("%03d",as.numeric(collection))
	if (getCOLLECTION(product=product,collection=collection)==FALSE) {stop(paste("The collection you have requested may doesn't exist run: 'getCOLLECTION(LocalArcPath='",LocalArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}
	}


# load aux
if (file.exists(file.path(auxPATH,"ftpdir.txt",fsep=fsep))) {
	ftpdirs <- read.table(file.path(auxPATH,"ftpdir.txt",fsep=fsep),stringsAsFactors=FALSE)
	} else {
	ftpdirs <- data.frame()
	}
	
data("MODIS_Products")
result <- list()
resnames<-list()
for (i in 1:length(product$PF2)){
	
	productName <- product$productName[i]
	productNameFull <- paste(product$productName[i],".",collection,sep="")

	if (!paste(product$PF2[i],product$PD,sep="") %in% MODIS_Products[,1]) {stop(product$PF2[i],product$PD," is an unkown product\n",sep="")}
	
		if (productNameFull %in% names(ftpdirs)) {
			createNew <- FALSE
			ind <- which(names(ftpdirs)==productNameFull)

			if (length(ftpdirs[,ind]) == 0 ) { # ...relevant for the first time only
				getIT <- TRUE
			} else {

				avDates <- as.Date(ftpdirs[,ind],format="%Y.%m.%d")
		
				if (!is.null(startdate)){
					begin <- transDATE(begin=startdate)$begin
						if (is.na(begin)) {stop("\n'startdate=",startdate,"' is eighter wrong format (not:'YYYY.MM.DD') or an invalid date")}
					if (begin < min(avDates,na.rm=TRUE)) {
					getIT <- TRUE
					} else {
					getIT <- FALSE
					}
				} else {
					getIT <- TRUE
				}
	
				if (!is.null(enddate) & !getIT) {
					end <- transDATE(end=enddate)$end 
						if (is.na(end)) {stop("\n'enddate=",enddate,"' is eighter wrong format (not:'YYYY.MM.DD') or an invalid date")}
					if (end > max(avDates,na.rm=TRUE)) {
					getIT <- TRUE
					} else {
					getIT <- FALSE
					}
				} else {
					getIT <- TRUE
				}
			}
		} else {
			getIT <- TRUE
			createNew <- TRUE
		}


	if (getIT) { # the return is 'FtpDayDirs' of the requested product

		ftp <- paste("ftp://e4ftl01.cr.usgs.gov/",product$PF1[i],"/", productNameFull,"/",sep="")
#		ftp <- paste("ftp://e4ftl01u.ecs.nasa.gov/",product$PF1[i],"/", productNameFull,"/",sep="") # old ftp
		cat("Getting structure for:", ftp,"\n")	
		require(RCurl)
		FtpDayDirs  <- getURL(ftp)
	
			if (wait > 0 && i != length(product$PF2)) {
					Sys.sleep(wait)
					}
	
		FtpDayDirs  <- unlist(strsplit(FtpDayDirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"})) # Is this enought? Mac? Solaris?....
		FtpDayDirs  <- FtpDayDirs[substr(FtpDayDirs, 1, 1)=='d'] 
		FtpDayDirs  <- unlist(lapply(strsplit(FtpDayDirs, " "), function(x){x[length(x)]}))
		
		if (!createNew) {	
			FtpDayDirs <- matrix(FtpDayDirs)
			mtr <- matrix(NA,ncol=ncol(ftpdirs),nrow=max(length(FtpDayDirs),dim(ftpdirs)[1]))
			colnames(mtr) <- colnames(ftpdirs)	
		
			if (ncol(ftpdirs)!=0){
				for(j in 1:ncol(ftpdirs)){
					mtr[,j] <- replace(mtr[,j], 1:nrow(ftpdirs),ftpdirs[,j])
				}
			}
		
			mtr[,productNameFull] <- replace(mtr[,productNameFull], 1:length(FtpDayDirs),FtpDayDirs) 
			ftpdirs <- mtr
		}
		
	}


	if (createNew) { # creates the new ftpdir.txt
		FtpDayDirs <- matrix(FtpDayDirs)
		mtr <- matrix(NA,ncol=ncol(ftpdirs)+1,nrow=max(length(FtpDayDirs),dim(ftpdirs)[1]))
		colnames(mtr) <- if(ncol(ftpdirs)>0){c(colnames(ftpdirs),productNameFull)} else {productNameFull}	
			
			if (ncol(ftpdirs)!=0){ # relevant only for the first time
				for(j in 1:ncol(ftpdirs)){
					mtr[,j] <- replace(mtr[,j], 1:nrow(ftpdirs),ftpdirs[,j])
				}
			}
			
		mtr[,ncol(mtr)] <- replace(mtr[,ncol(mtr)], 1:length(FtpDayDirs),FtpDayDirs) 
		ftpdirs <- mtr
	}

res   <- ftpdirs[,which(colnames(ftpdirs)==productNameFull)]
begin <- gsub("-","\\.",begin)
end   <- gsub("-","\\.",end)

result[[i]] <- res[res >= begin & res <= end]

resnames[[i]] <- productNameFull
}
write.table(ftpdirs,file.path(auxPATH,"ftpdir.txt",fsep=fsep))

names(result) <- resnames
invisible(result) 
}




