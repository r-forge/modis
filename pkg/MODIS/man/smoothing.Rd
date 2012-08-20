\name{smooth.spline.raster}

\docType{methods}

\alias{smooth.spline.raster}

\title{Filter time series imagery with a cubic spline}

\description{
This function uses the \code{smooth.spline} function to filter a vegetation index time serie of satellite data. Currently tested only with MODIS and Landsat data. Using M*D13 it is also possible to use the 'composite_day_of_the_year' layer and the 'VI_Quality' layer. This function is currently under heavy development!
}

\usage{
smooth.spline.raster(vi,wt=NULL,inT=NULL,groupYears=TRUE,timeInfo=orgTime(vi),df=6,outPath ="./")
}

\arguments{
  \item{vi}{Sorted Vegetation index files(names).}
  \item{wt}{In case of MODIS composite the 'VI_Quality' filesfiles(names).}
  \item{inT}{In case of MODIS composite the 'composite_day_of_the_year' filesfiles(names).} 
  \item{groupYears}{Default \code{TRUE}, rasterBrick files separated by years. If \code{FALSE} a overall rasterBrick file} 
  \item{timeInfo}{result from \code{?orgTime}} 
  \item{df}{_Yearly_ degree of freedom value passed to \code{?smooth.spline}} 
  \item{outPath}{Output path default is the current directory}   
} 

\value{
the filtered data and a text file with the dates of the output layers
}

\author{
  Matteo Mattiuzzi
}

\examples{
\dontrun{
# The full capacity of the following functions is currently avaliable only with M*D13 data.
# !! The function is very now, distrust to the result is for sure not the worst behavior !!

# You need to extract the: 'vegetation index', 'VI_Quality layer', and 'composite day of the year' layer.
# runGdal(product="MOD13A2",begin="2004340",extent="sicily",end="2006070",job="fullCapa",SDSstring="101000000010")
# You can download this already processed dataset from: http://www.wuala.com/IVFL/R_MODIS/ 
# Afterward copy it to \code{MODIS:::.getDef()$outDirPath}

# the only obligatory dataset is "vi" (vegetatino index), get the 'vi' data on the source directory: 
path <- paste(MODIS:::.getDef()$outDirPath,"/fullCapa",sep="")
vi   <- preStack(path=path, pattern="*_NDVI.tif$")

# "orgTime" detects timing information of the input data and generates based on the arguments
# the output date information. For spline function the beginning and the end of the time series
# is always problematic. So there is the argument "pillow" (default 75 days) that adds
# (if available) some more layers on the two endings.
  
timeInfo <- orgTime(vi,nDays=16,begin="2005001",end="2005365",pillow=40)

# now re-run "preStack" with two diferences, 'files' (output of the first 'preStack' call. and the 'timeInfo'
# Here only the data needed for the filtering is extractet:
vi <- preStack(files=vi,timeInfo=timeInfo)

# For speedup try (Sometimes problematic on Win7): 
beginCluster(type="SOCK") # on linux you can also set the 'nice' level for the workers see: ?beginCluster
system.time(smooth.spline.raster(vi,timeInfo=timeInfo,df=10))

# Doesn't works in version 0.5-0!
# if the files are M*D13 you can use also Quality layers and the composite day of the year:
#wt  <- preStack(path=path, pattern="*_VI_Quality.tif$", timeInfo=timeInfo)
#inT <- preStack(path=path, pattern="*_composite_day_of_the_year.tif$", timeInfo=timeInfo)

#beginCluster(type="SOCK") # on linux you can also set the 'nice' level for the workers see: ?beginCluster
#system.time(smooth.spline.raster(vi=vi,wt=wt,inT=inT,timeInfo=timeInfo,df=10))

}
}


