if (!require(SSOAP) | !require(XMLSchema)){
  message("modisws NOT READY. You need to install the 'SSOAP' package: \n\tinstall.packages('SSOAP', repos = 'http://www.omegahat.org/R', dependencies=TRUE, type='source')")
  # STOP: package not ready
}else{
  library(SSOAP)
  ## get the SOAP service
  ornlMODIS<- processWSDL("http://daac.ornl.gov/cgi-bin/MODIS/GLBVIZ_1_Glb_subset/MODIS_webservice.wsdl")

  ## define the function set
  ornlMODISFuncs<- genSOAPClientInterface(operations=ornlMODIS@operations[[1]], def=ornlMODIS)
  message("Package ready!")
}
