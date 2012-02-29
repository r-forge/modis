# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3


getCollection <- function(product,collection=NULL,newest=TRUE,localArcPath=.getDef("localArcPath"),forceCheck=FALSE,as="character",stubbornness="high",quiet=TRUE){

localArcPath <- normalizePath(localArcPath,"/",mustWork=FALSE)
dir.create(localArcPath,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 

auxPATH <- file.path(localArcPath,".auxiliaries",fsep="/")
dir.create(auxPATH,showWarnings=FALSE)

# load aux
if (file.exists(file.path(auxPATH,"collections.txt",fsep="/"))) {
	ftpdirs <- read.table(file.path(auxPATH,"collections.txt",fsep="/"),stringsAsFactors=TRUE)
	} else {
	ftpdirs <- data.frame()
	}

productN <- getProduct(x=product,quiet=quiet)

for (i in 1:length(productN$PF1)){

	if (forceCheck | !productN$PRODUCT[i] %in% colnames(ftpdirs) ) {
		
		ftp <- paste("ftp://e4ftl01.cr.usgs.gov/",productN$PF1[i],"/",sep="")
		
		cat("Cecking data on FTP\n")
		require(RCurl)

		sturheit <- .stubborn(level=stubbornness)
		if(exists("dirs")) {rm(dirs)}
		for (g in 1:sturheit){
		try(dirs <- getURL(ftp),silent=TRUE)
		if(exists("dirs")){break}
		} 
		if (!exists("dirs")) {
			cat("FTP is not available, using stored information from previous calls (this is mostly fine)\n")
		} else {
		
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

	write.table(ftpdirs,file.path(auxPATH,"collections.txt",fsep="/"))
	}
	}
}	
ind <- which(colnames(ftpdirs)==productN$PRODUCT[i])

if (length(ind)==0) {stop("Data not available")}

res <- as.character(ftpdirs[!is.na(ftpdirs[,ind]),ind])

if (!is.null(collection)) {
	
	isOk <- sprintf("%03d",as.numeric(collection)) %in% sprintf("%03d",as.numeric(res)) 

	if (isOk) { # if collection is providen...return formatted collection or 'FALSE'
		res <- sprintf("%03d",as.numeric(collection))
	} else {
		res <- FALSE
	}
	
} else if (newest) {
	if(!quiet) {cat("No Collection specified getting the newest for ",as.character(productN$PRODUCT),"\n",sep="")}

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
if (as=="numeric") {res=as.numeric(res);if (sum(res,na.rm=TRUE)==0) {res <- FALSE}}
return(res)
}



