# Author: Matteo Mattiuzzi, Anja Klisch, matteo.mattiuzzi@boku.ac.at
# Date : July 2011
# Licence GPL v3
  

getHdf <- function(HdfName,product,begin=NULL,end=NULL,tileH,tileV,extent,collection=NULL,dlmethod="auto",stubbornness="veryhigh",quiet=FALSE,wait=1,checkSize=FALSE,log=TRUE,localArcPath=.getDef("localArcPath")) {

localArcPath <- normalizePath(localArcPath,"/",mustWork=FALSE)
dir.create(localArcPath,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 

auxPATH <- file.path(localArcPath,".auxiliaries",fsep="/")

sturheit <- .stubborn(level=stubbornness)

# TODO HdfName as regex

if (!missing(HdfName)){ 

	HdfName <- unlist(HdfName)
	dates <- list()
	for (i in seq(along=HdfName)){
	
	fname <- basename(HdfName[i]) # separate name from path
	HdfName[i] <- fname
	rm(fname)

	product <- getProduct(x=HdfName[i],quiet=TRUE)		
	path    <- MODIS:::.genString(product)
	dir.create(path$localPath,recursive=TRUE,showWarnings=FALSE)
	
	if (!file.exists(paste(path$localPath,"/",HdfName[i],sep=""))) {

		for (x in 1:length(path$remotePath)){ # begins with the first ftp source...until subborness is reached, then it tries the nest available server
			if (!quiet) {cat("\n#####################\nTrying to get the file from",names(path$remotePath)[x],"server\n\n")}
			g=1
			while(g <= sturheit) {
		
				if (g==1){qi <- quiet} else { qi <- TRUE}
				hdf=1			
				try(hdf <- download.file(
					paste(path$remotePath[[x]],"/",HdfName[i],sep=""),
					destfile=paste(path$local,"/",HdfName[i],sep=""),
					mode='wb', method=dlmethod, quiet=qi, cacheOK=FALSE)
				)
				if (hdf!=0 & !quiet) {cat("Remote connection fail! Re-try:",g,"\r")} 
				if (hdf==0 & !quiet & g>1) {cat("Downloaded after:",g,"retries\n")}
				if (hdf==0 & !quiet & g==1) {cat("Downloaded by the first try!\n")}
				if (hdf==0) {break}	
				Sys.sleep(as.numeric(wait))
				g=g+1	
			}
			if(hdf==0) {break}	
		}
	}
		
	if(checkSize){
		g=1
		while(g <= sturheit) {
			if (g==1){qi <- quiet} else { qi <- TRUE}
			try(xml <- getXml(HdfName = HdfName[i],checkSize=TRUE,wait=wait,quiet=qi,dlmethod=dlmethod))
			if(sum(xml)==0) {break}
			g=g+1
		}
	}

dates[[i]] <- paste(path$local,"/",HdfName[i],sep="")
	}
return(invisible(unlist(dates)))

} else { # if HdfName isn't provided:

	if (is.null(begin)) {cat("No begin(-date) set, getting data from the beginning\n")} 
	if (is.null(end))   {cat("No end(-date) set, getting data up to the most actual\n")} 
	if (missing(product)){stop("Please provide the supported-'product'. See in: 'getProduct()'")}

	#######
	# check product
	product <- getProduct(x=product,quiet=TRUE)
	# check collection
	product$CCC <- getCollection(product=product,collection=collection,quiet=TRUE)
	#########
	# tranform dates
	tLimits <- transDate(begin=begin,end=end)
	#########
	# getStruc
	.getStruc(localArcPath=localArcPath,product=product,begin=tLimits$begin,end=tLimits$end,wait=0)

	ftpdirs <- list()
	ftpdirs[[1]] <- read.table(file.path(auxPATH,"LPDAAC_ftp.txt",fsep="/"),stringsAsFactors=FALSE)
	ftpdirs[[2]] <- read.table(file.path(auxPATH,"LAADS_ftp.txt",fsep="/"),stringsAsFactors=FALSE)

	dates  <- list()
	output <- list() # path info for the invisible output
	l=0
		
	for(z in 1:length(product$PRODUCT)){ # Platforms MOD/MYD

		todo <- paste(product$PRODUCT[z],".",product$CCC[[which(names(product$CCC)==product$PRODUCT[z])]],sep="")
		
		if (product$TYPE[z]=="Swath") {
			cat("'Swath'-products not yet supported, yumping to the next.\n")
		}else{

			# tileID
			if (product$TYPE[z]=="CMG") {
				tileID="GLOBAL"
				ntiles=1 
			} else {
				if (!missing(extent)) {
  					tileID <- getTile(extent=extent)$tile
 				 } else if (!missing(tileH) & !missing(tileV)) {
    				tileID <- getTile(tileH=tileH,tileV=tileV)$tile
 				 } else {stop("Please provide eighter a 'tileH' plus 'tileV' or an 'extent'")}
				ntiles <- length(tileID)
			}

			us <- lapply(ftpdirs,function(x){
					x <- as.Date(x,format="%Y.%m.%d")
					x <- sel >= tLimits$begin & x <= tLimits$end
			}) # convert to date
	
			if (sum(us[[1]],na.rm=TRUE)>0){ 

				dates[[z]] <- ftpdirs[us[[1]]]

				dates[[z]] <- cbind(dates[[z]],matrix(rep(NA, length(dates[[z]])*ntiles),ncol=ntiles,nrow=length(dates[[z]])))
				colnames(dates[[z]]) <- c("date",tileID)

				for (i in 1:nrow(dates[[z]])){
	
					year <- format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%Y")
					doy  <- as.integer(format(as.Date(dates[[z]][i,1],format="%Y.%m.%d"), "%j"))
					doy  <- sprintf("%03d",doy)
					datu <- paste("A",year,doy,sep="")
					mtr  <- rep(1,ntiles) # for file availability flaging

					# creates local directory (HDF file container)
					path <- MODIS:::.genString()
					arcPath <- paste(localArcPath,"/",product$PF2[z],product$PD,".",collection,"/",dates[[z]][i,1],"/",sep="")
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

	if(exists("ftpfiles")) {rm(ftpfiles)}
	require(RCurl)
	for (g in 1:sturheit){
		try(ftpfiles <- getURL(paste(ftp,dates[[z]][i,1],"/",sep="")),silent=TRUE)
		if(exists("ftpfiles")){break}
	}
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
			while(g <= sturheit) {
			
				if (g==1){qi <- quiet} else {qi <- TRUE}
				hdf=1
				try(hdf <- download.file(paste(ftp, dates[[z]][i,1], "/", HDF,sep=""),
					destfile=paste(arcPath, HDF, sep=""), mode='wb', method=dlmethod, quiet=qi, cacheOK=FALSE),silent=TRUE)
				if(hdf==0 & !quiet) {
					if (g==1) {
						cat("Downloaded by the first try!\n\n")
					} else {
						cat("Downloaded after",g,"retries!\n\n")
					}
				}
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
		dir.create(file.path(localArcPath,"LOGS",fsep="/"),showWarnings=FALSE)	
		write.csv(dates[[z]],file=file.path(localArcPath,"LOGS",paste(product$PF2[z],product$PD,".",collection,"_LOG.csv",sep=""),fsep="/"))
	}
	
	if(checkSize){
		g=1
		while(g <= sturheit) {
			if (g==1){qi <- quiet} else { qi <- TRUE}
			try(xmlIn <- getXml(HdfName = as.list(paste(arcPath,dates[[z]][i,-1],sep="")),wait=wait,quiet=qi,dlmethod=dlmethod),silent=TRUE)
		if(sum(xmlIn)==0) {break}
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
}
return(invisible(paste(unlist(output),sep="")))
} # end if not HdfName
} ## END: FTP vs ARC check and download 

