\name{runGdal}

\docType{methods}

\alias{runGdal}

\title{Process MODIS hdf with GDAL}

\description{
Downloads MODIS grid data from archive (FTP or local) and processes the files.}

\usage{runGdal(...)}

\arguments{
  \item{...}{See section 'Methods'.}
} 

\section{Methods}{

\describe{
\tabular{rll}{
\tab \code{product}\tab See: \code{?getProduct()}\cr
\tab \code{begin}\tab See: \code{?transDate()}\cr
\tab \code{end}\tab See: \code{?transDate()}\cr
\tab \code{extent}\tab See: \code{?getTile()} and Details!\cr
\tab \code{SDSstring}\tab See: \code{?getSds(). Default is extract all SDS (layers).}\cr
\tab \code{job}\tab Character. Name of the current job for the creation of the output folder. If not specified it is created: 'PRODUCT.COLLECTION_DATETIME'\cr
\tab \code{outProj}\tab CRS/ prj4/ EPSG code of output any format supported by gdal utilities see examples. Default is 'GEOGRAPHIC', alternative is 'asIn' for no warping. You can change the default in the '.MODIS_opts.R' file.\cr
\tab \code{pixelSize}\tab Numeric single value. Output pixel size in target reference system unit. Default is 'asIn'.\cr
\tab \code{resamplingType}\tab Character. Default is 'near' or one of: 'bilinear', 'cubic', 'cubicspline', 'lanczos'.\cr
\tab \code{blockSize}\tab integer. Default \code{NULL} that means the stripe size is set by GDAL. Basically it is the "-co BLOCKYSIZE=" parameter. See: http://www.gdal.org/frmt_gtiff.html\cr
\tab \code{compression}\tab logical. Default is \code{TRUE}, compress data with the lossless LZW compression with "predictor=2". See: http://www.gdal.org/frmt_gtiff.html\cr

\tab \code{localArcPath}\tab Character. Default \code{options("MODIS_localArcPath")}. Local path to look for and/or to download MODIS files.\cr
\tab \code{outDirPath}\tab Character. Default \code{options("MODIS_outDirPath")}. Root directory where to write \code{job} folder.\cr

}
}
}

\details{
\code{runGdal()} uses a lot of 'MODIS'-package functions, see their manual (?funX) for details and input possibilities. You can also pass arguments of \code{getHdf()} such as 'dlmetod', 'checkSize'... see \code{getHdf}.
\cr If the argument \code{extent} is a raster* object, and if not specified otherwise with dedicated arguments (pixelSize and outProj), the output has exactly the same extent, pixelSize and output projection as the used raster* object.
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
# LST in Austria
runGdal( product="MOD11A1", extent="austria", begin="2010001", end="2010005", SDSstring="101")

# LST with interactiv area selection
runGdal( product="MOD11A1", begin="2010001", end="2010005", SDSstring="101")

### outProj examples
# LST of Austria warped to UTM 34N (the three different possibilites to specify "outProj")
# to find am EPSG or prj4 you may use: prj <- make_EPSG() See  
runGdal( job="LSTaustria", product="MOD11A1", extent="Austria", begin="2010001", end="2010005",
 SDSstring="101", outProj="EPSG:32634")
 
runGdal( job="LSTaustria", product="MOD11A1", extent="Austria", begin="2010001", end="2010005",
 SDSstring="101", outProj="32634")
 
runGdal( job="LSTaustria", product="MOD11A1", extent="Austria", begin="2010001", end="2010005",
 SDSstring="101", outProj="+proj=utm +zone=34 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")

### resamplingType examples
runGdal( job="LSTaustria", product="MOD11A1", extent="Austria", begin="2010001", end="2010005",
 SDSstring="1", resamplingType="lanczos", outProj="32634", pixelSize=100)

### processing entire tiles and keeping Sinusoidal projection
# This corresponds to a format conversion (eos-hdf04 to Geotiff) and layer extraction (multi-layer to single layer)
runGdal( job="LSTaustria", product="MOD11A1", tileH=18:19,tileV=4, begin="2010001", end="2010005",
 SDSstring="1", outProj="asIn")

}
}


