.onAttach <- function(lib, pkg){
  if (!require(SSOAP) | !require(XMLSchema)){
    packageStartupMessage("modisws NOT READY. You need to install the 'SSOAP' package: \n\tinstall.packages('SSOAP', repos = 'http://www.omegahat.org/R', dependencies=TRUE, type='source')")
  }else{
## SOAP client done at installing time for lazy loading
# Problems in case of offline intallation vs offline package loading
#     ## get the SOAP service
#     ornlMODIS<- processWSDL("http://daac.ornl.gov/cgi-bin/MODIS/GLBVIZ_1_Glb_subset/MODIS_webservice.wsdl")
# 
#     ## define the function set
#     ornlMODISFuncs<- genSOAPClientInterface(operations=ornlMODIS@operations[[1]], def=ornlMODIS)
    packageStartupMessage("modisws package ready!")
  }
}

