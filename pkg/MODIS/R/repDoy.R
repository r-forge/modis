# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3

 
repDoy <- function(pixX, layerDate = NULL, bias = 0)
{	

    if (is.null(layerDate))
    {
        layerDate <- extractDate(colnames(pixX),asDate=TRUE)    
    }	
	if (layerDate$asDate)
	{
	    layerDoy  <- format(layerDate$inputLayerDates,"%j")
        layerYear <- format(layerDate$inputLayerDates,"%Y")
	} else 
	{
	    layerDoy  <- substr(layerDate$inputLayerDates,5,7)
	    layerYear <- substr(layerDate$inputLayerDates,1,4)
	}

	if (is.matrix(pixX))
	{
    	pixX <- t(pixX)
	} else
	{
    	pixX <- as.matrix(pixX)
	}
	
	m1 <- pixX[ pixX <= 0 ]
	#layerDoy  <- matrix(layerDoy, ncol = ncol(pixX), nrow = nrow(pixX), byrow=FALSE)
	mask <- pixX - as.numeric(layerDoy)
    mask <- sign(mask)==-1
	
	ndays <- as.numeric(format(as.Date(paste(layerYear,"-12-31",sep="")),"%j"))
	bias1  <- matrix(ndays, ncol = ncol(pixX), nrow = nrow(pixX), byrow=FALSE)
	
	pixX[mask] <- pixX[mask] + bias1[mask]  
	
	ndays <- as.numeric(format(as.Date(paste(unique(layerYear),"-12-31",sep="")),"%j"))
    bias1  <- cumsum(ndays) - min(ndays)
	
	counter <- as.numeric(table(layerYear))
	
	biasN <- list()
	for(i in seq_along(counter))
	{
	    biasN[[i]] <- rep(bias1[i],counter[i])
	}
    bias1 <- unlist(biasN) - (as.numeric(format(min(layerDate$inputLayerDates),"%j"))-1)	
    bias1 <- matrix(bias1, ncol = ncol(pixX), nrow = nrow(pixX), byrow=FALSE)
		
	pixX <- pixX + bias1 + bias
	pixX[m1] <- NA
	return(t(pixX))
}
  
  
  
  
  
