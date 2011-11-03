\name{tiletable}
\alias{tiletable}
\docType{data}
\title{Sinusoidal Grid Bounding Coordinates of MODLAND Tiles}
\description{
Function \code{?getTILE} uses this information to get the tile id for any location (Lat/Lon)
}
\usage{data(tiletable)}
\format{
  A data frame with 648 observations on the following 6 variables.
  \describe{
    \item{\code{iv}}{a numeric vector of vertical tile number}
    \item{\code{ih}}{a numeric vector of horizontal tile number}
    \item{\code{lon_min}}{a numeric vector of western geographic coordinate}
    \item{\code{lon_max}}{a numeric vector of eastern geographic coordinate}
    \item{\code{lat_min}}{a numeric vector of southern geographic coordinate}
    \item{\code{lat_max}}{a numeric vector of northern geographic coordinate}
  }
}
\source{
\code{http://landdb1.nascom.nasa.gov/developers/sn_tiles/sn_bound_10deg.txt}
}
\examples{
data(tiletable)
## maybe str(tiletable) ; plot(tiletable) ...
}
\keyword{datasets}
