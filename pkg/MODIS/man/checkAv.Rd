\name{checkAv}

\docType{methods}

\alias{checkAv}
\alias{checkAv,localArcPath,product,startdate,enddate,tileH,tileV,extent,collection,quiet}

\title{Check for availability of needed MODIS data}

\description{
 Function is very similar to \code{getHdf}, with the difference that it returns only the amount of needed data and the amount of yet locally available data.}

\usage{checkAv(product,begin=NULL,end=NULL,tileH,tileV,extent,collection,quiet=FALSE,localArcPath=.getDef("localArcPath"))}

\arguments{

  \item{product}{Character. MODIS grid product to be checked for local availability. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. Run \code{getProduct()} for available once.}   
    
  \item{begin}{Character. Subset start date of MODIS time series (sequence is: "YYYY.MM.DD").}

  \item{end}{Character. Subset end date of MODIS time series (sequence is: "YYYY.MM.DD"). Can be a future (but real!) date, for continuous update in a schedule job.}

  \item{tileH}{Character vector. Horizontal tile number(s) (between 0 and 35). I.e.: \code{tileH = 1:5}. Refer to \url{http://modis-land.gsfc.nasa.gov/MODLAND_grid.htm} to find your area.}

  \item{tileV}{Character vector. Vertical tile number(s) (between 0 and 17). I.e.: \code{tileV = 9:17}.}

  \item{extent}{see \code{'extent'} in \code{?getTile}.}

  \item{collection}{Character or integer. Refers to the MODIS product collection-version. Often '005', but see MODIS pages for more information.} 

  \item{quiet}{Logical. Refers to all internal \code{download.file()} actions. Default \code{FALSE}, if \code{TRUE} the \code{getHdf} becomes really boring.}

  \item{localArcPath}{Character. Default is \code{MODIS:::.getDef('localArcPath')}. Set path to the data archive, it is created if it doesn't exists.}
}

\value{
  list with 2 slots: number of totaly needed ('requested') files and the mumber of localy 'available' data.
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getXml}}
}

\examples{
\dontrun{
checkAv(product="MOD13Q1",begin="2009.01.01",end="2015.12.31",tileH=19,tileV=4:5) 
checkAv(product="MOD13Q1",begin="2009.01.01",end="2015.12.31",extent="austria") 

}
}


