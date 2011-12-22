\name{getProductsWS}

\docType{methods}

\alias{getProductsWS}

\title{Check the avalability of the MODIS products via the MODIS webservice tool}

\description{
	Check the avalability of the MODIS products via the MODIS webservice tool
	Please install the required packages
	# install.packages("SSOAP", repos = "http://www.omegahat.org/R", dependencies=TRUE, type="source")
	# install.packages("XML", repos = "http://www.omegahat.org/R", dependencies=TRUE, type="source")
	# install.packages("XMLSchema", repos = "http://www.omegahat.org/R", dependencies=TRUE, type="source")
	In to run this function!
}

\usage{getProductsWS()}

\arguments{

}

\value{
	A list with the available MODIS products
}

\author{
  Jan Verbesselt
}

\examples{
	getProductsWS()

}
