
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
		file <- normalizePath(file,winslash="\\")
		FileSize <- as.numeric(shell(paste('for %I in ("',file,'") do @echo %~zI',sep=""),intern=TRUE))
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


.checkTools <- function(what=c("MRT","GDAL"),quiet=FALSE){
	
	MRT  <- NULL
	GDAL <- NULL
		
	if ("MRT" %in% what){
	
		MRT <- 0
		
		mrtH 	<- Sys.getenv("MRT_HOME")
		mrtDD <- Sys.getenv("MRT_DATA_DIR")
		
		if (!quiet){
			cat("Checking availabillity of MRT:\n")
		}
	
		if(mrtH=="") {
			if (!quiet){
				cat("  'MRT_HOME' not set/found! MRT is NOT enabled!\n")
			}
		} else {
			if (!quiet){
				cat("  'MRT_HOME' found:", mrtH,"\n")
			}
			if (mrtDD=="") {
				if (!quiet){
					cat("  'MRT_DATA_DIR' not set/found! MRT is NOT enabled!\n")
				}
			} else {
				if (!quiet){
					cat("  'MRT_DATA_DIR' found:",mrtDD,"\n")
					cat("   MRT enabled, settings are fine!\n")
				}
				MRT <- 1 
			}
		}

	}

	if ("GDAL" %in% what){

		GDAL <- 0

		if (.Platform$OS=="unix") {	
			if (!quiet){
				cat("Checking availabillity of GDAL:\n")
			}
			gdal <- try(system("gdalinfo --version",intern=TRUE),silent=TRUE)
			if (inherits(gdal,"try-error")){
				warning("   GDAL not found, install it or check path settings in order to use related functionalities!")
			} else {
				if (!quiet){
					cat("   OK,",gdal,"found!\n")
				}
				GDAL <- 1
			}	
		} else {
			if (!quiet){
				cat("Checking availabillity of FWTools (GDAL with HDF4 support for Windows):\n")	
			}
			gdal <- try(shell("gdalinfo --version",intern=TRUE),silent=TRUE)
			if (inherits(gdal,"try-error")|length(grep(x=gdal,pattern="FWTools"))==0){
				warning("   In order to enable GDAL-functionalities (HDF4 support) on windows you need to install 'FWTools'! You can get it from 'http://fwtools.maptools.org/'")
			} else {
				if (!quiet){
					cat("   OK,",gdal,"found!\n")
				}
				GDAL <- 1
			}
		}
	}
	return(invisible(list(GDAL=GDAL,MRT=MRT)))		
}


.isSupported <- function(x) {

	fname   <- basename(x)
	
	warn <- options("warn")
	options(warn=-1)
	on.exit(options(warn=warn$warn))
	
	res <- sapply(fname,function(y) {
	
		product <- getProduct(y,quiet=TRUE)
	
		if (is.null(product)){
			return(FALSE)
		} else {

			secName <- MODIS:::.defineName(product$request)
		
			if (product$SENSOR[1] == "MODIS") {
	
				if (product$TYPE[1] == "Tile") {
					Tpat    <- "h[0-3][0-9]v[0-1][0-9]" # to enhance
					return(all((grep(secName["TILE"],pattern=Tpat)) + (substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
			
				} else if (product$TYPE[1] == "CMG") {
						return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==5)))
			
				} else if (product$TYPE[1] == "Swath"){ # actually no support for Swath data!
#						return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
#				} else {
						return(FALSE)
				}
			} else {
				return(FALSE)
			}
		}
	})
return(unlist(res))
}

# TODO enhancement of SENSOR/PRODUCT detection capabilities! 
# the metods below are based on the results of the strsplit().

.defineName <- function(x) { # "x" is a MODIS,SRTM or culture-MERIS filename
	
	if(missing(x)) {
		stop("x is missing, must be a MODIS, SRTM or culture-MERIS filename!")
	} else {
	
	data(MODIS_Products)
	
	fname   <- basename(x)
	secName <- strsplit(fname,"\\.")[[1]] # for splitting with more signes "[._-]"
	
	if (toupper(substring(secName[1],1,4))=="CULT") {
		sensor="MERIS"
	} else if (tolower(substring(secName[1],1,4))=="srtm"){
		sensor = "C-Band-RADAR"
		secName <- strsplit(secName[1],"_")[[1]]
	} else {
		sensor="MODIS"
	}
	 # PROVISORIC

###################################
###################################
# date NAME definition (must be File-specific!)

# MODIS
	if (sensor=="MODIS"){

		product <- getProduct(x=secName[1],quiet=TRUE)
			if (product$TYPE=="Tile") {
				names(secName) <- c("PRODUCT","DATE","TILE","CCC","PROCESSINGDATE","FORMAT")
			} else if (product$TYPE=="CMG") {
				names(secName) <- c("PRODUCT","DATE","CCC","PROCESSINGDATE","FORMAT")
			} else if (product$TYPE=="Swath") { 
				names(secName) <- c("PRODUCT","DATE","TIME","CCC","PROCESSINGDATE","FORMAT")
			} else {
				stop("Not a 'Tile', 'CMG' or 'Swath'! Product not supported. See: 'getProduct()'!")
			}
#		}

# MERIS
    } else if (sensor=="MERIS") {
		
			product  <- getProduct(x="culture-MERIS",quiet=TRUE)
			secName  <- strsplit(fname,MODIS_Products[MODIS_Products$PRODUCT==product$PRODUCT,]$INTERNALSEPARATOR)[[1]]
			lastpart <- strsplit(secName[length(secName)],"\\.")[[1]]
			secName  <- secName[-length(secName)]
    	secName  <- c(secName,lastpart)
    
    	if (length(secName)==6) {
    		names(secName) <- c("PRODUCT","CCC","DATE1DATE2","TILE","FORMAT","COMPRESSION")
    	}else if (length(secName)==5) {
		   	names(secName) <- c("PRODUCT","CCC","DATE1DATE2","TILE","FORMAT")
    	}

# XXX
    } else if (sensor=="C-Band-RADAR") {
    		product  <- getProduct(x=secName[1],quiet=TRUE)
				secName  <- strsplit(fname,MODIS_Products[MODIS_Products$PRODUCT==product$PRODUCT,]$INTERNALSEPARATOR)[[1]]
				lastpart <- strsplit(secName[length(secName)],"\\.")[[1]]
				secName  <- secName[-length(secName)]
    		secName  <- c(secName,lastpart)
				names(secName) <- c("PRODUCT","tileH","tileV","COMPRESSION") 

    } # XXX else if ....
}
##
return(secName)
}


