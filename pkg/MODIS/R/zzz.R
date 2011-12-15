# zzz.R taken from raster package
.onLoad <- function(lib, pkg)  {
	pkg.info <- drop(read.dcf(file=system.file("DESCRIPTION", package=pkg), fields=c("Version","Date")))
	packageStartupMessage(paste("\n",pkg, " version ", pkg.info["Version"], " (", pkg.info["Date"], ")\n\nThe MODIS package is still in an early development status. So bugs and substanzial changes are very frequent!\nMODIS_manual: http://www.wuala.com/IVFL/R_MODIS/ ", sep=""))
	tst <- try( removeTmpFiles(), silent=TRUE )

	return(invisible(0))
}

