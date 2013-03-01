.onLoad <- function(lib, pkg)
{
  # Starting message taken from pkg raster (R.J.Hijmans)
	#pkg.info <- utils::packageDescription('MODIS')
	#packageStartupMessage(paste("\nMODIS version ", pkg.info[["Version"]], " (", pkg.info["Date"], ") \nMODIS_manual: https://www.dropbox.com/sh/18t0rgcm6bga7xt/-4k_Xwojxr/MODIS", sep=""))
	packageStartupMessage("MODIS_manual: https://www.dropbox.com/sh/18t0rgcm6bga7xt/-4k_Xwojxr/MODIS")
    win <- options("warn")
    options(warn=-1)
    MODISoptions(save=FALSE, checkPackages=FALSE, quiet=TRUE)
    options(warn=win$warn)
}



