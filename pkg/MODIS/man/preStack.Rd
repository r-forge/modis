\name{preStack}

\docType{methods}

\alias{preStack}

\title{Organises (MODIS) files for the generation of a RasterStack object}

\description{
  This function only organises the filenames within a pattern sorting it by date. It is thought to be used on results of \code{runGdal} or \code{runMrt}
}

\usage{
  preStack(pattern = "*", path = "./", files = NULL, timeInfo = NULL)
}

\arguments{
  \item{pattern}{Pattern to search for MODIS files see: \code{?list.files}}
  \item{path}{Location of MODIS files to create the stack: \code{?list.files}}
  \item{files}{character vector of filenames. If used it overrooles 'path' and 'pattern'} 
  \item{timeInfo}{result of \code{?orgTime}} 
} 

\value{
  Character vector of filenames sorted and subsetted by date. The result should be used for: \code{s <- stack(prepStack("xxx"))}
}

\author{
  Matteo Mattiuzzi
}

\examples{
\dontrun{
# see the example in \code{?smooth.spline.raster}
}
}


