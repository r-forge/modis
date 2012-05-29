
# central setting for stubbornness 
.stubborn <- function(level="high"){
if (is.numeric(level)) {
	sturheit <- level	
	} else {
	sturheit <- c(5,50,100,1000,10000)[which(level==c("low","medium","high","veryhigh","extreme"))]
	}
}


.file.size <- function(file,units="b"){
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
	
		if (! require(XML) ) {
			stop("You need to install the 'XML' package: install.packages('XML')")
		}

		xmlfile  <- paste(file,".xml",sep="")
		xmlfile  <- xmlParse(xmlfile)
		MetaSize <- getNodeSet(xmlfile, "/GranuleMetaDataFile/GranuleURMetaData/DataFiles/DataFileContainer/FileSize" )
		MetaSize <- as.numeric(xmlValue(MetaSize[[1]])) # expected filesize
	} else {
		MetaSize <- as.numeric(SizeInfo[which(SizeInfo[,1]==basename(file)),2])
	}
	
	FileSize <- .file.size(file)
	if (flexB!=0){
		isOK <- (MetaSize >= FileSize-flexB & MetaSize <= FileSize+flexB) 	
	} else {
		isOK <- (MetaSize == FileSize)
	}
	res  <- list(MetaSize,FileSize,isOK)	
	names(res) <- c("MetaSize","FileSize","isOK")
return(res)	
}


search4map <- function(pattern="",database='worldHires',plot=FALSE){

	if (!require(mapdata)){
	stop("This function requires 'mapdata', please install it first: install.packages('mapdata')")
	}

	areas <- grep(x=map(database,plot=FALSE)$names,pattern=pattern,value=TRUE,ignore.case=TRUE)

	if (length(areas)==0){
		cat("No country (region or island) found! please change your pattern!\n")
		return(invisible(NULL))
	} else {

	if (plot){
		map(database,areas)
		map.axes() 
		box()
		grid(36,18,col="blue",lwd=0.5)
	
		if(length(areas)>4) {
			subareas <- paste(areas[1:3],collapse=", ") 
			title(c(paste(subareas,"and",(length(areas)-3),"other")))
		} else {
			title(areas)
		}
	}
	return(areas=areas)
	}
}


