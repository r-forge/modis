\name{runMRT}

\docType{methods}

\alias{runMRT}

\title{Run MRT-grid with specified parameters}

\description{
  Spezifying input parameters this function, gets MODIS grid data from archive (FTP or local) and processes the files.}

\usage{runMRT(LocalArcPath,ParaSource,...,mosaic=TRUE, anonym=TRUE, MRTpath="check", quiet=FALSE, dlmethod="auto", stubbornness="low")}

\arguments{
  \item{LocalArcPath}{Character. Local path to look for and to download MODIS files.  If missing the default archive '~/MODIS_ARC/' (LINUX), 'C:/Documents and Settings/username/My Documents/MODIS_ARC/' (Windows XP) and 'C:/Users/username/Documents/MODIS_ARC' (Vista/Windows 7) is used.}

  \item{ParaSource}{Text file. Run: \code{runMRT()} or the MRT grid Manual for more information.}

  \item{...}{See: parameters in: \code{runMRT()}. Not all are working for now!}
  
  \item{mosaic}{Logical, default \code{TRUE}. Mosaic files of not? One case for setting \code{mosaic=FALSE} is a to big \code{extent}. HDF4 file supports max 2GB filesize using \code{mosaic=FALSE} this can exied in the mosaicing process.}
    
  \item{anonym}{Logical, default \code{TRUE}. if \code{FALSE} the job name is added to the root filename.}

  \item{MRTpath}{Character. Default \code{MRTpath='check'} for automatic detection. See \code{?getPATH}. But you can insert a manual path to \code{mrt/bin/}} 

  \item{quiet}{Logical. Default \code{FALSE}, its up to you to switsch to 'boring' alias \code{FASLE}. Not fully implemented!}

  \item{dlmethod}{Default \code{auto}. Argument passed to \code{?download.file}}

  \item{stubbornness}{Default \code{low}. \code{stubbornness} of the download machanism after ftp connection break. Levels are \code{low} try once, \code{medium} three retries, \code{high} with eight, \code{veryhigh} fifty times and \code{extreme} with fivehundred, or a numeric individual value. Increasing the \code{stubbornness} increases the chance of getting your job terminated. For large download jobs, it is recomanded to increase the \code{stubbornness}, any experience feedback is wellcome!} 

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


