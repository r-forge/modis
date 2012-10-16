\name{checkSize}

\docType{methods}

\alias{checkSize}
\alias{getXml}

\title{Function that checks the integrity of MODIS-grid-hdf files in the query.}

\description{
The expected filesize is determined by listening file size infomration on the FTP server(s) and comparse is with the effective file size. For each MODIS 'product/collection and date' available locally the function checks for online information. Once this information is available locally the check is relatively fast and applicable to all new tiles within the same 'product/collection and date'.  
}

\usage{
checkSize(HdfName, dlmethod="auto",stubbornness="low",localArcPath=.getDef('localArcPath'))
}

\arguments{

\item{HdfName}{Character. MODIS-hdf filename or a pattern (regular expression) to check
  locally. If \code{HdfName} is not provided all found
  MODIS GRID files are gathered inside the \code{LocalArcPath}}
\item{dlmethod}{Default \code{"auto"}. Argument is passed to \code{?download.file} if it is called!}
\item{stubbornness}{Character or numeric. Default \code{extreme}. See: code{?getHdf}}
\item{localArcPath}{Character. Is the path to look recursively for MODIS-HDF files. default is \code{MODIS:::.getDef('localArcPath')} If \code{HdfName} is not set, all underlaying MODIS-HDF files
  are checked for the XML file presence. If not available locally the
  are checked.}
}

\value{
  A vector of the length of the checked files. \code{TRUE} for file is ok, \code{FASLE} if not.
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHdf}}
}

\examples{
\dontrun{
# checks all HDF files under MODIS:::.getDef('localArcPath')
checkSize()

# check all MODIS Terra Vegetation Indices 250 m (13Q1)
checkSize(HdfName="MOD13Q1*")

# check for a single file
chekSize(HdfName="MYD09GA.A2011002.h19v05.005.2011007211429.hdf")
}
}

