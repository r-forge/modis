\name{runGdal}

\docType{methods}

\alias{runGdal}

\title{Process MODIS hdf with GDAL}

\description{
Downloads MODIS grid data from archive (FTP or local) and processes the files.}

\usage{runGdal(ParaSource=NULL,...)}

\arguments{
  \item{ParaSource}{Text file. Run: \code{runGdal()} and look GDAL-utilities.}
  \item{...}{See: Methods or see 'ParaSource' file.}
} 

\section{Methods}{

\describe{
\tabular{rll}{
\tab \code{product}\tab See: \code{?getProduct()}\cr
\tab \code{begin}\tab See: \code{?transDate()}\cr
\tab \code{end}\tab \code{?transDate()}\cr
\tab \code{extent}\tab See: \code{?getTile()}\cr
\tab \code{job}\tab Character. name of the current job. if not specified it is created: 'PRODUCT.COLLECTION_DATETIME'\cr
\tab \code{outProj}\tab CRS/prj4/EPSG code of output any format supported by gdal utilities see examples. Default is 'GEOGRAPHIC', alternative is 'asIn' for no warping. You can set a default in the '.MODIS_opts.R' file.\cr
\tab \code{pixelsize}\tab Numeric single value. Output pixelsize in target reference system unit. default is 'asIn'.\cr
\tab \code{resamplingType}\tab Character. Default is 'near'. Or one of:  'near', 'bilinear', 'cubic', 'cubicspline', 'lanczos'.\cr
\tab \code{blockSize}\tab integer. Default \code{NULL} that means the stripe size is sett by GDAL. Basically it is the "-co BLOCKYSIZE=" parameter. See: http://www.gdal.org/frmt_gtiff.html\cr
\tab \code{compression}\tab logical. Default is \code{FALSE}, no compression. Alternative is \code{TRUE} that uses (currently) the LZW compression with "predictor=2". See: http://www.gdal.org/frmt_gtiff.html\cr
}
}
}

\details{
\code{runGdal()} uses a lot of 'MODIS'-package functions, see their manual (?funX) for details and input possibilities. You can also pass arguments of \code{getHdf()} such as 'dlmetod', 'checkSize'... see \code{getHdf}  
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

# LST in Austria
runGdal(product="MOD11A1",extent="austria",begin="2010001",end="2010005",SDSstring="101")

# LST interactiv with area selection
runGdal(product="MOD11A1",begin="2010001",end="2010005",SDSstring="101")

### outProj examples
# LST of Austria warped to UTM 34N 
runGdal(job="LSTaustra",product="MOD11A1",extent="Austria",begin="2010001",end="2010005",SDSstring="101",outProj="EPSG:32634")
runGdal(job="LSTaustra",product="MOD11A1",extent="Austria",begin="2010001",end="2010005",SDSstring="101",outProj="32634")
runGdal(job="LSTaustra",product="MOD11A1",extent="Austria",begin="2010001",end="2010005",SDSstring="101",outProj="+proj=utm +zone=34 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

### resamplingType examples
runGdal(job="LSTaustra",product="MOD11A1",extent="Austria",begin="2010001",end="2010005",SDSstring="1",resamplingType="lanczos",outProj="32634",pixelsize=100)

}
}


