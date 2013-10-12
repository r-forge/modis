# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011

getModisWS <- function(lat, long, product, bandname, startdate, enddate, KmAboveBelow, KmLeftRight) {
	result<- ornlMODISFuncs@functions$getsubset(lat, long, product, bandname, startdate, enddate, KmAboveBelow, KmLeftRight)

	return(createbrickWS(result))
}
