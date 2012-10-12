\name{getTile}

\docType{methods}
\alias{getTile}

\title{Get MODIS tile id(s)}

\description{Get MODIS tile id(s) for a geographic area.}

\usage{getTile(extent=NULL, tileH=NULL, tileV=NULL, buffer=NULL, system="MODIS", zoom=TRUE)}

\arguments{

  \item{tileH}{Integer. Horizontal tile number(s) (between 0 and 35). I.e.: \code{tileH = 19:25}}

  \item{tileV}{Integer. Vertical tile number(s) (between 0 and 17). I.e.: \code{tileV = 9:12}.}

  \item{extent}{Extent Informations see details.}
  
  \item{buffer}{Numeric [map units]. Buffers the extent, negative values are allowed. If \code{extent} is a vector object ("shp" or _"character"_ name of a "map" object) only 1 value is allowed i.e. \code{buffer=0.5} (rgeos:::gBuffer() is used). In the other cases also \code{buffer=c(x,y)} _can_ be specified.}

  \item{system}{Character. Default is \code{MODIS}. Alternative is the \code{SRTM} tiling system!}
  \item{zoom}{Logical, default \code{TRUE}. The interactive mode is only activated if no other extent arguments ("extent","tileH", "tileV") are specified. If \code{zoom==TRUE} the first 2 clicks on the map are defining the zoom-in area, and the next 2 clicks the download area. For large areas you can set to \code{FALSE}.}  

}

\details{
\code{extent}: 
\cr

If "list":\cr Then LatLon coordinates in the following form:\cr 
\code{list(xmin=mumeric, xmax=mumeric, ymax=mumeric, ymin=mumeric)}.\cr
\cr
If "character":\cr
- the country name of a \code{map} object (see package \code{maps})\cr
- the file name of a raster or a ESRI Shapefile (shp).\cr
\cr
One of the following "R-objects":\cr
- Package raster: \code{"extent","rasterLayer","rasterStack"} or \code{"rasterBrick"}.\cr
Using a raster object (not "extent"!), and if not specified otherwise, the "extent", "pixelsize", and the "projection" of the raster object is used as output arguments \code{"extent","pixelSize","outProj"}. (if not LatLon it requires a valid CRS string!)\cr
If ESRI shapefile (shp) or \code{maps:::map} object, a call to ?sp:::over is performed to determine MODIS tile containg the "extent", this often reduces the number of required MODIS tiles considerably but leads to NO-DATA areas outside the specified "extent" in the result! 
\cr
\cr
\code{tileH, tileV}:\cr
If the extent is specified through this method, no cropping is performed and the full un-cutted tile(s) is/are processed!  
}

\value{List}

\author{
  Matteo Mattiuzzi
}

\seealso{
raster package: \code{?extent,?raster,?stack,?brick} or \code{?shapefile}
}

\examples{
\dontrun{
# ex 1 ############
# drawing the extent. NOTE: It is not possible to draw a date-line crossing area!
# draw extent with zoom, for smaller extents
getTile()

# ex 2 ############
# "extent" specified with a vector file (map or shp)
japan <- getTile(extent="Japan")
japan
# and here the same "extent" without polygon (vwector object) 
getTile(extent=japan$extent)

# ex 3 ############
# with tileH and tileV
getTile(tileH=18:19,tileV=4)

# ex 4 ############
# with Extent of class "list"
Austria <- list(ymin=46.12,ymax=49.3,xmin=9.2,xmax=17.47)
getTile(extent=Austria)
getTile(extent=Austria,buffer=10)
getTile(extent=Austria,buffer=c(0,10)) 

# ex 5 ############
# with Extent or raster* object from raster package
# rasterObject
rasterObject <- raster(xmn=9.2,xmx=17.47,ymn=46.12,ymx=49.3)
getTile(extent=rasterObject)

# raster extent
ext <- extent(rasterObject)
getTile(extent=ext)

# rasterObject in UTM33N
CRS <- "+proj=utm +zone=33 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
rasterObject <- projectExtent(rasterObject,CRS)
extent(rasterObject)
projection(rasterObject)
getTile(extent=rasterObject) 

# ex 6 #################
require(mapdata)
# Character name of a map contained in "map("worldHires",extent,plot=FALSE)".
# Use with caution! The following example includes much more areas than the main USA. 
map("worldHires","usa")

# Maybe before using this option run a test map("worldHires",yourCharacterExtent).
# Check awailability of maps with: 
map("worldHires",plot=FALSE)$names
# or 
search4map("Gua")

getTile(extent="usa")
# it is also possible to put an map object. In this specific example the low resolution map is used!
# in such case polygon matching is used see ex 2
getTile(extent=map("usa",plot=FALSE))

# also possible: 
ext <-  map("state", region = c("new york", "new jersey", "penn"))
getTile(extent=ext)

# or:
getTile(extent=c("austria","germany","switzerland"))
# SRTM data
getTile(extent=c("austria","germany","switzerland"),system="SRTM")


}
}


