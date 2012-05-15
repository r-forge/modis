\name{genTile}

\docType{methods}

\alias{genTile}
\alias{genTile,tileSize,offset}

\title{Generate tiling system}

\description{
This function generates a matrix with bounding box information for a global tiling system (based on Lat/Lon!). 
}

\usage{genTile(tileSize=10,offset=0,StartNameFrom=c(0,0),extent=list(xmin=-180,xmax=180,ymin=-90,ymax=90))}

\arguments{

  \item{tileSize}{Numeric. Size of a single tile, in degrees (Lat/Lon, WGS84)}

  \item{offset}{Numeric. Shift the tiling system in upper-left direction.}

  \item{offset}{Numeric. "c(Lat-Direction,Lon-Direction)" start number in the name of the tiles.}

  \item{offset}{list. Tile system Extent information.}  

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
e1 <- genTile(tileSize=1) # 1x1 degree tiling system.  
e2 <- genTile(offset=(1/112)/2) # 10x10 degree tiling system with shift to be aligned to the Geoland2 (BioPar) Dataset (1km Pixelcenter reference)

head(e1)
head(e1)
}
}



