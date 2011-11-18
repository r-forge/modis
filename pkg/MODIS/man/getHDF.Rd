\name{getHDF}

\docType{methods}

\alias{getHDF}
\alias{getHDF, LocalArcPath, HdfName, product, startdate, enddate, tileH, tileV, extent, collection, dlmethod, stubbornness, quiet, wait, checkSize, log}

\title{Create or update a local, user-defined subset of the global online
  MODIS grid data pool.}

\description{
  Create or update a local user-defined subset of the global MODIS grid
  data archive (starting from version 0.2.4: \url{ftp://e4ftl01.cr.usgs.gov/},until version 0.2-3: \url{ftp://e4ftl01u.ecs.nasa.gov/}). Based on
  user-specific parameters the function checks in the local archive for
  available data and downloads missing data from the online MODIS data
  pool. When run in a schedule job, the function manage the continuous
  update of local MODIS data archive.
}

\usage{getHDF(LocalArcPath, HdfName, product, startdate, enddate, tileH, tileV, extent, collection, dlmethod="auto",stubbornness="low", quiet=FALSE, wait=1, checkSize=FALSE, log=TRUE)}

\arguments{

  \item{LocalArcPath}{Character. Local path to look for and to download MODIS files.  If missing the default archive '~/MODIS_ARC/' (LINUX), 'C:/Documents and Settings/username/My Documents/MODIS_ARC/' (Windows XP) and 'C:/Users/username/Documents/MODIS_ARC' (Vista/Windows 7) is used.}

  \item{HdfName}{Character (vector or list). Full HDF file name(s) to download. If just few single (AND known!) files should be downloaded use \code{HdfName}. If \code{HdfName} is provided the other file-related parameters are ignored: \code{startdate, enddate, collection, tileV,...}. If many files have to be checked and downloaded it is simpler, safer and faster to use following parameters.}

  \item{product}{Character. (Ignored if \code{HdfName} is provided.) MODIS grid product to be downloaded. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. See \url{https://lpdaac.usgs.gov/lpdaac/products/modis_products_table} for more Products.}   
    
  \item{startdate}{Character. (Ignored if \code{HdfName} is provided.) Subset start date of MODIS time series (format: "YYYY.MM.DD").}

  \item{enddate}{Character. (Ignored if \code{HdfName} is provided.) Subset end date of MODIS time series (format: "YYYY.MM.DD"). Can be a future date, for continuous update in a schedule job.}

  \item{tileH}{Character vector. (Ignored if \code{HdfName} is provided.) Horizontal tile number(s) (between 0 and 35). I.e.: \code{tileH = 1:5}. Refer to \url{http://modis-land.gsfc.nasa.gov/MODLAND_grid.htm} to find your area.}

  \item{tileV}{Character vector. (Ignored if \code{HdfName} is provided.) Vertical tile number(s) (between 0 and 17). I.e.: \code{tileV = 9:17}.}

  \item{extent}{see \code{'extent'} in \code{?getTILE}.}

  \item{collection}{Character or integer. (Ignored if \code{HdfName} is provided.) Refers to the MODIS product collection-version. Often '005', but see MODIS pages for more information.} 

  \item{dlmethod}{Default \code{auto}. Argument passed to \code{?download.file}}

  \item{stubbornness}{Default \code{low}. \code{stubbornness} of the download machanism after ftp connection break. Levels are \code{low} try once, \code{medium} three retries, \code{high} with eight, \code{veryhigh} fifty times and \code{extreme} with fivehundred, or a numeric individual value. Increasing the value increases the runtime but increases also the chance of getting your job terminated. For large jobs, it is recomanded to increase the \code{stubbornness}, any experience feedback is wellcome!} 
  
  \item{checkSize}{Logical. Default \code{FALSE}, MODIS-XML files are not downloaded with their MODIS-HDF file and a "checkSum" is not done. If \code{TRUE} MODIS-HDF and corresponding MODIS-XML files are checked and downloaded and the filesize is checked. (!keep FALSE for now!)}
    
  \item{wait}{Numeric. Default \code{1}. Inserts a break (in seconds) after every internal \code{download.file()} or \code{getURL()} call. It reduces the chance of FTP connection error that often occurs after many requests. Requires the 'audio' package. (Hopefully a temporary solution!)}

  \item{quiet}{Logical. Refers to all internal \code{download.file()} actions. Default \code{FALSE}, if \code{TRUE} the \code{getHDF} becomes really boring.}
  
    \item{log}{Logical. Default \code{TRUE}, a log file is generated in \code{LocalArcPath}}
}

\value{
  NONE, a CSV file with reports, and the HDF archive
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getXML}}
}

\examples{
\dontrun{
# one spezific file (no regular erpression allowed here for now!)
getHDF(HdfName="MOD13Q1.A2009209.h19v04.005.2009227222141.hdf", wait=0)

# DO NOT RUN THE NEXT EXAMPLE (unless you need this data)!!!
# Get all MODIS TERRA 13Q1 beginning from 01. January 2009 up to today.
# If run in a scheduled batch job it will update the data until end of 2015.
getHDF(product="MOD13Q1",startdate="2009.01.01",enddate="2015.12.31",tileH=19,tileV=4:5) 

# or the same with an (list) Extent
Austria <- list(lat_min=46.12,lat_max=49.3,lon_max=17.47,lon_min=9.2)
getHDF(product="MYD13Q1",startdate="2009.01.01",enddate="2015.12.31",extent=Austria)

# require(mapdata)
getHDF(product="MYD13Q1",startdate="2009.01.01",enddate="2015.12.31",extent="austria")
}
}


