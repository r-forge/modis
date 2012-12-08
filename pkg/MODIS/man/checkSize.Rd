\name{checkSize}

\docType{methods}

\alias{checkSize}
\alias{getXml}

\title{Function that checks the integrity of MODIS-grid-hdf files in the query.}

\description{
The expected filesize is determined by listening file size infomration on the FTP server(s) and comparse is with the effective file size. For each MODIS 'product/collection and date' available locally the function checks for online information. Once this information is available locally the check is relatively fast and applicable to all new tiles within the same 'product/collection and date'.  
}

\usage{
checkSize(HdfName, flexB = 0, ...)
}

\arguments{

\item{HdfName}{Character. MODIS-hdf filename or a pattern (regular expression) to check
  locally. If \code{HdfName} is not provided all found
  MODIS GRID files are gathered inside the \code{LocalArcPath}}
\item{flexB}{positive integer. Rigor of the file size check in _Bites_}
\item{...}{Arguments in \code{?MODISoptions}, Ie stubbornness, dlmethod and localArcPath}
}

\value{
  Logical vector of the length of the checked files. \code{TRUE} for file is ok, \code{FASLE} if not.
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHdf}}
}

\examples{
\dontrun{
# only local available files are checked!
# check all MODIS Terra Vegetation Indices 250 m (13Q1)
checkSize(HdfName="MOD13Q1*")

# checks all HDF files under MODIS:::.getDef('localArcPath')
checkSize()

# check for a single file
chekSize(HdfName="MYD09GA.A2011002.h19v05.005.2011007211429.hdf")
}
}

