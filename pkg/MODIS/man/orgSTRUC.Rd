\name{orgSTRUC}

\docType{methods}

\alias{orgSTRUC}

\title{Organise structure of the local MODIS data archive}

\description{This function changes the storage structure (see details). Depending on the amount of files stored and how files are accessed, the folder structure can be changed. !Use this function with care! }

\usage{orgSTRUC(LocalArcPath, deep = FALSE, HdfName, to, move = TRUE,quiet = FALSE)}

\arguments{
  \item{LocalArcPath}{Character. Local path to look for MODIS files. If missing the default archive '~/MODIS_ARC/' (LINUX), 'C:/Documents and Settings/username/My Documents/MODIS_ARC/' (Windows XP) and 'C:/Users/username/Documents/MODIS_ARC' (Vista/Windows 7) is used.}

  \item{deep}{Logical. Default \code{FALSE}. !!! use with care !!! eventually put \code{move=FALSE}. if \code{TRUE} the functuion look in your entire home (UNIX-alikes) for MODI-GRID-HDF files! and removes them from the origin folder!!! Here a control of a more experienced peRson could spare myself from R-collgues curses!}  
  
 \item{HdfName}{Character. Regular expression (passed to \code{?list.files}) for file matching. If missing, all local MODIS grid data under \code{LocalArcPath} is considered.}

 \item{to}{Integer between \code{1} and \code{3}}

 \item{move}{Logical. Default is \code{TRUE}, this means that files are moved and multiple files are deleted. If \code{FALSE}, files are just copied and remain in origin folder!}
 
  \item{quiet}{Logical. Default is \code{FALSE}}
}

\details{
\tabular{rll}{
  \tab If \code{to} is \code{1} than: \code{/LocalArcPath/product.collection/hdf-} and \code{xml-}files\cr
  \tab If \code{to} is \code{2} than: \code{/LocalArcPath/product.collection/year/hdf-} and \code{xml-}files\cr
  \tab If \code{to} is \code{3} than: \code{/LocalArcPath/product.collection/date/hdf-} and \code{xml-}files\cr

}
}
\value{
  NONE, (or just an information about moved/copied files)
}

\author{
  Matteo Mattiuzzi
}

\seealso{
  \code{\link{getXML},\link{getHDF}}
}

\examples{
\dontrun{
# MOVE all MODIS grid data to a MODIS data online pool like structure
orgSTRUC(to=3,move=TRUE)

# COPY all MOD13Q1 to folder "/LocalArcPath/MOD13Q1.collection/"
orgSTRUC(HdfName="MOD13Q1",to=1,move=FALSE)
}
}


