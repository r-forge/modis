# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3
	
getProduct <- function(x,quiet=TRUE) { # TODO improvement of automatic sensor detection!!!! 
	
	data(MODIS_Products)
    
    if (missing(x)){
	   	return(MODIS_Products[,c(1:3,6:9)])
  	}

	if (is.list(x) && names(x) %in% c("request","PF1","PF2","PLATFORM","PD","TYPE","PRODUCT","SENSOR")) { # if TRUE than it is a result from a getProduct call.
		x <- x$request
	}

	if (!is.null(x)) {
	x     <- basename(x) # if x is a full filename(+path)
	inVar <- x
	x <- strsplit(x,"\\.")[[1]][1]		
    x <- toupper(x)
	x <- sub(pattern="MXD", replacement="M.D", x=x)
	
	if (length(grep(pattern=x,x=MODIS_Products$PRODUCT))>0){
		sensor="MODIS"
	} else if (substring(x,1,12) %in% c("CULTURE-MERI","CULTUREMERIS")) { # can be a file or a product name
		sensor="MERIS"
	} else {
		stop("No product found with the name ",inVar,"try 'getProduct()' to list available products",sep = "")
	}
	
    if (sensor == "MODIS") {
		
		ind <- grep(pattern=x,x=MODIS_Products$PRODUCT)
		info <- MODIS_Products[ind,]
		
		if (!quiet) {
        	for (i in 1:length(ind)) {
				if (i > 1) {
					cat("and\n")
				}
        	           cat(paste('You are looking for ', info$PRODUCT[i], ', the ', info$TEMP_RES[i],' ', info$TOPIC[i],' ',info$TYPE[i],' product from ',info$SENSOR[i],'-', info$PLATFORM[i],' with a ground resolution of ', info$RES[i], '\n', sep = ""))
			}
		}
		
#        warn <- options("warn")
 #       options("warn"=-1)
  #      for (l in 1:nchar(x)){ # detect position of the first numeric value in x (ie: "MOD13Q1"== 4) 
   #     st <- !is.na(as.numeric(substr(x,l,l)))
    #    if(st){break}
     #   }
      #  options("warn"=unlist(warn))
       # PD <- substr(x, l, nchar(x))
		PD <- substr(info$PRODUCT[1], 4, nchar(as.character(info$PRODUCT[1])))
	       
        return(list(request = inVar, PF1 = info$PF1, PF2 = info$PF2, PD = PD, PLATFORM = info$PLATFORM, TYPE = info$TYPE[1], PRODUCT = info$PRODUCT,SENSOR = sensor))
    
    } else if (sensor == "MERIS") {
    	infos <- MODIS_Products[MODIS_Products$SENSOR==sensor,]
        return(list(request = infos$PRODUCT, PF1 = "", PF2 = "", PD = "", PLATFORM = infos$PLATFORM, TYPE = infos$TYPE, PRODUCT = infos$PRODUCT,SENSOR = infos$SENSOR))
    }
	} else { 
		stop("Input product 'NULL', something is wrong!")
	}
}

##################################

.isSupported <- function(x) {

	fname   <- basename(x)
	
	warn <- options("warn")
	options(warn=-1)
	
	res <- sapply(fname,function(x) {
	
		# product <- getProduct(fname,quiet=TRUE)
	
		if (is.null(product)){
			return(FALSE)
		} else {

		secName <- MODIS:::.defineName(fname)
	
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
