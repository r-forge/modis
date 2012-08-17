# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3

repDoy <- function(pixX,layerDate)
{	
	inX <- which(substr(layerDate,5,7)==361)
	msk <- (pixX[,inX] < 361)*365
	msk <-  pixX[,inX] + msk
	pixX[,inX] <- msk
	
	inX <- which(substr(layerDate,5,7)==353)
	msk <- (pixX[,inX] < 353)*365
	msk <-  pixX[,inX] + msk
	pixX[,inX] <- msk

	period <- as.numeric(unique(substring(layerDate,1,4)))
	zz <- 0
	for(h in period){ # adjust year offset
		inX <- which(substr(layerDate,1,4)==h)
		pixX[,inX] <- pixX[,inX] + (zz*365)
		zz <- zz+1
	}

	pixX <- (pixX + 1)- as.numeric(substr(min(layerDate),5,7)) 

	pixX[pixX<=0] <- NA
    return(pixX)
}
  
