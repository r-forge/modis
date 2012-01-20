\name{getPRODUCT}

\docType{methods}

\alias{getPRODUCT}
\alias{product,quiet}

\title{Check the avalability of a given product}

\description{
This function will become internal. It will be used if no collection is spezified in the different functions i.e.: \code{getHDF}
}

\usage{getPRODUCT(product,sensor="MODIS",quiet=TRUE)}

\arguments{

  \item{product}{Character. MODIS grid product to check. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. See \url{https://lpdaac.usgs.gov/lpdaac/products/modis_products_table} for more Products.}   

  \item{sensor}{Character. Default \code{MODIS}. Select sensor do download data. \code{MODIS or MERIS}. (MERIS not fully implemented yet)}

  \item{quiet}{Logical. Default \code{TRUE}. No Prints}

}

\value{
An invisible list with usable information for other functions.
}

\author{
  Matteo Mattiuzzi
}

\examples{

getPRODUCT(product="MxD11C3")
x <- getPRODUCT(product="MxD11C3")
x
getPRODUCT(product="MxD11C3",quiet=FALSE)

x <- getPRODUCT(sensor="MERIS",quiet=FALSE)
x
}
