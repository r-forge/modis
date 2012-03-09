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
	MODIS:::.getStruc(localArcPath=localArcPath,product=product,begin=tLimits$begin,end=tLimits$end,wait=0)
	#.getStruc(localArcPath=localArcPath,product=product,server="LAADS",begin=tLimits$begin,end=tLimits$end,wait=0)
	ftpdirs <- list()
	ftpdirs[[1]] <- read.table(file.path(auxPATH,"LPDAAC_ftp.txt",fsep="/"),stringsAsFactors=FALSE)
	#ftpdirs[[2]] <- read.table(file.path(auxPATH,"LAADS_ftp.txt",fsep="/"),stringsAsFactors=FALSE)

	dates  <- list()
	output <- list() # path info for the invisible output
	l=0
		
	for(z in 1:length(product$PRODUCT)){ # Platforms MOD/MYD

		if (product$TYPE[z]=="Swath") {
			cat("'Swath'-products not yet supported, yumping to the next.\n")
		}else{

			todo <- paste(product$PRODUCT[z],".",product$CCC[[which(names(product$CCC)==product$PRODUCT[z])]],sep="")
		
			for (u in 1:length(todo)){
		
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
	
				# us <- lapply(ftpdirs,function(x){
				#		x <- as.Date(x,format="%Y.%m.%d")
				#		x <- x >= tLimits$begin & x <= tLimits$end
				# }) # convert to date
				
				datedirs <- ftpdirs[[1]][,todo[u]]
				datedirs <- datedirs[!is.na(datedirs)]			
				sel <- as.Date(datedirs,format="%Y.%m.%d")
				us  <- sel >= tLimits$begin & sel <= tLimits$end
				
				if (sum(us,na.rm=TRUE)>0){ 
				
					l=l+1

					
					dates[[l]] <- datedirs[us]

					dates[[l]] <- cbind(dates[[l]],matrix(rep(NA, length(dates[[l]])*ntiles),ncol=ntiles,nrow=length(dates[[l]])))
					colnames(dates[[l]]) <- c("date",tileID)

					for (i in 1:nrow(dates[[l]])){
	
						year <- format(as.Date(dates[[l]][i,1],format="%Y.%m.%d"), "%Y")
						doy  <- as.integer(format(as.Date(dates[[l]][i,1],format="%Y.%m.%d"), "%j"))
						doy  <- sprintf("%03d",doy)
						datu <- paste("A",year,doy,sep="")
						mtr  <- rep(1,ntiles) # for file availability flaging
	
						# creates local directory (HDF file container)
						path <- MODIS:::.genString(x=strsplit(todo[u],"\\.")[[1]][1],collection=strsplit(todo[u],"\\.")[[1]][2],date=dates[[l]][i,1])
	
						for(j in 1:ntiles){
	
							dates[[l]][i,j+1] <- paste(product$PF2[z],product$PD,".",datu,".",if (tileID[j]!="GLOBAL") {paste(tileID[j],".",sep="")},collection,".*.hdf$",sep="") # create pattern
		
								if (length(dir(path$localPath,pattern=dates[[l]][i,j+1]))>0){ # if available locally
			
									HDF <- dir(path$localPath,pattern=dates[[l]][i,j+1])  # extract HDF file
			
									if (length(HDF)>1) { # in very recent files sometimes there is more than 1 file/tile/date if so get the last
										select <- list()
										for (d in 1:length(HDF)){ 
											select[[d]]<- strsplit(HDF[d],"\\.")[[1]][5]
										}
										HDF <- HDF[which.max(unlist(select))]		
									}
									dates[[l]][i,j+1] <- HDF
									mtr[j] <- 0
								}
						}

						if (sum(mtr)!=0) { # if one or more of the tiles in date is missing, its necessary to go on ftp

							if(exists("ftpfiles")) {rm(ftpfiles)}
							require(RCurl) # get the filenames
							
							for (g in 1:sturheit){ # get list of files in remote dir
								try(ftpfiles <- getURL(paste(path$remotePath[[(g%%length(path$remotePath))+1]],"/",sep="")),silent=TRUE)
								if(exists("ftpfiles")){break}
								Sys.sleep(as.numeric(wait))
							}
							if(!exists("ftpfiles")) {stop("Problems with FTP connections try a little later")} # This breaks the entire job! it schouldn't, better to jump to the next file...may it is local!
			
							ftpfiles <- strsplit(ftpfiles, if(.Platform$OS.type=="unix"){"\n"} else{"\r\n"})[[1]]
	
							if (ftpfiles[1] != "total 0") {
	    
								ftpfiles <- unlist(lapply(strsplit(ftpfiles," "),function(x){x[length(x)]})) # found empty dir!
		
								for(j in 1:ntiles){
				
									if(mtr[j]==1){ # if tile is missing get it
										onFtp <- grep(ftpfiles,pattern=dates[[l]][i,j+1],value=TRUE)
										HDF   <- grep(onFtp,pattern=".hdf$",value=TRUE)
		
										if(length(HDF)>0){
					
											if (length(HDF)>1) { # in very recent files sometimes there is more than 1 file/tile/date if so get the last
												select <- list()
												for (d in 1:length(HDF)){
													select[[d]] <- strsplit(HDF[d],"\\.")[[1]][5]
												}
												HDF <- HDF[which.max(unlist(select))]		
											}
											dates[[l]][i,j+1] <- HDF

											for(g in 1:sturheit) {
												server <- c("LAADS","LPDAAC")[g%%length(path$remotePath)+1]
												cat("Getting file from:",server,"\n")
												hdf=1
												try(hdf <- download.file(
													paste(path$remotePath[[(g%%length(path$remotePath))+1]],"/", HDF,sep=""),
													destfile=paste(path$localPath,"/", HDF, sep=""),
													mode='wb', method=dlmethod, quiet=quiet, cacheOK=FALSE),
												silent=TRUE)
												if(hdf==0 & !quiet) {
													if (g==1) {
														cat("Downloaded by the first try!\n\n")
													} else {
														cat("Downloaded after",g,"retries!\n\n")
													}
												}
												if(hdf==0) {break}
											}
					
											mtr[j] <- hdf
											Sys.sleep(as.numeric(wait))
										} else { 
											dates[[l]][i,j+1] <- "No tile for location" 
										}
									} # if mtr==1
								}
							} else {
								dates[[l]][i,(j+1):ncol(dates[[l]])] <- "No files for that date on FTP"
							} # on ftp is possible to find empty folders!
						}
					}
					if (log) {
						dir.create(file.path(localArcPath,"LOGS",fsep="/"),showWarnings=FALSE)	
						write.csv(dates[[l]],file=file.path(localArcPath,"LOGS",paste(todo[u],"_LOG.csv",sep=""),fsep="/"))
					}
		
					if(checkSize){
						for (g in 1:sturheit){ 
							try(xmlIn <- getXml(HdfName = as.list(paste(path$localPath,"/",dates[[l]]		[i,-1],sep="")),wait=wait,quiet=qi,dlmethod=dlmethod),silent=TRUE)
							if(sum(xmlIn)==0) {break}
						}
					}
					output[[l]] <- paste(path$localPath,"/",grep(dates[[l]][i,-1],pattern=".hdf$",value=TRUE),sep="")
					names(output)[l] <- todo[u]
				} else {
					cat(paste("No files on ftp in date range for: ",todo[u],"\n\n",sep=""))
				}
			} 
		}
	}
	return(invisible(output))
} 
} ## END: FTP vs ARC check and download 

