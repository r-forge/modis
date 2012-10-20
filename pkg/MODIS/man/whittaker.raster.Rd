\name{whittaker.raster}

\docType{methods}

\alias{whittaker.raster}

\title{Filter vegetation index time series imagery with the modified whittaker approach} 

\description{
This function uses a modified whittaker filter function (see references) from package 'ptw' to filter a vegetation index time serie of satellite data.
}

\usage{
whittaker.raster(vi,w=NULL,t=NULL,groupYears=TRUE,timeInfo=orgTime(vi),lambda=500, nIter= 5,
 outPath ="./", ...)
}

\arguments{
  \item{vi}{Sorted 'Vegetation index' raster-Brick, Stack or filenames.}
  \item{w}{In case of MODIS composite the 'VI_Quality'  raster-Brick, Stack or filenames.}
  \item{t}{In case of MODIS composite the 'composite_day_of_the_year'  raster-Brick, Stack or filenames.} 
  \item{groupYears}{Default \code{TRUE}, rasterBrick files separated by years. If \code{FALSE} a overall rasterBrick file.} 
  \item{timeInfo}{result from \code{?orgTime}.} 
  \item{lambda}{_Yearly_ lambda value passed to \code{?with2}.  If set as character (i.e. lambda="600"), it is not adapted to the time serie length but used as a fixed value (see details). High values = stiff/rigid spline} 
  \item{nIter}{Number of iteration for the upper envelope fitting.}   
  \item{outPath}{Output path default is the current directory.}   
  \item{...}{Arguments passed to ?writeRaster (except filename ist automatic), NAflag, datatype, overwrite,..., and if }   
} 

\details{
The argument 'lambda' is passed to the \code{MODIS:::miwhitatzb1} function. You can set it as a yearly 'lambda', this means that it doesn't matter how long the _input_ time serie is because 'lambda' is adapted to it with: \code{lambda*('length of _input_ timeserie in days'/365)}. The input length can differ from the output because of the \code{pillow} argument in \code{orgTime}! But you can also set it as a character value (i.e. lambda="1000") in this case the adaption to the time serie length is not performed.
Further arguments will be implemented very soon!  
}

\value{
The filtered data and a text file with the dates of the output layers
}

\references{
Modified Whittaker smoother, according to Atzberger & Eilers 2011 International Journal of Digital Earth 4(5):365-386.
Implementation in R: A.Lobo 2012 \email{Agustin.Lobo@ictja.csic.es}
}

\note{
Currently tested on MODIS and Landsat data. Using M*D13 it is also possible to use the 'composite_day_of_the_year' layer and the 'VI_Quality' layer. This function is currently under heavy development and a lot of changes will come!
}

\seealso{
\code{\link{smooth.spline.raster}}, \code{?raster}
}

\author{
  Matteo Mattiuzzi and Agustin Lobo
}

\examples{
\dontrun{
# The full capacity of the following functions is currently avaliable only with M*D13 data.
# !! The function is very new, double check the result !!

# You need to extract the: 'vegetation index', 'VI_Quality layer', and 'composite day of the year' layer.
# runGdal(product="MOD13A2",begin="2004340",extent="sicily",end="2006070",
# job="fullCapa",SDSstring="101000000010")
# You can download this dataset from (2.5 MB): https://www.dropbox.com/sh/18t0rgcm6bga7xt/-4k_Xwojxr/MODIS 
# Afterward extract it to: 
MODIS:::.getDef()$outDirPath

# the only obligatory dataset is "vi" (vegetatino index), get the 'vi' data on the source directory: 
path <- paste(MODIS:::.getDef()$outDirPath,"/fullCapa",sep="")
vi <- preStack(path=path, pattern="*_NDVI.tif$")

# "orgTime" detects timing information of the input data and generates based on the arguments
# the output date information. For spline functions (in general) the beginning and the end of the time series
# is always problematic. So there is the argument "pillow" (default 75 days) that adds
# (if available) some more layers on the two endings.
  
timeInfo <- orgTime(vi,nDays=16,begin="2005001",end="2005365",pillow=40)

# now re-run "preStack" with two differences, 'files' (output of the first 'preStack' call. and the 'timeInfo'
# Here only the data needed for the filtering is extracted:
vi <- preStack(files=vi,timeInfo=timeInfo)

# For speedup try (On some Win7 problematic): 
beginCluster(type="SOCK",exclude="MODIS") # See: ?beginCluster
system.time(whittaker.raster(vi,timeInfo=timeInfo,lambda=1000))

# if the files are M*D13 you can use also Quality layers and the composite day of the year:
wt <- preStack(path=path, pattern="*_VI_Quality.tif$", timeInfo=timeInfo)
# can also be already stacked:
inT <- stack(preStack(path=path, pattern="*_composite_day_of_the_year.tif$", timeInfo=timeInfo)) 

beginCluster(type="SOCK",exclude="MODIS") # See: ?beginCluster
system.time(whittaker.raster(vi=vi,wt=wt,inT=inT,timeInfo=timeInfo,lambda=1000,overwrite=TRUE))

}
}

