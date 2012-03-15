\name{runMrt}

\docType{methods}

\alias{runMrt}

\title{Run MRT-grid with specified parameters}

\description{
Specifying input parameters this function, gets MODIS grid data from archive (FTP or local) and processes the files.}

\usage{runMrt(ParaSource=NULL,...)}

\arguments{
  \item{ParaSource}{Text file. Run: \code{runMrt()} and look in the MRT-grid Manual for more information.}
  \item{...}{See: Methods or see ParaSource file.}

} 

\section{Methods}{

\describe{
\tabular{rll}{
\tab \code{localArcPath}\tab Character. Default \code{MODIS:::.getDef('localArcPath')}. Local path to look for and to download MODIS files.\cr
  
\tab \code{mosaic}\tab Logical, default \code{TRUE}. Mosaic files of not? One case for setting \code{mosaic=FALSE} is a to big \code{extent}. HDF4 file supports max 2GB filesize using \code{mosaic=FALSE} this can exied in the mosaicing process.\cr
    
\tab \code{anonym}\tab Logical, default \code{TRUE}. If \code{FALSE} the job name is added to the root filename.\cr

\tab \code{MRTpath}\tab Character. Default \code{MRTpath='check'} for automatic detection. See \code{?getPath}. But you can insert path to \code{mrt/bin/}\cr

\tab \code{quiet}\tab Logical. Default \code{FALSE}, its up to you to switsch to 'boring' alias \code{FASLE}. Not fully implemented!\cr

\tab \code{dlmethod}\tab default \code{auto}. Argument passed to \code{?download.file}\cr

\tab \code{stubbornness}\tab Default \code{high}. \code{stubbornness} of the download machanism after ftp connection break. Levels are \code{low} try once, \code{medium} three retries, \code{high} with eight, \code{veryhigh} fifty times and \code{extreme} with fivehundred, or a numeric individual value. Increasing the \code{stubbornness} increases the chance of getting your job terminated. For large download jobs, it is recomanded to increase the \code{stubbornness}, any experience feedback is welcome!\cr
}
}
}
\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getHdf}}
}

\examples{
\dontrun{
runMrt()
# You can open the file specified by 'runMrt()' and modify it or test it!
runMrt(ParaSource="OutputOf'runMrt()'")
}
}


