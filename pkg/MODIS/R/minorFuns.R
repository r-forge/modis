
# central setting for stubbornness 
.stubborn <- function(level="high"){
if (is.numeric(level)) {
	sturheit <- level	
	} else {
	sturheit <- c(5,50,100,1000,10000)[which(level==c("low","medium","high","veryhigh","extreme"))]
	}
}


file.size <- function(file,units="b"){
	if (.Platform$OS.type == "unix") {
		FileSize <- as.numeric(system(paste("stat -c %s ",file,sep=""), intern=TRUE))
	} else if (.Platform$OS.type == "windows") {
		FileSize <- as.numeric(shell(paste("for %I in (",file,") do @echo %~zI",sep=""),intern=TRUE))
	} else {
		stop("Only Unix/Linux and Windows supported, please tell me which system you use!")
	}
	uni <- c(1,1024,1024*1024,1024*1024*1024) 
	names(uni) <- toupper(c("b","Kb", "Mb", "Gb"))
	FileSize <- as.numeric(FileSize/uni[toupper(units)])
return(FileSize)
}


.checksizefun <- function(file,type="MODIS",SizeInfo=NULL,flexB=0){

	# determine reference size
	if (type=="MODIS"){ 
		require(XML)
		xmlfile  <- paste(file,".xml",sep="")
		xmlfile  <- xmlParse(xmlfile)
		MetaSize <- getNodeSet(xmlfile, "/GranuleMetaDataFile/GranuleURMetaData/DataFiles/DataFileContainer/FileSize" )
		MetaSize <- as.numeric(xmlValue(MetaSize[[1]])) # expected filesize
	} else {
		MetaSize <- as.numeric(SizeInfo[which(SizeInfo[,1]==basename(file)),2])
	}
	
	FileSize <- file.size(file)
	if (flexB!=0){
		isOK <- (MetaSize >= FileSize-flexB & MetaSize <= FileSize+flexB) 	
	} else {
		isOK <- (MetaSize == FileSize)
	}
	res  <- list(MetaSize,FileSize,isOK)	
	names(res) <- c("MetaSize","FileSize","isOK")
return(res)	
}


