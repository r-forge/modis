# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : February 2012
# Licence GPL v3

# TODO enhancement of SENSOR/PRODUCT detection capabilities! 
# the metods below are based on the results of the strsplit().

.defineName <- function(x) {
	
	if(missing(x)) {
		stop("x is missing, must be a MODIS/MERIS filename!")
	} else {
	data(MODIS_Products)
	
	fname <- basename(x)
	secName <- strsplit(fname,"\\.")[[1]] # for splitting with more signes "[._-]"
	
	if (substring(secName[1],1,12)=="CULTUREMERIS") {sensor="MERIS"} else {sensor="MODIS"} # PROVISORIC

###################################
###################################
# date NAME definition (must be File-specific!)

# MODIS
	if (sensor=="MODIS"){

		product <- getProduct(x=secName[1])
#		if (length(secName)==1 && secName[1] %in% MODIS_Products$PRODUCT){
#			secName <- product
#		} else {
			if (product$TYPE=="Tile") {
				names(secName) <- c("PRODUCT","DATE","TILE","CCC","PROCESSINGDATE","FORMAT")
			} else if (product$TYPE=="CMG") {
				names(secName) <- c("PRODUCT","DATE","CCC","PROCESSINGDATE","FORMAT")
			} else if (product$TYPE=="Swath") { 
				names(secName) <- c("PRODUCT","DATE","TIME","CCC","PROCESSINGDATE","FORMAT")
			} else {
				stop("Not a 'Tile' or 'CMG' what, product not yet supported!")
			}
#		}

# MERIS
    } else if (sensor=="MERIS") {
	
		product  <- getProduct(x="culture-MERIS")
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
################################
# getPATH takes as argument ONLY a .defineName() or a getProduct() result, or basicaly a vector with named "nodes"
################################
.getPart <- function(x , what = c("YYYY","DDD","DATE","SENSOR","PF1","PF2","PLATFORM","TILE","C","CCC","PRODUCT","FORMAT","COMPRESSION","DATE1DATE2","PROCESSINGDATE","REGION","TIME")){    
      if (missing(x)){return(cat("Available 'placeholders' are:",what,"\n",sep=" "))}
      
       what <- match.arg(what)
       switch(what,
              YYYY = substring(x["DATE"],2,5), # works with AYYYYDDD input
              DDD  = substring(x["DATE"],6,8), # works with AYYYYDDD input
              DATE = gsub(transDate(begin=substring(x["DATE"],2,8),)$begin,pattern="-",replacement="."), # works with AYYYYDDD input
              SENSOR = product$SENSOR,
              PF1 = getProduct(x=x[1])$PF1,
              PF2 = getProduct(x=x[1])$PF2,
              PLATFORM = getProduct(x=x[1])$PLATFORM,
              TILE = x["TILE"],
              C = as.numeric(x["CCC"]),
              CCC = x["CCC"],
              PRODUCT = x["PRODUCT"],
              FORMAT = x["FORMAT"],
              COMPRESSION = x["COMPRESSION"],
              DATE1DATE2 = x["DATE1DATE2"],
              PROCESSINGDATE = x["PROCESSINGDATE"],
              #REGION = getTILE(x["TILE"]) # TODO get REION by Tile
              REGION = "EuropeAfrica", # the only supported for now!
              TIME = x["TIME"]
              )
}

