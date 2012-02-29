# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : February 2012
# Licence GPL v3

.genString <- function(x,local=TRUE,remote=TRUE,collection=NULL,localArcPath=.getDef('localArcPath')) {

	opts <- MODIS:::.getDef()
	localArcPath <- path.expand(localArcPath)
	
	if (missing(x)) {
		stop("'x' must be a file name or a product name!")
	}

	x <- basename(x)
	product <- getProduct(x,quiet=TRUE)
	
	if (length(product)==1) {
		if(is.null(product)) {
			stop("'x' is not a valid 'product'")
		}
	}

	
	if (length(strsplit(x,"\\.")[[1]])==1){ # if x is an product name

		if (is.null(collection)) {
			product$CCC <- getCollection(product=product)
		} else {
			product$CCC <- getCollection(product,collection)
				if (product$CCC==FALSE) {stop(paste("The collection you have requested may doesn't exist, run: 'getCollection(localArcPath='",localArcPath,"',product='",product$request ,"',forceCheck=TRUE,newest=FALSE)' to update internal list and see available once!",sep=""))}
		}

		if (local) {
			struc <- opts$arcStructure
			tempString <- strsplit(struc,"/")[[1]]
			
			string <- list()
			for (i in 1:length(tempString)){
	
			s <- strsplit(tempString[i],"\\.")[[1]]
			
			if (length(s)> 1) {
				tmp <- list()
				
				for (u in 1:length(s)){
					if (s[u] %in% c("DATE","YYYY","DDD")) {
						tmp[[u]] <- s[u]
					} else {
						tmp[[u]] <- .getPart(product,s[u])[[1]]
					}
				}
			string[[i]] <- paste(unlist(tmp),sep="",collapse=".")
			}
			
			if  (length(s)==1) {
				if (s %in% c("DATE","YYYY","DDD")) {
					string[[i]] <- s 
				} else {
					string[[i]] <- .getPart(product,s) 
				}
			}
			}
		localPath <- path.expand(paste(localArcPath,paste(unlist(string),sep="",collapse="/"),sep="/"))
		}
		if (remote) {
		
			namesFTP <- names(opts)
			Hmany <- grep(namesFTP,pattern="^ftpstring*.")
		
			remotePath <- list()
			n = 0
			for (e in Hmany){
			
				stringX <- opts[[e]]
				
				if (product$SENSOR %in% stringX$SENSOR) {
					struc      <- stringX$variablepath	
					tempString <- strsplit(struc,"/")[[1]]
				
					string <- list()
					for (i in 1:length(tempString)){
				
						s <- strsplit(tempString[i],"\\.")[[1]]
				
						if (length(s)> 1) {
							
							tmp <- list()
							for (u in 1:length(s)){
								if (s[u] %in% c("DATE","YYYY","DDD")) {
									tmp[[u]] <- s[u]
								} else {
									tmp[[u]] <- .getPart(product,s[u])[[1]]
								}
							}
							string[[i]] <- paste(unlist(tmp),sep="",collapse=".")
						}
				
						if  (length(s)==1) {
							if (s %in% c("DATE","YYYY","DDD")) {
								string[[i]] <- s 
							} else {
								string[[i]] <- .getPart(product,s) 
							}
						}
					}
			n=n+1
			remotePath[[n]] <- path.expand(paste(stringX$basepath,paste(unlist(string),sep="",collapse="/"),sep="/"))
			names(remotePath)[n] <- stringX$name
				}
			}
		}
	return(list(localPath=if(local){localPath} else {NULL}, remotePath=if(remote){remotePath} else {NULL}))
	} else { # if x is a file name
	
		fname   <- MODIS:::.defineName(x) 
		product <- as.list(c(fname,unlist(product)))
				
		if (local) {
			struc <- opts$arcStructure
			tempString <- strsplit(struc,"/")[[1]]
		
			string <- list()
			l=0
			for (i in 1:length(tempString)){
		
				s <- strsplit(tempString[i],"\\.")[[1]]
				
				if (length(s)>0){
					l=l+1
					tmp <- list()
					for (u in 1:length(s)){
						tmp[[u]] <- MODIS:::.getPart(product,s[u])
					}
				string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
				}
			}	
		localPath <- path.expand(paste(localArcPath,paste(unlist(string),sep="",collapse="/"),sep="/"))
		}
	
		if (remote) {
		
			namesFTP <- names(opts)
			Hmany <- grep(namesFTP,pattern="^ftpstring*.") # extract ftpstring in ./MODIS_opts.R
		
			remotePath <- list()
			n = 0
			for (e in Hmany){
			
				stringX <- opts[[e]]
				
				if (product$SENSOR %in% stringX$SENSOR) {
					struc <- stringX$variablepath	
					tempString <- strsplit(struc,"/")[[1]]
				
					string <- list()
					l=0		
					for (i in 1:length(tempString)){
				
						s <- strsplit(tempString[i],"\\.")[[1]]
				
						if (length(s)>0){
							l=l+1
							tmp <- list()
							for (u in 1:length(s)){
								tmp[[u]] <- MODIS:::.getPart(product,s[u])
							}
						string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
						}
					}
			n=n+1
			remotePath[[n]]      <- path.expand(paste(stringX$basepath,paste(unlist(string),sep="",collapse="/"),sep="/"))
			names(remotePath)[n] <- stringX$name
				}
			}		
		}
	return(list(localPath=if(local){localPath} else {NULL}, remotePath=if(remote){remotePath} else {NULL}))
	}	
}	

