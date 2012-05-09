\name{tiletable}
\alias{tiletable}
\docType{data}
\title{Sinusoidal Grid Bounding Coordinates of MODLAND Tiles}
\description{
Function \code{?getTile} uses this information to get the tile id for any location (Lat/Lon)
}
\usage{data(tiletable)}
\format{
  A data frame with 648 observations on the following 6 variables.
  \describe{
    \item{\code{iv}}{a numeric vector of vertical tile number}
    \item{\code{ih}}{a numeric vector of horizontal tile number}
    \item{\code{xmin}}{a numeric vector of western geographic coordinate}
    \item{\code{xmax}}{a numeric vector of eastern geographic coordinate}
    \item{\code{ymin}}{a numeric vector of southern geographic coordinate}
    \item{\code{ymax}}{a numeric vector of northern geographic coordinate}
  }
}
\source{
\code{http://landdb1.nascom.nasa.gov/developers/sn_tiles/sn_bound_10deg.txt}
}
\examples{
data(tiletable)
tiletable[160:170,]
}
\keyword{datasets}
