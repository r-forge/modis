\name{getProduct}

\docType{methods}

\alias{getProduct}
\alias{product,quiet}

\title{Check the avalability of a given product, create file related information}

\description{
On user side it is a funtion to find the desidered product. On package site it generates internal information for string generation.  
}

\usage{getProduct(x,quiet=FALSE)}

\arguments{

  \item{x}{Character. MODIS filename, MODIS Product name or Regular expression (for regular expression argument see in \code{?grep} the argument \code{pattern} for details).}   

  \item{quiet}{Logical. Default \code{FALSE}.}

}

\value{
An invisible list with usable information for other functions.
}

\author{
  Matteo Mattiuzzi
}

\examples{

getProduct() # list available products

getProduct("MxD11C3") # 'x' for backward compatibility
getProduct("MxD11C3",quiet=TRUE)
# or
getProduct("M.D11C3") # regular expression
getProduct("MOD14") # regular expression
getProduct("MOD14$") # regular expression



getProduct("culture-MERIS") # not fully supported yet

}
