\name{checkAV}

\docType{methods}

\alias{checkAV}
\alias{checkAV, LocalArcPath,  product, startdate, enddate, tileH, tileV, extent, collection, quiet}

\title{Check for availability of needed MODIS data}

\description{
 Function is very similar to \code{getHDF}, with the difference that it reurns only the amount of needed data and the amount of yet locally available data.}

\usage{checkAV(LocalArcPath, product, startdate, enddate, tileH, tileV, extent, collection, quiet=FALSE)}

\arguments{

  \item{LocalArcPath}{Character. Local path to look for and to download MODIS files.  If missing the default archive '~/MODIS_ARC/' (LINUX), 'C:/Documents and Settings/username/My Documents/MODIS_ARC/' (Windows XP) and 'C:/Users/username/Documents/MODIS_ARC' (Vista/Windows 7) is used.}

  \item{product}{Character. (Ignored if \code{HdfName} is provided.) MODIS grid product to be downloaded. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. See \url{https://lpdaac.usgs.gov/lpdaac/products/modis_products_table} for more Products.}   
    
  \item{startdate}{Character. (Ignored if \code{HdfName} is provided.) Subset start date of MODIS time series (sequence is: "YYYY.MM.DD").}

  \item{enddate}{Character. (Ignored if \code{HdfName} is provided.) Subset end date of MODIS time series (sequence is: "YYYY.MM.DD"). Can be a future (but real!) date, for continuous update in a schedule job.}

  \item{tileH}{Character vector. (Ignored if \code{HdfName} is provided.) Horizontal tile number(s) (between 0 and 35). I.e.: \code{tileH = 1:5}. Refer to \url{http://modis-land.gsfc.nasa.gov/MODLAND_grid.htm} to find your area.}

  \item{tileV}{Character vector. (Ignored if \code{HdfName} is provided.) Vertical tile number(s) (between 0 and 17). I.e.: \code{tileV = 9:17}.}

  \item{extent}{see \code{'extent'} in \code{?getTILE}.}

  \item{collection}{Character or integer. (Ignored if \code{HdfName} is provided.) Refers to the MODIS product collection-version. Often '005', but see MODIS pages for more information.} 

  \item{quiet}{Logical. Refers to all internal \code{download.file()} actions. Default \code{FALSE}, if \code{TRUE} the \code{getHDF} becomes really boring.}
  
  }

\value{
  list with 2 slots: number of requested files and the mumber of available data
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getXML}}
}

\examples{
\dontrun{
checkAV(product="MOD13Q1",startdate="2009.01.01",enddate="2015.12.31",tileH=19,tileV=4:5) 
}
}


