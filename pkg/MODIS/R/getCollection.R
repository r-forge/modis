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

####
# checks for product
if (missing(product)){stop("Please provide a valid product")}
productN <- getProduct(x=product,quiet=TRUE)
if (is.null(productN)) {stop("Unknown product")}

# load aux
if (file.exists(file.path(auxPATH,"collections.txt",fsep="/"))) {
	ftpdirs <- read.table(file.path(auxPATH,"collections.txt",fsep="/"),stringsAsFactors=TRUE)
	} else {
	ftpdirs <- data.frame()
	}

if (forceCheck | sum(!productN$PRODUCT %in% colnames(ftpdirs))>0) {
	require(RCurl)
	#sturheit <- .stubborn(level=stubbornness)

	for (i in 1:length(unique(productN$PF1))) {		

		ftp <- paste("ftp://e4ftl01.cr.usgs.gov/",unique(productN$PF1)[i],"/",sep="")
		
		cat("Getting collections from FTP for platform:",unique(productN$PLATFORM)[i],"\n")
	
		if(exists("dirs")) {rm(dirs)}
		for (g in 1:sturheit){
			try(dirs <- getURL(ftp),silent=TRUE)
			if(exists("dirs")){break}
		} 
	
		if (!exists("dirs")) {
			cat("FTP is not available, using stored information from previous calls (this is mostly fine)\n")
		} else {
			
			dirs <- unlist(strsplit(dirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"})) # Is this enought? Mac? Solaris?....
			dirs <- dirs[substr(dirs, 1, 1)=='l'] 
			dirs <- sapply(strsplit(dirs, "/"), function(x){x[length(x)]})	
		
			prod <- sapply(dirs,function(x){strsplit(x, "\\.")[[1]][1]})
			coll <- sapply(dirs,function(x){strsplit(x, "\\.")[[1]][2]})
	
			mtr  <- cbind(prod,coll)
			mtr  <- tapply(INDEX=mtr[,1],X=mtr[,2],function(x){x})
	
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
ind <- which(colnames(ftpdirs)%in%productN$PRODUCT)
if (length(ind)==0) {stop("Data not available")}

res <- as.list(ftpdirs[,ind])
res <- lapply(res, function(x){x[!is.na(x)]})

if (!is.null(collection)) {
	
	isOk <- sprintf("%03d",as.numeric(collection)) %in% sprintf("%03d",as.numeric(res)) 

	if (isOk) { # if collection is providen...return formatted collection or 'FALSE'
		res <- sprintf("%03d",as.numeric(collection))
	} else {
		cat("The Collection you have specified doesn't exist. Try 'getCollection('",productN$request,"',newest=FALSE,forceCheck=TRUE)'\n",sep="")
		return(invisible(FALSE))
	}
	
} else if (newest) {
	if(!quiet) {cat("No Collection specified getting the newest for",productN$PRODUCT,"\n",sep=" ")}

	## oioioi! what a caos
	
res <- unlist(res)
########################### brocken!!!!!!!!!!!!!!!!!!!
size <- lapply(res,function(x){
			sapply(x,function(c){
			c <- nchar(c)-1
			if (c==0) {
				as.numeric(1)
			} else {
				as.numeric(paste(1,rep(0,c),sep=""))	
			}})})
for(u in 1:length(res)){
res[[u]]/size[[u]]
}	
	})
	res <- res / size
	or  <- apply(res,2,order)
	maxpos <- apply(or,2,function(x){which(x==max(x))})
	
	maxes <- list()
	for(u in 1:ncol(res)){
	zaza <- sprintf("%03d",res[maxpos[u],u]*size[maxpos[u],u])
	names(zaza) <- colnames(res)[u]
	maxes[[u]] <- zaza
	}
	res <- matrix(maxes,ncol=length(maxes))
	colnames(res) <- name
	
}
if (as=="character") {
	res <- matrix(sprintf("%03d",res),nrow=nrow(res),ncol=ncol(res),byrow=F)
	}

return(res)
}



