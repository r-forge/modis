\name{transDate}

\docType{methods}

\alias{transDate}

\title{internal function that transform character to a object of class 'date'}

\description{
  Interal function, for date conversion}

\usage{transDate(begin=NULL,end=NULL)}

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
  \code{\link{getHdf}}
}

\examples{
transDate()

transDate(begin="2009.01.01")

transDate(end="2009.01.01")

transDate(begin="2009-01-01",end="2011.03.16")
}


