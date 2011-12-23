# Author: Jan Verbesselt, Jan.Verbesselt@wur.nl
# Date : December 2011

getDatesWS <- function(lat,long,product) {
	## get the SOAP service
	ornlMODIS = processWSDL("http://daac.ornl.gov/cgi-bin/MODIS/GLBVIZ_1_Glb_subset/MODIS_webservice.wsdl")
	## define the function set
	ornlMODISFuncs = genSOAPClientInterface(operations=ornlMODIS@operations[[1]], def=ornlMODIS)
	## get the products
	return(ornlMODISFuncs@functions$getdates(lat,long,product))
}






