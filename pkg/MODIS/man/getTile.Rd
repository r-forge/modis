\name{getTile}

\docType{methods}
\alias{getTile}
\alias{getTile,tileH,tileV,extent,buffer,system}

\title{Get MODIS tile id(s)}

\description{
Get MODIS tile id(s) for a geographic area.
}

\usage{getTile(tileH,tileV,extent,buffer=NULL,system="MODIS")}

\arguments{

  \item{tileH}{Integer. Horizontal tile number(s) (between 0 and 35). I.e.: \code{tileH = 19:25}}

  \item{tileV}{Integer. Vertical tile number(s) (between 0 and 17). I.e.: \code{tileV = 9:12}.}

  \item{extent}{Extent Informations see details.}
  
  \item{buffer}{Numeric [map units]. Buffers the extent, used only in combination with \code{extent}. \code{buffer=0.5} or \code{buffer=c(x,y)}. }

  \item{system}{Character. Default is \code{MODIS}. Alternative is the \code{MERIS} tiling system, (implemented but not tested!!) from culture-MERIS dataset. See \code{?genTile}!}
}

\details{
\code{extent}: \cr
If 'list': \code{myExtent <- list(xmin=mumeric, xmax=mumeric, ymax=mumeric, ymin=mumeric)}.\cr
If 'character', the country name from \code{mapdata}. \cr
Or one of the following objects \code{'extent','rasterLayer','rasterStack'} or \code{'rasterBrick'} from \code{package(raster)}.
}

\value{List}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHdf}}, raster package: \code{?extent,?raster,?stack} or \code{?brick}
}

\examples{
\dontrun{
# with tileH and tileV
getTile(tileH=18:19,tileV=4)

# with Extent of class 'list'
Austria <- list(ymin=46.12,ymax=49.3,xmin=9.2,xmax=17.47)
getTile(extent=Austria)
getTile(extent=Austria,buffer=10)
getTile(extent=Austria,buffer=c(0.5,10)) 

# with Extent or raster* object from raster package
require(raster)
# rasterObject
rasterObject <- raster(xmn=9.2,xmx=17.47,ymn=46.12,ymx=49.3)
getTile(extent=rasterObject)
# raster extent
ext <- extent(rasterObject)
getTile(extent=ext)

# require(mapdata)
# if you pass a character name to extent a standard call to 'map('worldHires',extent,plot=FALSE)' is performed.
# Use with caution! The following example includes much more areas than the main USA. Look at \code{map('worldHires','usa')} result.
# Maybe to detect the needed extent it helps to run: \code{map('worldHires','usa',plot=FALSE)$names} or to use the default low resolution map \code{map('usa')}

getTile(extent='usa')
getTile(extent=map('usa',plot=FALSE))
 
# so you better always check befor applying an extent of the class 'character' that defines a 'map' object
# if you want subsets or more detailed maps use ?map arguments 
ext <-  map('state', region = c('new york', 'new jersey', 'penn'))
getTile(extent=ext)
}
}


