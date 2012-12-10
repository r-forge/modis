\name{MODISoptions}
\alias{MODISoptions}
\title{
Set or retrieve permanent MODIS package options}
\description{
With this function you can get or set _persistant_ MODIS package options (user or system wide). Changes here will persist sessions and updates.}
\usage{
MODISoptions(localArcPath, outDirPath, pixelSize, outProj, resamplingType, gdalPath, dlmethod, stubbornness, systemwide = FALSE, print = TRUE)
}
\arguments{
  \item{localArcPath}{
File Path where to store downloaded MODIS Grid Products. Default is "~/MODIS_ARC".  
}
  \item{outDirPath}{
The output path where to store results of \code{runGdal} or \code{whittaker.raster}
}
  \item{pixelSize}{
Default is "asIn", pixel size [target reference system units] of processing functions \code{runGdal} and \code{runMrt}.
}
  \item{outProj}{
Target reference system where to process data using \code{runGdal} or \code{runMrt}, must be a valid CRS for \code{runGdal}. For \code{runMrt} consult the manual of MRT. Since the two pocessing method do not have common methods, it is suggested to leave it default, or to use "GEOGRAPHIC".}
  \item{resamplingType}{
Default is "NN" (Neares Neightbour). In common for MRT and GDAL are 'NN', 'CC', 'BIL'. GDAL supports  further: 'cubicspline' and 'lanczos' }
  \item{gdalPath}{
Path to gdal _bin_ directory. Use \code{MODIS:::.checkTools("GDAL")} to detect it automaticly}
  \item{dlmethod}{
Argument passed to ?download.file}
  \item{stubbornness}{
The number of retries after that the FTP has refused the connection. Higher values increase the cahnce of getting the file but also leads to hanging functions if the server is down.}
  \item{systemwide}{
Default \code{FALSE}. User wide settings, if \code{TRUE} write settings to system wide (presumed you have root/administrator access)
}
  \item{print}{
Print to console}
}
\details{
This Settings are _permanent_, easy to change and effective immediatley!}

\author{
Matteo Mattiuzzi and Steven Mosher 
}
\examples{
\dontrun{
MODISoptions()
# MODISoptions(localArcPath="/another/path/than/default")
}
}
