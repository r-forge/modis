\name{getSTRUC}

\docType{methods}

\alias{getSTRUC}

\title{Change structure of local Archive}

\description{
This function retrieves and updates the folder structure on the MODIS data pool and creates a local file to use for further calls. This function is used for reducing the number of \code{getURL} calls and to enable as offline mode especially for \code{getHDF}.
}

\usage{getSTRUC(LocalArcPath,product,collection,startdate,enddate,wait=1)}

\arguments{
  \item{LocalArcPath}{Character. Is needed because this funtion creates a hidden folder to store ftp directory information. If left empty standard path is used, see \code{?getHDF}.}
  
  \item{product}{Character. MODIS grid product to be downloaded. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. See \url{https://lpdaac.usgs.gov/lpdaac/products/modis_products_table} for more Products.}   
    
  \item{collection}{Character or integer. Refers to the MODIS product collection-version. Often '005', but see MODIS pages for more information.}
 
  \item{startdate}{Character. Subset start date of MODIS time series (format: "YYYY.MM.DD").}

  \item{enddate}{Character. Subset end date of MODIS time series (format: "YYYY.MM.DD").}

  \item{wait}{Numeric. Default \code{1}. Inserts a break (in seconds) after every internal \code{getURL()} call. It reduces the chance of FTP connection error that often occurs after many requests. (Hopefully a temporary solution!)}

}


\value{
  NONE, a file in an hidden folder \code{/MODIS_ARC/.auxiliaries/ftpdir.txt}
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHDF}}
}

\examples{
\dontrun{
# update or get the internal structure for MOD13Q1 and MYD13Q1 collection "005"
getSTRUC(product="MxD13Q1",collection=5)

# update or get the internal structure for MOD09GQ within a limited period
getSTRUC(product="MxD13Q1",collection=5, startdate="2003.05.03",enddate="2008.07.23")
}
}
