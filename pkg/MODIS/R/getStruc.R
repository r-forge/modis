# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3


.getStruc <- function(localArcPath=.getDef("localArcPath"),product,collection=NULL,begin=NULL,end=NULL,wait=1) {


localArcPath <- paste(strsplit(localArcPath,"/")[[1]],collapse="/")# removes "/" or "\" on last position (if present)
dir.create(localArcPath,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly")} 

auxPATH <- file.path(localArcPath,".auxiliaries",fsep="/")
dir.create(auxPATH,showWarnings=FALSE)

# Check Platform and product
product <- getProduct(x=product)
#####
# Check collection
if (is.null(collection)) {
	collection <- getCollection(product=product)
	} else {
	collection <- sprintf("%03d",as.numeric(collection))
	if (getCollection(product=product,collection=collection)==FALSE) {stop(paste("The collection you have requested may doesn't exist run: 'getCollection(localArcPath='",localArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}
	}


# load aux
if (file.exists(file.path(auxPATH,"ftpdir.txt",fsep="/"))) {
	ftpdirs <- read.table(file.path(auxPATH,"ftpdir.txt",fsep="/"),stringsAsFactors=FALSE)
	} else {
	ftpdirs <- data.frame()
	}
	
data("MODIS_Products")
result   <- list()
resnames <- list()
for (i in 1:length(product$PF2)){
	
	productName <- product$PRODUCT[i]
	productNameFull <- paste(product$PRODUCT[i],".",collection,sep="")

	if (!paste(product$PF2[i],product$PD,sep="") %in% MODIS_Products$PRODUCT) {stop(product$PF2[i],product$PD," is an unkown product\n",sep="")}
	
		if (productNameFull %in% names(ftpdirs)) {
			createNew <- FALSE
			ind <- which(names(ftpdirs)==productNameFull)

			if (length(ftpdirs[,ind]) == 0 ) { # ...relevant for the first time only
				getIT <- TRUE
			} else {

				avDates <- as.Date(ftpdirs[,ind],format="%Y.%m.%d")
		
				if (!is.null(begin)){
					begin <- transDate(begin=begin)$begin
						if (is.na(begin)) {stop("\n'begin=",begin,"' is eighter wrong format (not:'YYYY.MM.DD') or an invalid date")}
					if (begin < min(avDates,na.rm=TRUE)) {
					getIT <- TRUE
					} else {
					getIT <- FALSE
					}
				} else {
					getIT <- TRUE
				}
	
				if (!is.null(end) & !getIT) {
					end <- transDate(end=end)$end 
						if (is.na(end)) {stop("\n'end=",end,"' is eighter wrong format (not:'YYYY.MM.DD') or an invalid date")}
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
		cat("Getting structure in:", ftp,"\n")	
		
		require(RCurl)
		
		if(exists("FtpDayDirs")) {rm(FtpDayDirs)}
		for (g in 1:MODIS:::.stubborn()){
		try(FtpDayDirs <- getURL(ftp),silent=TRUE)
		if(exists("FtpDayDirs")){break}
		} 
				
		if (wait > 0 && i < length(product$PF2)) {
			Sys.sleep(wait)
		}
	
		FtpDayDirs  <- unlist(strsplit(FtpDayDirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"})) # ok for Mac/Solaris?
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

res <- ftpdirs[,which(colnames(ftpdirs)==productNameFull)]
res <- res[!is.na(res)]
dates <- transDate(begin=begin,end=end)
begin <- gsub("-","\\.",dates$begin)
end   <- gsub("-","\\.",dates$end)

result[[i]] <- res[res >= begin & res <= end]

resnames[[i]] <- productNameFull
}
write.table(ftpdirs,file.path(auxPATH,"ftpdir.txt",fsep="/"))

names(result) <- resnames
invisible(result) 
}




