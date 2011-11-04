\name{transDATE}

\docType{methods}

\alias{transDATE}

\title{internal function that transform character to a object of class 'date'}

\description{
  Interal function, gets a }

\usage{transDATE(begin,end)}

\arguments{
  \item{begin}{character string with the following sequence: "YYYY.MM.DD", separator can be any (".","-","/",...)}
  \item{end}{character string with the following sequence: "YYYY.MM.DD", separator can be any (".","-","/",...)}
} 

\value{
  list with 2 slots of class 'date'
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHDF}}
}

\examples{
transDATE()

transDATE(begin="2009.01.01")

transDATE(end="2009.01.01")

transDATE(begin="2009-01-01",end="2011.03.16")
}


