# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3
	
getProduct <- function(x,quiet=FALSE) { # TODO improvement of automatic sensor detection!!!! 
	
	data(MODIS_Products)
    
    if (missing(x)){
	   	return(MODIS_Products[,c(1:3,6:9)])
  	}

	if (is.list(x) && names(x) %in% c("request","PF1","PF2","PLATFORM","PD","TYPE","PRODUCT","SENSOR")) { # if TRUE than it is a result from a getProduct() call. a good idea would be to have a CLASS "modisproduct"
		x <- x$request
	}

	if (!is.null(x)) {

		inbase  <- basename(x) # if x is a full filename(+path)
		fname   <- strsplit(inbase,"\\.")[[1]]
		if (!fname[length(fname)] %in% c("hdf","xml","tif","gz","tar")) {fname <- inbase}
		product <- toupper(fname[1])
		pattern <- sub(pattern="MXD", replacement="M.D", x=product) 
		
		if (length(grep(pattern=pattern,x=MODIS_Products$PRODUCT))>0){
			sensor="MODIS"
		} else if (substring(pattern,1,12) %in% c("CULTURE-MERI","CULTUREMERIS")) { # can be a file or a product name
			sensor="MERIS"
		} else {
			if(!quiet){
				cat("No product found with the name ",inbase," try 'getProduct()' to list available products.\n",sep = "")
			}
		return(invisible(NULL))
		}

		if (length(fname)>1){ # in this case it must be a filename
		
		    if (sensor == "MODIS") {
			
				ind  <- grep(pattern=pattern,x=MODIS_Products$PRODUCT)
				info <- MODIS_Products[ind,]
				
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
				if (!isok) stop("Check filename:", inbase,"\nIt seams to be not supported...if it should please send some feedback!") 
				
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
		  
    		} else if (sensor == "MERIS") {
    			infos  <- MODIS_Products[MODIS_Products$SENSOR==sensor,]
    		    return(invisible(list(request = as.character(infos$PRODUCT), PF1 = "", PF2 = "", PD = "", PLATFORM = as.character(infos$PLATFORM), TYPE = as.character(infos$TYPE), PRODUCT = as.character(infos$PRODUCT),SENSOR = as.character(infos$SENSOR))))
    		}
		} else if (length(fname)==1){

			if (sensor == "MODIS") {
		
				ind <- grep(pattern=pattern,x=MODIS_Products$PRODUCT)
				info <- MODIS_Products[ind,]
			
				if (!quiet) {
    		    	for (i in 1:length(ind)) {
    		    	    cat(paste(info$PRODUCT[i], ', the ', info$TEMP_RES[i],' ',info$TYPE[i],' ', info$TOPIC[i],' product from ',info$SENSOR[i],'-', info$PLATFORM[i],' with a ground resolution of ', info$RES[i], '\n', sep = ""))
					}
				}
		
				PD <- substr(info$PRODUCT, 4, nchar(as.character(info$PRODUCT)))
	       
	      	 return(invisible(list(request = inbase, PF1 = as.character(info$PF1), PF2 = as.character(info$PF2), PD = PD, PLATFORM = as.character(info$PLATFORM), TYPE = as.character(info$TYPE), PRODUCT = as.character(info$PRODUCT),SENSOR = sensor)))
    
			} else if (sensor == "MERIS") {
    			infos <- MODIS_Products[MODIS_Products$SENSOR==sensor,]
			return(invisible(list(request = as.character(infos$PRODUCT), PF1 = "", PF2 = "", PD = "", PLATFORM = as.character(infos$PLATFORM), TYPE = as.character(infos$TYPE), PRODUCT = as.character(infos$PRODUCT),SENSOR = as.character(infos$SENSOR))))
    		}
		}
	}
}
##################################

.isSupported <- function(x) {

	fname   <- basename(x)
	
	warn <- options("warn")
	options(warn=-1)
	
	res <- sapply(fname,function(y) {
	
		product <- getProduct(y,quiet=TRUE)
	
		if (is.null(product)){
			return(FALSE)
		} else {

		secName <- MODIS:::.defineName(y)
		
		if (product$SENSOR == "MODIS") {
	
			if (product$TYPE == "Tile") {
				Tpat    <- "h[0-3][0-9]v[0-1][0-9]" # to enhance
				return(all((grep(secName["TILE"],pattern=Tpat)) + (substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
	
			} else if (product$TYPE == "CMG") {
				return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==5)))
	
			} else if (product$TYPE == "Swath"){
				return(all((substr(secName["DATE"],1,1) == "A") + (length(secName)==6)))
			} else {
				return(FALSE)
			}
		} else {
			return(FALSE)
		}
		}
	})
	
options(warn=warn$warn)
return(unlist(res))
}

# TODO enhancement of SENSOR/PRODUCT detection capabilities! 
# the metods below are based on the results of the strsplit().

.defineName <- function(x) { # "x" is a MODIS or culture-MERIS filename
	
	if(missing(x)) {
		stop("x is missing, must be a MODIS or culture-MERIS filename!")
	} else {
	
	fname <- basename(x)
	secName <- strsplit(fname,"\\.")[[1]] # for splitting with more signes "[._-]"
	
	if (substring(secName[1],1,12)=="CULTUREMERIS") {sensor="MERIS"} else {sensor="MODIS"} # PROVISORIC

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
		
		data(MODIS_Products)
		product  <- getProduct(x="culture-MERIS",quiet=TRUE)
		secName  <- strsplit(fname,subset(MODIS_Products,PRODUCT==product$PRODUCT)$INTERNALSEPARATOR)[[1]]
		lastpart <- strsplit(secName[length(secName)],"\\.")[[1]]
		secName  <- secName[-length(secName)]
    	secName  <- c(secName,lastpart)
    
    	if (length(secName)==6) {
    		names(secName) <- c("PRODUCT","CCC","DATE1DATE2","TILE","FORMAT","COMPRESSION")
    	}else if (length(secName)==5) {
		   	names(secName) <- c("PRODUCT","CCC","DATE1DATE2","TILE","FORMAT")
    	}

# XXX
    } # else if (sensor=="XXX") {} ....
}
##
return(secName)
}

