\name{getPATH}

\docType{methods}

\alias{getPATH}

\title{get path to MRT}

\description{
  If PATH variable to MRT is not set, this function searchs for it.}

\usage{getPATH(deep=FALSE,quiet=FALSE)}

\arguments{
  \item{deep}{Logical. Default \code{FALSE}, search path ".". If \code{TRUE} search path "/"}
  \item{quiet}{Logical. if run inside an other function use \code{quiet=TRUE}. Probably this function will become internal...} 
} 

\value{
  Absolute path to MRT
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getXML},\link{getHDF}}
}

\examples{
getPATH(quiet=TRUE)
getPATH()
}


