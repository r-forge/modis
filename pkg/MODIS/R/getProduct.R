# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3
	
getProduct <- function(x=NULL,quiet=FALSE) { # TODO improvement of automatic sensor detection!!!! 
	
	data(MODIS_Products)
    
	if (is.null(x)){ # if x isn't provided, return table of supported files.
		return(MODIS_Products[order(MODIS_Products$PRODUCT),c(1:3,6:9)])
	}

	if (is.list(x) && names(x) %in% c("request", "PRODUCT", "DATE", "TILE", "TILEV", "TILEH", "CCC", "PROCESSINGDATE", "FORMAT", "SENSOR", "PLATFORM", "PF1", "PF2", "TOPIC", "TYPE", "RES", "TEMP_RES", "INTERNALSEPARATOR")) {
		# if TRUE than it is a result from a getProduct() call. a good idea would be to have a CLASS for it!
		return(x)
	}
	## moody but seams to work!!
	inbase  <- basename(x) # if x is a filename(+path) remove the path
	if (substring(inbase,nchar(inbase)-2, nchar(inbase)) %in% c("hdf","xml","tif",".gz","tar","zip")) {
		isFile <- TRUE
		intSepTest <- c("\\.","_")[which(c(length(strsplit(inbase, "\\.")[[1]]),length(strsplit(inbase, "_")[[1]]))==max(c(length(strsplit(inbase, "\\.")[[1]]),length(strsplit(inbase, "_")[[1]]))))]
		product  <- strsplit(inbase,intSepTest)[[1]]
	} else {
		isFile <- FALSE
		product  <- inbase
	}
	
	product <- product[1]
	pattern <- sub(pattern="MXD", replacement="M.D", x=product,ignore.case=TRUE) # make a regEx out of "x" 	
	info    <- MODIS_Products[grep(pattern=pattern,x=MODIS_Products$PRODUCT,ignore.case=TRUE),]

	if(length(info)==0){
		stop("No product found with the name ",inbase," try 'getProduct()' to list available products.\n",sep = "")
	}
	if (info$SENSOR[1]=="MODIS") {
		info$PRODUCT <- toupper(info$PRODUCT)
	}
	
	
	if (isFile){ # in this case it must be a filename

#		if (intSepTest!=info$INTERNALSEPARATOR[1]) {
			fname <- unlist(strsplit(inbase,info$INTERNALSEPARATOR[1]))
			fname <- unlist(strsplit(fname,"\\."))
#		}

		if (info$SENSOR[1] == "MODIS") { # file TEST
			
			if (info$TYPE == "Tile") { # file check.
				Tpat    <- "h[0-3][0-9]v[0-1][0-9]"
				isok <- all((grep(fname[2],pattern=Tpat)) + (substr(fname[2],1,1) == "A") + (fname[6]=="hdf") + (length(fname)==6))
			
			} else if (info$TYPE == "CMG") {
				isok <- all((substr(fname[2],1,1) == "A") + (fname[5]=="hdf") + (length(fname)==5))
			
			} else if (info$TYPE == "Swath"){
				isok <- all((substr(fname[2],1,1) == "A") + (fname[6]=="hdf") + (length(fname)==6))
			} else {
				isok <- FALSE
			}
			if (!isok) stop("Check filename:", inbase,"\nIt seams to be not supported...if it should please send some feedback! matteo.mattiuzzi@boku.ac.at") 
				
			PD <- substr(info$PRODUCT[1], 4, nchar(as.character(info$PRODUCT[1])))
			  
			if (info$TYPE=="Tile") {
				names(fname) <- c("PRODUCT","DATE","TILE","CCC","PROCESSINGDATE","FORMAT")
			} else if (info$TYPE=="CMG") {
				names(fname) <- c("PRODUCT","DATE","CCC","PROCESSINGDATE","FORMAT")
				} else if (info$TYPE=="Swath") { 
				names(fname) <- c("PRODUCT","DATE","TIME","CCC","PROCESSINGDATE","FORMAT")
			} else {
				stop("Not a 'Tile', 'CMG' or 'Swath'! Product not supported. See: 'getProduct()'!")
			}
			request <- x
			names(request) <- "request"
			result <- c(request,fname,info)
			result <- result[!duplicated(names(result))]
			result <- as.list(sapply(result,function(x)as.character(x)))

			return(invisible(result))  
		  
    } else if (info$SENSOR[1] %in% c("MERIS","C-Band-RADAR")) {
    	return(invisible(list(request = as.character(info$PRODUCT), PF1 = NULL, PF2 = NULL, PD = NULL, PLATFORM = as.character(info$PLATFORM), TYPE = as.character(info$TYPE), PRODUCT = as.character(info$PRODUCT),SENSOR = as.character(info$SENSOR))))
    } 		
	} else { # if not a file
		if (!quiet) {
	   	for (i in 1:nrow(info)) {
	 	  	cat(paste(info$PRODUCT[i],'the',info$TEMP_RES[i],info$TYPE[i], info$TOPIC[i],'product from',info$SENSOR[i], info$PLATFORM[i],'with a ground resolution of', info$RES[i],'\n', sep = " "))
			}
		}

		if (info$SENSOR[1] == "MODIS") {
				
			PD <- substr(info$PRODUCT, 4, nchar(as.character(info$PRODUCT)))
	    return(invisible(list(request = inbase, PF1 = as.character(info$PF1), PF2 = as.character(info$PF2), PD = PD, PLATFORM = as.character(info$PLATFORM), TYPE = as.character(info$TYPE), PRODUCT = as.character(info$PRODUCT),SENSOR = as.character(info$SENSOR))))
    
  } else if (info$SENSOR[1] %in% c("MERIS","C-Band-RADAR")) {
  	return(invisible(list(request = as.character(info$PRODUCT), PF1 = NULL, PF2 = NULL, PD = NULL, PLATFORM = as.character(info$PLATFORM), TYPE = as.character(info$TYPE), PRODUCT = as.character(info$PRODUCT),SENSOR = as.character(info$SENSOR))))
	} 		
 }
}
##################################

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

			secName <- MODIS:::.defineName(y)
		
			if (product$SENSOR[1] == "MODIS") {
	
				if (product$TYPE[1] == "Tile") {
					Tpat    <- "h[0-3][0-9]v[0-1][0-9]" # to enhance
					return(all((grep(secName["TILE"],pattern=Tpat)) + (substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
			
				} else if (product$TYPE[1] == "CMG") {
						return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==5)))
			
				} else if (product$TYPE[1] == "Swath"){
						return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
				} else {
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

