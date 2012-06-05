# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : July 2011
# Licence GPL v3

getXml <- function(HdfName,checkSize=TRUE,wait=1,dlmethod="auto",quiet=FALSE,stubbornness="extreme",localArcPath=.getDef('localArcPath')){

localArcPath <- paste(strsplit(localArcPath,"/")[[1]],collapse="/")# removes "/" or "\" on last position (if present)
dir.create(localArcPath,showWarnings=FALSE)
# test local localArcPath
try(testDir <- list.dirs(localArcPath,recursive=FALSE), silent=TRUE)
if(!exists("testDir")) {stop("'localArcPath' not set properly!")} 
#################

sturheit <- .stubborn(level=stubbornness)


if(!missing(HdfName)) {
	
	HdfName <- unlist(HdfName)
	avFiles <- list()
	
	for (i in seq(length(HdfName))){
		if (file.exists(HdfName[i])) { # if exists than HdfName is a path+File+itexists
			avFiles[[i]] <- HdfName[i] 
		} else {
			avFiles[[i]] <- list.files(localArcPath,pattern=HdfName[i],recursive=TRUE,full.names=TRUE)
			avFiles[[i]] <- grep(avFiles[[i]], pattern=".hdf$",value=TRUE) # no ".hdf.xml" files, only ".hdf" 
		}
	}
	 
avFiles <- unlist(avFiles)
} else {
avFiles <- list.files(localArcPath,pattern=".hdf$",recursive=TRUE,full.names=TRUE) # all hdf under 'localArcPath'
}
avFiles <- normalizePath(avFiles,winslash="\\")
data(MODIS_Products)
# tests if it is a MODIS-grid file(s) (TODO proper function that checks that)
doit <- MODIS:::.isSupported(avFiles)
avFiles <- avFiles[doit]


	if(length(avFiles)==0) {
		return(cat("No MODIS grid files found.\n"))
	} else {

	islocal <- rep(NA,length(avFiles))

	for (u in seq(along=avFiles)){

		product    <- getProduct(avFiles[u],quiet=TRUE)
		fdate      <- MODIS:::.getPart(product,"DATE")
		collection <- MODIS:::.getPart(product,"CCC")
		path       <- MODIS:::.genString(product)

		if (
			!file.exists(paste(avFiles[u],".xml",sep=""))
			|
			if (file.exists(paste(avFiles[u],".xml",sep=""))){ # check filesize of xml file! TODO  Needs improvement!!
				MODIS:::.file.size(paste(avFiles[u],".xml",sep="")) < 2000	
			} else {
				FALSE
			}
		) {
		
			for(g in 1:sturheit) {
				isin=1
				try(isin <- download.file( # get xml file !Avalable only on LPDAAC!
					paste(path$remotePath$LPDAAC,"/",basename(avFiles[u]),".xml",sep=""),
					destfile=paste(avFiles[u],".xml",sep=""),
					mode='wb', method=dlmethod, quiet=quiet, cacheOK=FALSE),
				silent=TRUE)
				if(isin==0) {break}
				isin=1
			}
			islocal[u] <- isin # xml file is local T/F
		} else {
			isin       <- 0
			islocal[u] <- 0 # xml file is local T
		}

		# XML based checksum for HDF files
		if (checkSize) {
			if (isin==1) {
				cat("'sizeCheck' not perfomed! It wasn't possible to download the xml file:\n",basename(avFiles[u]),".xml\n",sep="")
			} else {
				sizes <- .checksizefun(avFiles[u])
	
				if (!sizes$isOK) {
					if(!quiet){
						cat("Size Error detected: ",avFiles[u],"\nFileSize is ",sizes$FileSize,", but should be: ",sizes$MetaSize,"\n",sep="")
					}
			
					# get the hdf file if size fails
					for (g in 1:sturheit){
						server <- c("LAADS","LPDAAC")[g%%length(path$remotePath)+1]
						cat("Getting HDF file from:",server,"\n")
	
						hdf=1
						try(hdf <- download.file( ## hdf file
							paste(path$remotePath[[server]],"/",basename(avFiles[u]),sep=""),
							destfile=avFiles[u],
							mode='wb', method=dlmethod, quiet=quiet, cacheOK=FALSE)
						,silent=TRUE)
						if(hdf==0) {break}
					}
	
					sizes <- .checksizefun(avFiles[u])

					if (!sizes$isOK) {
						if(!quiet){
							cat("Still an Size Error detected: ",avFiles[u],"\nFileSize is ",sizes$FileSize,", but should be: ",sizes$MetaSize,"\n",sep="")
						}
					} else {
						if(!quiet){
							cat("Filesize ok for: ",avFiles[u], "\n")
						}		
					}
				} else {
					if(!quiet){
						cat("Filesize ok for: ",avFiles[u], "\n")
					}
				}
			}
		}
	}
invisible(islocal)
}
}

