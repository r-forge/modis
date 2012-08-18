\name{orgTime}

\docType{methods}

\alias{orgTime}

\title{Creat. an output date information based on the input date information.}

\description{
This function checks the date information in an input file (ie. from MODIS filenames) and generates an output date information used for the creation of a regular intervalled result.
}

\usage{
  orgTime(files,nDays=10,begin=NULL,end=NULL,pos1=10,pos2=16,format="\%Y\%j")
}

\arguments{
  \item{files}{MODIS filenames, output or \code{runGdal} od \code{runMrt}.}
  \item{nDays}{Integer. Time interval for the output layers. Default is 10 days. Can also be nDays="1 month" or "1 week" see: \link{http://statistics.berkeley.edu/classes/s133/dates.html} example of seq(from,to,by) at the bottom.}
  \item{begin}{Default is from earliest input dataset. Here you can supply the begin date of the output files} 
  \item{end}{Default to the end of the input dataset. Here you can specify the end date of the output file (note, the exact value depends also in "nDays" argument.} 
  \item{pos1}{Start position of date in the filename. You have to count, sorry!} 
  \item{pos2}{End position of date in the filename. You have to count, sorry!} 
  \item{format}{Default is all dates, if set the function subsets by date the files in path and pattern} 
} 

\value{
  Character vector of filenames sorted and subsetted by date. The result should be used for: \code{s <- stack(prepStack("xxx"))}
}

\author{
  Matteo Mattiuzzi
}

\examples{
\dontrun{
# note, this function can be applied to any files that have a date information in the _filename_!
files <- c("MOD13A2.A2010353.1_km_16_days_composite_day_of_the_year.tif", "MOD13A2.A2011001.1_km_16_days_composite_day_of_the_year.tif", "MYD13A2.A2010361.1_km_16_days_composite_day_of_the_year.tif", "MYD13A2.A2011009.1_km_16_days_composite_day_of_the_year.tif")

orgTime(files)
orgTime(files,nDays=2,begin="2010350",end="2011015")
}
}


