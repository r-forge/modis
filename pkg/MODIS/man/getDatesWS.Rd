\name{getDatesWS}

\docType{methods}

\alias{getDatesWS}

\title{Get the available Dates of images at the a location for a specific MODIS product available via the MODIS webservice tool}

\description{
Get the available Dates of images at the a location for a specific MODIS product available via the MODIS webservice tool
}

\usage{getDatesWS(lat,long,product)}

\arguments{
	\item{lat}{ Latitude }
	\item{long}{ Longitude }
  \item{product}{ A MODIS product available via the MODIS webservice }
}

\value{
	A list with the available MODIS Dates!
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
#	getProductsWS() ## first check products
#	getBandsWS("MOD13Q1") ## check bands of a product
#	getDatesWS(40,-110, "MOD13Q1")
}
