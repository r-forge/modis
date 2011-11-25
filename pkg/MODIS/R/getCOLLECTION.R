# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3


getCOLLECTION <- function(LocalArcPath,product,collection,newest=TRUE,forceCheck=FALSE){

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

# load aux
if (file.exists(file.path(auxPATH,"collections.txt",fsep=fsep))) {
	ftpdirs <- read.table(file.path(auxPATH,"collections.txt",fsep=fsep),stringsAsFactors=TRUE)
	} else {
	ftpdirs <- data.frame()
	}

product <- getPRODUCT(product=product)

for (i in 1:length(product$PF1)){

	if (forceCheck | !product$productName[i] %in% colnames(ftpdirs) ) {

		ftp <- paste("ftp://e4ftl01.cr.usgs.gov/",product$PF1[i],"/",sep="")
		# ftp <- paste("ftp://e4ftl01u.ecs.nasa.gov/",product$PF1[i],"/",sep="")
		
	
		require(RCurl)
		dirs  <- getURL(ftp)
		dirs  <- unlist(strsplit(dirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"})) # Is this enought? Mac? Solaris?....
		dirs  <- dirs[substr(dirs, 1, 1)=='l'] 
		dirs  <- sapply(strsplit(dirs, "/"), function(x){x[length(x)]})	
	
		prod <- sapply(dirs,function(x){strsplit(x, "\\.")[[1]][1]})
		coll  <- sapply(dirs,function(x){strsplit(x, "\\.")[[1]][2]})

		mtr   <- cbind(prod,coll)
		mtr   <- tapply(INDEX=mtr[,1],X=mtr[,2],function(x){x})

		maxrow <- max(nrow(ftpdirs),sapply(mtr,function(x)length(x)))
		
		basemtr <- matrix(NA,ncol=nrow(mtr), nrow = maxrow)
		colnames(basemtr) <- names(mtr)

		for(u in 1:ncol(basemtr)) {
			basemtr[1:length(mtr[[u]]),u] <- mtr[[u]]
			}
		
		if (nrow(ftpdirs) < maxrow & nrow(ftpdirs) > 0) {
			ftpdirs <- rbind(ftpdirs,as.data.frame(NA,nrow=(maxrow-nrow(ftpdirs)), ncol=ncol(ftpdirs)))
			}
			
		if (ncol(ftpdirs)==0){ # relevant only for time
			ftpdirs <- data.frame(basemtr) # create new
		} else { # or update the available one
			indX    <- colnames(ftpdirs) %in% colnames(basemtr) 
			ftpdirs <- cbind(ftpdirs[,!indX],basemtr)

		}

	write.table(ftpdirs,file.path(auxPATH,"collections.txt",fsep=fsep))
	}
}	
ind <- which(colnames(ftpdirs)==product$productName[i])

res <- as.character(ftpdirs[!is.na(ftpdirs[,ind]),ind])

if (!missing(collection)) {
	res <- sprintf("%03d",as.numeric(collection)) %in% sprintf("%03d",as.numeric(res)) # if collection is providen...return TRUE or FALSE
} else if(newest) {
	res <- as.numeric(res)
	zeros <- sapply(nchar(res),function(x) {
			x<- x-1
			if (x==0) {
				as.numeric(1)
				} else {
				as.numeric(paste(1,rep(0,x),sep=""))	
				}
			})
	res <- res / zeros
	or  <- order(res)
	res <- res[which(or==max(or))]
	zeros <- zeros[which(or==max(or))]
	res <- res * zeros
	res <- sprintf("%03d",res)

} else {
	res <- sprintf("%03d",as.numeric(res))
}

return(res)
}



