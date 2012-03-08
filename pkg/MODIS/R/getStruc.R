# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3


.getStruc <- function(product,server="LPDAAC",begin=NULL,end=NULL,forceCheck=FALSE,wait=1,localArcPath=.getDef("localArcPath")) {

server <- toupper(server)
if(!server %in% c("LPDAAC","LAADS")) {stop(".getStruc() Error! server must be or 'LPDAAC' or 'LAADS'")}

sturheit <- 10

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
if (file.exists(file.path(auxPATH,paste(server,"_ftp.txt",sep=""),fsep="/"))) {
	ftpdirs   <- read.table(file.path(auxPATH,paste(server,"_ftp.txt",sep=""),fsep="/"),stringsAsFactors=FALSE)
} else {
	ftpdirs   <- data.frame()
}

for (i in 1:length(product$PRODUCT)){

	todo <- paste(product$PRODUCT[i],".",product$CCC[[which(names(product$CCC)==product$PRODUCT[i])]],sep="")
	
	for(u in 1:length(todo)){
		
		path <- MODIS:::.genString(x=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],local=FALSE)
		
		if (server== "LPDAAC" | (server == "LAADS" & url.exists(strsplit(path$remotePath$LAADS,"YYYY")[[1]][1]))) {

			if (todo[u] %in% names(ftpdirs)) {
			
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
				getIT <- TRUE
			}
	
			if (getIT | forceCheck) {

				require(RCurl)	
				cat("Getting structure on ",server," for: ",todo[u],"\n",sep="")
		
				if(exists("FtpDayDirs")) {
					rm(FtpDayDirs)
				}
							
				if (server=="LPDAAC"){
					startPath <- strsplit(path$remotePath$LPDAAC,"DATE")[[1]][1] # cut away everything behind DATE
					for (g in 1:sturheit){
						cat("Try:",g,"\r")
						try(FtpDayDirs <- getURL(startPath),silent=TRUE)
						cat("             \r") 			
						Sys.sleep(wait)
						if(exists("FtpDayDirs")){	
							break
						}
					}
					if(!exists("FtpDayDirs")) {stop("Could not connect to LPDAAC server!")}
		
					FtpDayDirs <- unlist(strsplit(FtpDayDirs[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"}))
					FtpDayDirs <- FtpDayDirs[substr(FtpDayDirs, 1, 1)=='d'] 
					FtpDayDirs <- unlist(lapply(strsplit(FtpDayDirs, " "), function(x){x[length(x)]}))
		
				} else if (server=="LAADS"){
					startPath <- strsplit(path$remotePath$LAADS,"YYYY")[[1]][1] # cut away everything behind YYYY
		
					for (g in 1:sturheit){
						cat("Getting Year(s), try:",g,"\r")
						try(years <- getURL(startPath),silent=TRUE)
						cat("                            \r") 			
						Sys.sleep(wait)
						if(exists("years")){	
							break
						}
					}
					years <- unlist(strsplit(years[[1]], if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"}))
					years <- years[substr(years, 1, 1)=='d'] 
					years <- unlist(lapply(strsplit(years, " "), function(x){x[length(x)]}))
					Ypath <- paste(startPath,years,"/",sep="")

					for (g in 1:sturheit){
						cat("Getting day(s), try:",g,"\r")
						try(p <- getURL(Ypath),silent=TRUE) # async=T!
						cat("                          \r") 
						if(exists("p")){	
							break
						}
						if (g < sturheit) {
							Sys.sleep(wait)
						}
					}
					
					FtpDayDirs <- as.character(unlist(sapply(p, function(pb,l=0) {
						pb <- unlist(strsplit(pb, if(.Platform$OS.type=="unix"){"\n"}else{"\r\n"}))
						pb <- pb[substr(pb, 1, 1)=='d'] 
						pb <- unlist(lapply(strsplit(pb, " "), function(x){x[length(x)]}))
						l=l+1
						format(as.Date(as.numeric(pb) - 1, origin = paste(years[l],"-01-01", sep = "")), "%Y.%m.%d")
						})))
					if(!exists("FtpDayDirs")) {stop("Could not connect to LAADS server!")}
				
				rm(years,p)
				}
				
				rowdim <- max(nrow(ftpdirs),length(FtpDayDirs))
				if (todo[u] %in% names(ftpdirs)) { 
					coldim <- ncol(ftpdirs)
					colnam <- colnames(ftpdirs)
				} else {
					coldim <- ncol(ftpdirs) + 1
					colnam <- c(colnames(ftpdirs),todo[u])
				}
				
				mtr <- matrix(NA,ncol=coldim,nrow=rowdim)
				colnames(mtr) <- colnam	
				
				if (ncol(ftpdirs)>0){
					for(j in 1:(ncol(ftpdirs))){
						mtr[,j] <- replace(mtr[,j], 1:nrow(ftpdirs),ftpdirs[,j])
					}
				}
				mtr[,todo[u]] <- replace(mtr[,todo[u]], 1:length(FtpDayDirs),FtpDayDirs)
	
				ftpdirs <- mtr
				
				rm(FtpDayDirs)
		
				write.table(ftpdirs,file.path(auxPATH,paste(server,"_ftp.txt",sep=""),fsep="/"))
			}
		}
	}
}
}


