\name{runMRT}

\docType{methods}

\alias{runMRT}

\title{Run MRT-grid with specified parameters}

\description{
  Spezifying input parameters this function, gets MODIS grid data from archive (FTP or local) and processes the files.}

\usage{runMRT(LocalArcPath,ParaSource, MRTpath = "check",quiet=FALSE)}

\arguments{
  \item{LocalArcPath}{Character. Local path to look for and to download MODIS files.  If missing the default archive '~/MODIS_ARC/' (LINUX), 'C:/Documents and Settings/username/My Documents/MODIS_ARC/' (Windows XP) and 'C:/Users/username/Documents/MODIS_ARC' (Vista/Windows 7) is used.}
  \item{ParaSource}{Text file. see: \code{data('ParaExample')} or the MRT grid Manual for more information.}
  \item{MRTpath}{Character. Default \code{MRTpath='check'} for automatic detection. See \code{?getPATH}. But you can insert a manual path to \code{mrt/bin/}} 
  \item{quiet}{Logical. Default \code{FALSE}, its up to you to switsch to 'boring' alias \code{FASLE}. Not fully implemented!}
} 

\value{
  List or character. If \code{SDSsting} is provided the function reports extracted SDS and a formatted SDSsting. If not provided the SDS names in \code{HdfName} are plotted.
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


