\name{getSDS}

\docType{methods}

\alias{getSDS}

\title{List SDS in a MODIS grid file}

\description{
  This function just lists the names of the SDS of a spezified MODIS grid HDF file}

\usage{getSDS(HdfName,SDSstring,method="gdal")}

\arguments{
  \item{HdfName}{Character. File name or better filename with path (faster) to extract SDS names.}
  \item{SDSstring}{Character. If missing (default), the return is the list of available SDS in \code{HdfName}. If Present sequence of \code{1} and \code{0} for extracting/not extracting SDS layers. I.e.: "11101", Consult the MRT manual for detailes}
  \item{method}{Character. Default \code{gdal}, also supported \code{mrt}} 
} 

\value{
  List or character. If \code{SDSsting} is provided the function reports extracted SDS and a formatted SDSsting. If not provided the SDS names in \code{HdfName} are plotted.
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getPATH}}
}

\examples{
\dontrun{
getSDS(HdfName="XXX")
getSDS(HdfName="/path/XXX")
}
}


