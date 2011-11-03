\name{getMODIS-package}

\alias{getMODIS-package}

\docType{package}

\title{Functions for selective MODIS-GRID-data download or update. And pre-processing routines (cropping, reprojecting, mosaicing, SDS extraction, bitmask extraction) usin MRT software.}
 
\description{
Functions for selective 'mirroring' of the global MODIS data pool (starting from version 0.2.4: \url{ftp://e4ftl01.cr.usgs.gov/},until version 0.2-3: \url{ftp://e4ftl01u.ecs.nasa.gov/}). Simple parameters are defining: modis-product, collection, area/tile and period. The functions are performing the following tasks: if not existing it creates a local archive structure equivalent to the online storage (or a simplified structure), checks if files are already stored locally, if not download the needed file(s).

Installing MODIS ReprojectionTool MRT software it is possible to further process downloaded data:

- MODIS ReprojectionTool (MRT): format conversion, mosaicing, SDS-extraction, reprojection, resampling, bit mask extraction. (\url{https://lpdaac.usgs.gov/lpdaac/tools/modis_reprojection_tool})

}

\author{
Matteo Mattiuzzi; Institute of Surveying, Remote Sensing and Land Information (IVFL), BOKU Vienna\cr 
Anja Klisch; Institute of Surveying, Remote Sensing and Land Information (IVFL), BOKU Vienna 

Maintainer: Matteo Mattiuzzi \email{matteo.mattiuzzi@boku.ac.at}
}

\references{
MODIS data pool home page with list of data access possibilities: \url{https://lpdaac.usgs.gov/lpdaac/get_data/data_pool}\cr
MODIS data pool server: \url{ftp://e4ftl01.cr.usgs.gov/}\cr
MODIS home page: \url{http://modis.gsfc.nasa.gov/}\cr

A great thanks to Tomislav Hengl. 'getMODIS' has its origin in his code see: \url{http://spatial-analyst.net/wiki/index.php?title=Download_and_resampling_of_MODIS_images}.

}

\keyword{package}
\keyword{MODIS, time series}

