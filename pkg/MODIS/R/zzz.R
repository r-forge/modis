.onLoad <- function(lib, pkg)
{
  # Starting message taken from pkg raster (R.J.Hijmans)
	pkg.info <- utils::packageDescription('MODIS')
	packageStartupMessage(paste("\nMODIS version ", pkg.info[["Version"]], " (", pkg.info["Date"], ") \nMODIS_manual: https://www.dropbox.com/sh/18t0rgcm6bga7xt/-4k_Xwojxr/MODIS", sep=""))
    MODISoptions(save=FALSE, checkPackages=FALSE, quiet=TRUE)
}



