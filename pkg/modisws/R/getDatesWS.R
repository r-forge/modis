# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011

getDatesWS <- function(lat,long,product) {
	return(ornlMODISFuncs@functions$getdates(lat,long,product))
}






