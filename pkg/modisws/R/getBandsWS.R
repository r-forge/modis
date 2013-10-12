# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011
# Licence GPL v3

getBandsWS <- function(product) {
	return(ornlMODISFuncs@functions$getbands(product))
}





