# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2011
# Licence GPL v3

getPRODUCT <- function(product,sensor="MODIS",quiet=TRUE){

if (sensor=="MODIS"){
# if product is already a result of getPRODUCT turn it back to the original request.
if (is.list(product) && names(product) %in% c("request","PF1","PF2","PD","raster_type","productName")) { # matching with class should be done here!
	product <- product$request
	} 

product <- toupper(product)
# Check Platform and product
PF <- substr(product,1,3)

if        (PF == "MXD") { PF1  <- c("MOLT", "MOLA"); PF2  <- c("MOD", "MYD") 
} else if (PF == "MYD") { PF1  <- "MOLA"; PF2 <- "MYD"
} else if (PF == "MOD") { PF1  <- "MOLT"; PF2 <- "MOD"
} else if (PF == "MCD") { PF1  <- "MOTA"; PF2 <- "MCD"
} else {stop("Check 'product', the platform specific part seams wrong.\n",PF,"is not one of 'MOD','MYD','MXD','MCD'.")
}

# Check product
PD <- substr(product,4,nchar(product)) #'09Q1',...
#####

data("MODIS_Products")

productName <- list()
# vality check and information
for (i in 1:length(PF2)){

	if (length(grep(MODIS_Products[,1],pattern=paste("^",PF2[i],PD,"$",sep="")))==1) {
	ind <- grep(MODIS_Products[,1],pattern=paste("^",PF2[i],PD,"$",sep=""))
	productName[[i]] <- MODIS_Products[ind,1]
	
if(as.character(MODIS_Products[ind,4])=="Swath"){stop(paste("You are looking for a '",as.character(MODIS_Products[ind,4]),"' product, only 'Grid' data is supported yet!",sep=""))
		} else { 
			if (!quiet){
				if(i == 1){cat("\n")} else {cat("and\n")}
			cat(paste("You are looking for ", as.character(MODIS_Products[ind,1]),", the ",as.character(MODIS_Products[ind,6])," ",as.character(MODIS_Products[ind,3])," product from ",as.character(MODIS_Products[ind,2])," with a ground resolution of ",as.character(MODIS_Products[ind,5]),"\n",sep=""))
			}
		}
	} else {
	cat(paste("No product found with the name ",PF2[i],PD,"\n",sep=""))}
}
if (!quiet){cat("\n")}
invisible(list(request=product,PF1 = PF1, PF2 = PF2,PD = PD,raster_type = "Tile",productName =  as.character(unlist(productName)),sensor=sensor))

} else if (sensor=="MERIS") {

invisible(list(sensor=sensor))

}
}


