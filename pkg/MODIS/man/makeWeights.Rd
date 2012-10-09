\name{makeWeights}

\docType{methods}

\alias{makeWeights}

\title{Extract bit-encoded information from a raster file. Create a weihgts rasterfile}

\description{
This function applies \code{bitMask} and \code{bitShiftR} from package bitops to convert bit-encoded information. It is also possible to convert this information to a scale from 0 to 1 in order to use it as quality information in functions like \link{whittaker.raster} or \link{smooth.spline.raster}  
}

\usage{
makeWeights(x, bitShift, bitMask, threshold=NULL, filename='', decodeOnly=FALSE,...)
}

\arguments{
  \item{x}{One of Raster -Stack or -Brick}
  \item{bitShift}{bit starting point}
  \item{bitMask}{bit mask size} 
  \item{threshold}{Threshold for valid quality} 
  \item{filename}{Argument passed to \code{writeRaster}, if not set it writes to a tempfile} 
  \item{decodeOnly}{default FASLE, convert bits to a weights from 0 (not used) to 1 (best quality). Or TRUE only extract selected bits and convert to decimal system.} 
  \item{...}{Other arguments for \code{writeRaster}} 
} 

\value{
    A raster object like the input with transformed values
}

\author{
  Matteo Mattiuzzi
}

\examples{
\dontrun{

require(bitopts)
bit <- round(runif(16*10*10,1,65536))
bit <- matrix(bit,ncol=16,nrow=100)

VIqual <- raster(ncol=10,nrow=10)
VIqual[] <- bit

# example MOD13Q1 see https://lpdaac.usgs.gov/products/modis_products_table/mod13q1 
# enter in Layers
# See in TABLE 2: MOD13Q1 VI Quality
# column 1 (bit) row 2 VI usefulness 
bitShift = 2
bitMask = 15 # ('15' is the decimal of the binary '1111')  
a <- makeWeights(VIqual,bitShift,bitMask,decodeOnly=TRUE)

# linear conversion of 0 (0000) to 15 (1111) to 1 fo 0 

b <- makeWeights(VIqual,bitShift,bitMask,decodeOnly=FALSE)

threshold=6 # every thing < threshold becomes a weight = 0
c <- makeWeights(VIqual,bitShift,bitMask,threshold,decodeOnly=FALSE)

res <- round(cbind(a[],b[],c[]),2)
colnames(res) <- c("ORIG","Weight","WeightThreshold") 
res
}
}


