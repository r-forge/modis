\name{getProduct}

\docType{methods}

\alias{getProduct}
\alias{product,quiet}

\title{Check the avalability of a given product}

\description{
This function will become internal. It will be used if no collection is spezified in the different functions i.e.: \code{getHDF}
}

\usage{getProduct(x,quiet=TRUE)}

\arguments{

  \item{x}{Character. MODIS grid product to check. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. See \url{https://lpdaac.usgs.gov/lpdaac/products/modis_products_table} for more Products.}   

  \item{quiet}{Logical. Default \code{TRUE}. No Prints}

}

\value{
An invisible list with usable information for other functions.
}

\author{
  Matteo Mattiuzzi
}

\examples{

getProduct() # listavailable products

getProduct(x="MxD11C3")

getProduct(x="MxD11C3",quiet=FALSE)

getProduct(x="culture-MERIS",quiet=FALSE) # not fully supported yet

}
