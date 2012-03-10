
# central setting for stubbornness 
.stubborn <- function(level="high"){
if (is.numeric(level)) {
	sturheit <- level	
	} else {
	sturheit <- c(5,50,100,1000,10000)[which(level==c("low","medium","high","veryhigh","extreme"))]
	}
}

.checksizefun <- function(HdfWithPath){
	require(XML)

	xmlfile  <- paste(HdfWithPath,".xml",sep="")
	xmlfile  <- xmlParse(xmlfile)
	MetaSize <- getNodeSet(xmlfile, "/GranuleMetaDataFile/GranuleURMetaData/DataFiles/DataFileContainer/FileSize" )
	MetaSize <- as.numeric(xmlValue(MetaSize[[1]])) # expected filesize
	
	if (.Platform$OS.type == "unix") {
		FileSize <- as.numeric(system(paste("stat -c %s ",HdfWithPath,sep=""), intern=TRUE))
	} else if (.Platform$OS.type == "windows") {
		FileSize <- as.numeric(shell(paste("for %I in (",HdfWithPath,") do @echo %~zI",sep=""),intern=TRUE))
	} else {
		stop("Only Unix/Linux and Windows supported, please tell me which system you use!")
	}

	isOK <- (MetaSize == FileSize)

	res  <- list(MetaSize,FileSize,isOK)	
	names(res) <- c("MetaSize","FileSize","isOK")
return(res)	
}


