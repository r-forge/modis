\name{getModisWS}

\docType{methods}

\alias{getModisWS}

\title{A R wrapper function to download MODIS data and convert it to a spatio-temporal raster brick filled with MODIS data}

\description{
A R wrapper function to download MODIS data and convert it to a spatio-temporal raster brick filled with MODIS data
}

\usage{getModisWS(lat, long, product, bandname, startdate, enddate, KmAboveBelow, KmLeftRight)}

\arguments{
	\item{lat}{ Latitude }
	\item{long}{ Longitude }
  \item{product}{ A MODIS product available via the MODIS webservice }
  \item{bandname}{ bandname }
	\item{startdate}{ start date }
  \item{enddate}{ end date }
  \item{KmAboveBelow}{ KmAboveBelow}
  \item{KmLeftRight}{ yes you know it also see MODIS webservice website for more info. }
}

\value{
	A brick filled with great fresh MODIS data from anywhere in the world :-)!
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
## get the data
b <- getModisWS(lat,long,"MOD13Q1", "250m_16_days_NDVI", "A2000049", "A2000097", 1, 1) # 1 km i.e. 9 by 9 pixel block
plot(b)

}
