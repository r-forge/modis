\name{getProductsWS}

\docType{methods}

\alias{getProductsWS}

\title{Check the avalability of the MODIS products via the MODIS webservice tool}

\description{
	Check the avalability of the MODIS products via the MODIS webservice tool.
	Please install the required packages
	# install.packages("SSOAP", repos = "http://www.omegahat.org/R", dependencies=TRUE, type="source")
	to run this function!
}

\usage{getProductsWS()}

\value{
	A list with the available MODIS products
}

\author{
  Jan Verbesselt
}

\examples{
\dontrun{
	#	Please install the required packages
	# install.packages("SSOAP", repos = "http://www.omegahat.org/R", dependencies=TRUE, type="source")
	# getProductsWS()
}
}
