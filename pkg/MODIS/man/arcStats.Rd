\name{arcStats}

\docType{methods}
\alias{arcStats}

\title{Visualise local available MODIS hdf data}

\description{
In the same manner as \code{getHdf()}, this function quantifies the availability of local MODIS hdf data. This function gives you an overview of locally available hdf files. 
}

\usage{arcStats(product,collection=NULL,extent="global",begin=NULL,end=NULL,asMap=TRUE,outName=NULL,outDir=MODIS:::.getDef("outDirPath"),localArcPath=MODIS:::.getDef("localArcPath"))}

\arguments{

  \item{product}{Character. See \code{?getProduct}. MODIS grid product to be checked. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{M.D13Q1}. Run \code{getProduct()} for an overview of supported products.}   

  \item{collection}{Character or integer. Refers to the MODIS product collection-version. Often '005', but see MODIS pages or run \code{?getCollection} for more information.} 

  \item{extent}{deafult is \code{'global'} additionally see the argument \code{'extent'} in \code{?getTile}.}
      
  \item{begin}{Character. Subset begin date of MODIS time series. See: \code{?transDate} for formatting.}

  \item{end}{Character. Subset end date of MODIS time series. See: \code{?transDate} for formatting. Can even be a future date, for continuous update in schedule jobs.}

  \item{asMap}{\code{TRUE,FALSE or "both"}. Indicates if the output is a 'png' a 'csv' or 'both' of them.}
  
  \item{outName}{Character. Default is the 'product.collection.YYYYMMDDHHMMSS.png/csv' of the function call or if aplicable 'product.collection.extent.YYYYMMDDHHMMSS.png/csv'}  

  \item{outDir}{Character. Default \code{outDir=MODIS:::.getDef("outDirPath")}. Path for saving results}

  \item{localArcPath}{Character. Default \code{MODIS:::.getDef('localArcPath')}. Local path to look for and to download MODIS files.}



}

\value{
  An invisible NULL (provably this will change to a matrix similar to the 'csv' output
}

\author{
  Matteo Mattiuzzi
}

\examples{
\dontrun{
# generates 2 png's and 2 csv's one for TERRA one for AQUA
arcStats(product="M.D13Q1")

arcStats(product="M.D13Q1",extent=c("austria","germany","italy"))

arcStats(product="MYD13Q1",begin="2005001",outName="MyDataStart2005")

}
}


