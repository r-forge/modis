# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011

getModisWS <- function(lat, long, product, bandname, startdate, enddate, KmAboveBelow, KmLeftRight) {

	## get the SOAP service
	ornlMODIS = processWSDL("http://daac.ornl.gov/cgi-bin/MODIS/GLBVIZ_1_Glb_subset/MODIS_webservice.wsdl")
	## define the function set
	ornlMODISFuncs = genSOAPClientInterface(operations=ornlMODIS@operations[[1]], def=ornlMODIS)
	## get the data
	result = ornlMODISFuncs@functions$getsubset(lat, long, product, 
																							bandname, startdate, enddate, 
																							KmAboveBelow, KmLeftRight)
	return(createbrickWS(result))
}








