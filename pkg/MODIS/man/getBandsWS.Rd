\name{getBandsWS}

\docType{methods}

\alias{getBandsWS}

\title{Get the bands of a specific MODIS product available via the MODIS webservice tool}

\description{
Get the bands of a specific MODIS product available via the MODIS webservice tool
}

\usage{getBandsWS(product = "MOD13Q1")}

\arguments{
  \item{product}{ A MODIS product available via the MODIS webservice}
}

\value{
	A list with the available MODIS bands for the MODIS product
}

\details{
Please see \url{http://daac.ornl.gov/MODIS/MODIS-menu/modis_webservice.html} for more details about the service.
}

\author{
  Jan Verbesselt
}

\examples{
	#	Please install the required packages
	# install.packages("SSOAP", repos = "http://www.omegahat.org/R", dependencies=TRUE, type="source")
	getProductsWS() ## first check products
	getBandsWS(product = "MOD13Q1") ## check bands of a product

}
