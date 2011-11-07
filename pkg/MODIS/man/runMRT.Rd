\name{runMRT}

\docType{methods}

\alias{runMRT}

\title{Run MRT-grid with specified parameters}

\description{
  Spezifying input parameters this function, gets MODIS grid data from archive (FTP or local) and processes the files.}

\usage{runMRT(LocalArcPath,ParaSource,job,product,startdate,enddate,tileH,tileV,extent,SDSstring,MRTpath="check", quiet=FALSE, dlmethod="auto")}

\arguments{
  \item{LocalArcPath}{Character. Local path to look for and to download MODIS files.  If missing the default archive '~/MODIS_ARC/' (LINUX), 'C:/Documents and Settings/username/My Documents/MODIS_ARC/' (Windows XP) and 'C:/Users/username/Documents/MODIS_ARC' (Vista/Windows 7) is used.}

  \item{ParaSource}{Text file. Run: \code{runMRT()} or the MRT grid Manual for more information.}

  \item{job}{\code{Character string}. job name (log) and outputfolder name.}
  
  \item{product}{Character. (Ignored if \code{HdfName} is provided.) MODIS grid product to be downloaded. For 'MODIS TERRA Vegetation Indices at 250 m ground resolution' use: \code{MOD13Q1}. For vegetation indices from TERRA and AQUA use \code{MxD13Q1}. See \url{https://lpdaac.usgs.gov/lpdaac/products/modis_products_table} for more Products. See data("MODIS_Products")}   

  \item{startdate}{Character. (Ignored if \code{HdfName} is provided.) Subset start date of MODIS time series (format: "YYYY.MM.DD"). See ?transDATE}

  \item{enddate}{Character. (Ignored if \code{HdfName} is provided.) Subset end date of MODIS time series (format: "YYYY.MM.DD"). Can be a future date, for continuous update in a schedule job. See ?transDATE}

  \item{tileH}{Character vector. (Ignored if \code{HdfName} is provided.) Horizontal tile number(s) (between 0 and 35). I.e.: \code{tileH = 1:5}. Refer to \url{http://modis-land.gsfc.nasa.gov/MODLAND_grid.htm} to find your area. See \code{?getTILE}}

  \item{tileV}{Character vector. (Ignored if \code{HdfName} is provided.) Vertical tile number(s) (between 0 and 17). I.e.: \code{tileV = 9:17}. See \code{?getTILE}}

  \item{extent}{see \code{'extent'} in \code{?getTILE}.}

  \item{SDSstring}{see: \code{getSDS}}

  \item{MRTpath}{Character. Default \code{MRTpath='check'} for automatic detection. See \code{?getPATH}. But you can insert a manual path to \code{mrt/bin/}} 

  \item{quiet}{Logical. Default \code{FALSE}, its up to you to switsch to 'boring' alias \code{FASLE}. Not fully implemented!}

  \item{dlmethod}{Default \code{auto}. Argument passed to \code{?download.file}}
} 

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHDF}}
}

\examples{
# runMRT()
# You can open the file specified by 'runMRT()' and modify it or test it!
# runMRT(ParaSource="OutputOf'runMRT()'")

}


