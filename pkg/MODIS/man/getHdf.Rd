\name{getHdf}

\docType{methods}
\alias{getHdf}

\title{Create or update a local, user-defined subset of the global online
  MODIS grid data pool.}

\description{
  Create or update a local user-defined subset of the global MODIS grid
  data archive (starting from version MODIS 0.2.4: \url{ftp://e4ftl01.cr.usgs.gov/}, until version MODIS 0.2-3: \url{ftp://e4ftl01u.ecs.nasa.gov/}). Based on
  user-specific parameters the function checks in the local archive for
  available data and downloads missing data from the online MODIS data
  pool. When run in a schedule job, the function manage the continuous
  update of the local MODIS data archive.
}

\usage{getHdf(product, begin=NULL, end=NULL, tileH=NULL, tileV=NULL, extent=NULL, collection=NULL, HdfName, quiet=FALSE, wait=1, checkSize=FALSE, ...)}

\arguments{

  \item{HdfName}{Character (vector or list). Full HDF file name(s) to download. If just few single (AND known!) files should be downloaded use \code{HdfName}. If \code{HdfName} is provided the other file-related parameters are ignored: \code{begin,end,collection,tileV,...}. If many files have to be checked and downloaded it is simpler, safer and faster to use the following parameters.}

  \item{product}{Character. (Ignored if \code{HdfName} is provided.) MODIS grid product to be downloaded. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{M.D13Q1}. Run \code{getProduct()} for an overview of supported products.}   
    
  \item{begin}{Character. (Ignored if \code{HdfName} is provided.) Subset begin date of MODIS time series. See: \code{?transDate} for formatting.}

  \item{end}{Character. (Ignored if \code{HdfName} is provided.) Subset end date of MODIS time series. See: \code{?transDate} for formatting. Can even be a future date, for continuous update in schedule jobs.}

  \item{tileH}{Character vector. (Ignored if \code{HdfName} is provided.) Horizontal tile number(s) (for MODIS between 0 and 35). I.e.: \code{tileH = 1:5}. Refer to \url{http://modis-land.gsfc.nasa.gov/MODLAND_grid.htm} to find your area.}

  \item{tileV}{Character vector. (Ignored if \code{HdfName} is provided.) Vertical tile number(s) (for MODIS between 0 and 17). I.e.: \code{tileV = 9:17}.}

  \item{extent}{see \code{'extent'} in \code{?getTile}.}

  \item{collection}{Character or integer. (Ignored if \code{HdfName} is provided.) Refers to the MODIS product collection-version. Often '005', but see MODIS pages or run \code{?getCollection} for more information.} 
  
  \item{checkSize}{Logical. Default \code{FALSE}, MODIS-XML files are not downloaded and the "checkSum" is not done. If \code{TRUE} MODIS-HDF and corresponding MODIS-XML files are checked and downloaded and the filesize is checked. This takes more time than using \code{FALSE} but gives more security of data integrity. You can also run \code{?getXml} in a separate run, this function checks the MODIS archive for data integrity.}
    
  \item{wait}{Numeric. Default \code{1}. Inserts a break (in seconds) after every internal \code{download.file()} or \code{getURL()} call. It reduces the chance of FTP connection error that often occurs after many requests. (Hopefully a temporary solution!)}

  \item{quiet}{Logical. Refers to all internal \code{download.file()} actions. Default \code{FALSE}, if \code{TRUE} the \code{getHdf()} becomes really boring.}

  \item{...}{Arguments found in MODISoptions, sections 'STORAGE' and 'DOWNLOAD'}

}

\value{
  An invisible vector of downloaded data+path, if \code{log=TRUE}, a CSV file with reports
}

\references{
MODIS data is obtained through the online Data Pool at the NASA Land Processes Distributed Active Archive Center (LP DAAC), USGS/Earth Resources Observation and Science (EROS) Center, Sioux Falls, South Dakota \url{https://lpdaac.usgs.gov/get_data}.

SRTM data is obtained through CGIAR-CSI and mirror servers. For the use this data please read \url{http://srtm.csi.cgiar.org/SELECTION/SRT_disclaimer.htm}.
Jarvis A., H.I. Reuter, A.  Nelson, E. Guevara, 2008, Hole-filled  seamless SRTM data V4, International Centre for Tropical Agriculture (CIAT), available  from
\url{http://srtm.csi.cgiar.org}
 
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getXml}}
}

\examples{
\dontrun{
# one specific file (no regular erpression allowed here for now!)
# ca 213 mB!!!
a <- getHdf(HdfName="MOD13Q1.A2009209.h19v04.005.2009227222141.hdf", wait=0)
a

# DO NOT RUN THE NEXT EXAMPLE (unless you need this data)!!!
# Get all MODIS TERRA and AQUA 11A1 beginning from 18. October 2011 up to today.
# (Can be ran in a sceduled job, for daily archive update)
# getHdf(product="M.D11A1",begin="2011.10.18",tileH=18:19,tileV=4) 

# same Tiles with a LIST extent.
# approximatley 21 mB!
Austria <- list(xmax=17.47,xmin=9.2,ymin=46.12,ymax=49.3)
b <- getHdf(product="M.D11A1",begin="2009001",end="2009-01-02",extent=Austria)
b

# require(mapdata)
getHdf(product="M.D11A1",begin="2009.01.01",end="2009002",extent="austria")
# without specification of the extent... interactive selection see: "getTile()"
c <- getHdf(product="M.D11A1",begin="2009.01.01",end="2009002")
c

# SRTM data
# SRTM server limits downloads! (It seams to be blocked, but (normally) it continues after a while,
# you have to be patient!).
# The files are zips, this function only performs the download! (runGdal does not run on this files!) 
d <- getHdf(product="SRTM",extent="austria")  
d
}
}


