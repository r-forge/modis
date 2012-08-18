\name{preStack}

\docType{methods}

\alias{preStack}

\title{Organises (MODIS) files for the generation of a RasterStack object}

\description{
  This function only organises the filenames within a pattern sorting it by date. It is thought to be used on results of \code{runGdal} or \code{runMrt}
}

\usage{
  preStack(path="./",pattern,begin=NULL,end=NULL,pos1=10,pos2=16)
}

\arguments{
  \item{path}{Location of MODIS files to create the stack: \code{?list.files}}
  \item{pattern}{Pattern to search for MODIS files see: \code{?list.files}}
  \item{begin}{Default is all dates, if set the function subsets by date the files in path and pattern} 
  \item{end}{Default is all dates, if set the function subsets by date the files in path and pattern} 
  \item{pos1}{Start position of date in the filename. You have to count, sorry!} 
  \item{pos2}{End position of date in the filename. You have to count, sorry!} 
} 

\value{
  Character vector of filenames sorted and subsetted by date. The result should be used for: \code{s <- stack(prepStack("xxx"))}
}

\author{
  Matteo Mattiuzzi
}

\examples{
\dontrun{
# no applicable example here
}
}


