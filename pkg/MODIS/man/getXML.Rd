\name{getXML}

\docType{methods}

\alias{getXML}
\alias{getXML, LocalArcPath, HdfName, wait, quiet}

\title{Function that checks the integrity of MODIS-grid-hdf files in the query.}

\description{
  Each MODIS HDF file has a xml-metafile. This data contains usefull
  information about each MODIS-hdf file. Within that package, the
  xml-files are used to check the size of the downloaded hdf files, and
  correcting the so often broken downloads. 'getXML' checks locally for the presence of spezified xml files and if not available it retrieves them from the MODIS ftp server.
}

\usage{
getXML(LocalArcPath,HdfName,checkSize=TRUE,wait=1,dlmethod="auto",quiet=FALSE)
}

\arguments{
  \item{LocalArcPath}{Character. Is the path to look recursively for MODIS-HDF files. If
  left Blank, the standard argument \code{list.files(path=".")} is
  used. If \code{HdfName} is not set, all underlaying MODIS-HDF files
  are checked for the XML file presence. If not available locally the
  MODIS-XML file is downloaded.}

\item{HdfName}{Character. Is a filename or a pattern (regular expression) to check
  for XML file presence. If \code{HdfName} is not set all found
  MODIS-XML files are gathered regarding the \code{LocalArcPath}
  setting.}
  
\item{checkSize}{Logical. Defoult \code{TRUE}, The main purpose of \code{getXML()} is to control if MODIS HDF files have been downloaded properly. If \code{FALSE} the function only downloads missing XML files without "checksum" the HDF files.}

\item{wait}{Numeric. Default \code{1}. Inserts a break (in seconds) after every
  internal \code{download.file()} or \code{getURL()} call. It reduces
  the chance of FTP connection error that often occurs. Recommended values 1 to 3
  seconds (more files, higer value). (Hopefully \code{wait} is a
  temporary solution!)}
  
\item{quiet}{Logical. Refers to all internal \code{download.file()} actions. Default \code{FALSE}}

\item{dlmethod}{Default \code{"auto"}. Argument is passed to \code{?download.file} if it is called!}
}

\value{
  An (invisible) integer code, \code{0} for success and non-zero for
  failure (see: \code{?download.file}). Look in the directory where the
  HDF files are stored to check for XML files.
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHDF}}
}

\examples{
\dontrun{
# checks all HDF files under path="." for the XML-file and size
getXML()

# check all MODIS Terra Vegetation Indices 250 m (13Q1) under "."
getXML(HdfName="MOD13Q1*")

# check for a single file
getXML(HdfName="MYD09GA.A2011002.h19v05.005.2011007211429.hdf")
}
}

