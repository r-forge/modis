\name{getCOLLECTION}

\docType{methods}

\alias{getCOLLECTION}
\alias{LocalArcPath,product,collection,newest,forceCheck}

\title{Retrieve available version of MODIS product collections}

\description{
This function will become internal. It will be used if no collection is spezified in the different functions i.e.: \code{getHDF}
}

\usage{getCOLLECTION(LocalArcPath,product,collection,newest=TRUE,forceCheck=FALSE)}

\arguments{
  \item{LocalArcPath}{Character. Is needed because this funtion creates a hidden folder to store ftp directory inforamtion. If left empty standard path is used see \code{?getHDF}}
  
  \item{product}{Character. MODIS grid product to check collections. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. See \url{https://lpdaac.usgs.gov/lpdaac/products/modis_products_table} for more Products.}   

  \item{collection}{If provided the function only checks it the product exists \code{TRUE} or \code{FALSE} is the value it returns in this case.}
    
  \item{newest}{Logical. Default \code{TRUE}, return only the number of the newest collection.}
 
  \item{forceCheck}{Logical. Default \code{FALSE}, if \code{TRUE} the function connects to the FTP and gets the available collection. Since the collections doesn't change very frequently this check is rarely needed.}

}


\value{
  A three digits integer converted to character, indicating the collection version(s). And a file in an hidden folder \code{/MODIS_ARC/.auxiliaries/collections.txt} as database for further calls.
  if \code{collection} is provided only a \code{TRUE} or \code{FALSE} is retuned!
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getPRODUCT}}
}

\examples{
# update or get the existing collections for MOD11C3 and MYD11C3
getCOLLECTION(product="MxD11C3")
getCOLLECTION(product="MxD11C3",newest=FALSE)

getCOLLECTION(product="MxD11C3",collection=3)
getCOLLECTION(product="MxD11C3",collection=41)
}
