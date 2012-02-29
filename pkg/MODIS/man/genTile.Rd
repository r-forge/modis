\name{genTile}

\docType{methods}

\alias{genTile}
\alias{genTile,tileSize,offset}

\title{Generate tiling system}

\description{
This function generates bounding box information for a global tiling system
}

\usage{genTile(tileSize=1,offset=0)}

\arguments{

  \item{tileSize}{Numeric. Size of a single tile, in degree (Lat/Lon, WGS84)}

  \item{offset}{Numeric. Shift the tiling system in upper-left direction.}

}

\value{Matrix}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getTile}}
}

\examples{
\dontrun{
e1 <- genTile() # 1x1 degree tiling system.  
e2 <- genTile(tileSize=10,offset=(1/112)/2) # 10x10 degree tiling system with shift to be aligned to the Geoland2 (BioPar) Dataset (1km Pixelcenter reference)

head(e1)
head(e1)
}
}



