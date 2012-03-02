# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : February 2012
# Licence GPL v3

.genString <- function(x,local=TRUE,remote=TRUE,collection=NULL,what="images",localArcPath=.getDef('localArcPath')) {

	opts <- MODIS:::.getDef()
	localArcPath <- normalizePath(localArcPath,"/") # for windows
	
	if (missing(x)) {
		stop("'x' must be a file name or a product name!")
	}

	product <- getProduct(x=x,quiet=FALSE)

	if (length(product$DATE)==0){ # if x is an PRODUCT name DATE should not exist
		
		collection <- getCollection(product=product,collection=collection)
		
		if (collection!=FALSE) {
			product$CCC <- collection
		} else {
			stop("The collection you have specified doesn't exist") # little mor info would be good!
		}
		
		
		if (local) {
			struc <- opts$arcStruc
			tempString <- strsplit(struc,"/")[[1]]
			
			string <- list()
			l=0
			for (i in 1:length(tempString)){
	
				s <- strsplit(tempString[i],"\\.")[[1]]
			
				if (length(s)> 1) {
					tmp <- list()
					for (u in 1:length(s)){
						l=l+1
						if (s[u] %in% c("DATE","YYYY","DDD")) {
							tmp[[u]] <- s[u]
						} else {
							tmp[[u]] <- .getPart(x=product,s[u])
						}
					string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
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
				
				if (product$SENSOR %in% stringX$SENSOR & what %in% stringX$content) {
					struc      <- stringX$variablepath	
					tempString <- strsplit(struc,"/")[[1]]
				
					string <- list()
					l=0
					for (i in 1:length(tempString)){
				
						s <- strsplit(tempString[i],"\\.")[[1]]
				
						if (length(s)> 1) {
							l=l+1	
							tmp <- list()
							for (u in 1:length(s)){
								if (s[u] %in% c("DATE","YYYY","DDD")) {
									tmp[[u]] <- s[u]
								} else {
									tmp[[u]] <- .getPart(x=product,s[u])
								}
							}
						string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
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
			
		if (local) {
			struc <- opts$arcStruc
			tempString <- strsplit(struc,"/")[[1]]
		
			string <- list()
			l=0
			for (i in 1:length(tempString)){
		
				s <- strsplit(tempString[i],"\\.")[[1]]
				
				if (length(s)>0){
					l=l+1
					tmp <- list()
					for (u in 1:length(s)){
						tmp[[u]] <- MODIS:::.getPart(x=product,s[u])
					}
				string[[l]] <- paste(unlist(tmp),sep="",collapse=".")
				}
			}	
		localPath <- path.expand(paste(localArcPath,paste(unlist(string),sep="",collapse="/"),sep="/"))
		}

		if (remote) {
			if (!what %in% c("images","metadata")) {stop("the Parameter 'what' must be one of 'images' or 'metadata'")} 		
			namesFTP <- names(opts)
			Hmany <- grep(namesFTP,pattern="^ftpstring*.") # get ftpstrings in ./MODIS_opts.R
		
			remotePath <- list()
			n = 0
			for (e in Hmany){
			
				stringX <- opts[[e]]
				
				if (product$SENSOR %in% stringX$SENSOR & what %in% stringX$content) {
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
								tmp[[u]] <- MODIS:::.getPart(x=product,s[u])
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

