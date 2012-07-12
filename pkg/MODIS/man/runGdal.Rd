\name{runGdal}

\docType{methods}

\alias{runGdal}

\title{Process MODIS hdf with GDAL}

\description{
Downloads MODIS grid data from archive (FTP or local) and processes the files.}

\usage{runGdal(ParaSource=NULL,...)}

\arguments{
  \item{ParaSource}{Text file. Run: \code{runGdal()} and look GDAL-utilities.}
  \item{...}{See: Methods or see ParaSource file.}

} 

\section{Methods}{

\describe{
\tabular{rll}{
\tab \code{product}\tab See: \code{?getProduct()}\cr
\tab \code{begin}\tab See: \code{?transDate()}\cr
\tab \code{end}\tab \code{?transDate()}\cr
\tab \code{extent}\tab \code{?getTile()}\cr
\tab \code{job}\tab Character. name of the current job. if not specified it is created: 'PRODUCT.COLLECTION_DATETIME'\cr
\tab \code{outProj}\tab Character. CRS string of output. Default is 'GEOGRAPHIC', alternative is 'asIn' for no warping. Or userdefined in '.MODIS_opts.R' file.  \cr
\tab \code{pixelsize}\tab Output pixelsize in target reference system. default 'asIn'.\cr
\tab \code{resamplingType}\tab Character. Default is 'near'. Or one of:  'near', 'bilinear', 'cubic', 'cubicspline', 'lanczos'.\cr
\tab \code{localArcPath}\tab Character. Default \code{MODIS:::.getDef('localArcPath')}. Local path to look for and to download MODIS files.\cr
\tab \code{dlmethod}\tab default \code{auto}. Argument passed to \code{?download.file}\cr
\tab \code{stubbornness}\tab Default \code{high}. \code{stubbornness} of the download machanism after ftp connection break. Levels are \code{low} try once, \code{medium} three retries, \code{high} with eight, \code{veryhigh} fifty times and \code{extreme} with fivehundred, or a numeric individual value. Increasing the \code{stubbornness} increases the chance of getting your job terminated. For large download jobs, it is recomanded to increase the \code{stubbornness}, any experience feedback is welcome!\cr
}
}
}
\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHdf}},\code{\link{runMrt}}
}

\source{
http://www.gdal.org/gdal_utilities.html
On Windows you need to install FWTools since the standard GDAL does not support HDF4 format (http://fwtools.maptools.org/) 
}

\examples{
\dontrun{
runGdal()
# You can open the file specified by 'runGdal()' and modify it or test it!
runGdal(ParaSource="OutputOf'runGdal()'")
}
}


