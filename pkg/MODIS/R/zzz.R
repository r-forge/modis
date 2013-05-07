.onLoad <- function(lib, pkg)
{
    win <- options("warn")
    options(warn=-1)
    MODISoptions(save=FALSE, checkPackages=FALSE, quiet=TRUE)
    options(warn=win$warn)

	packageStartupMessage("MODIS_manual: http://ivfl-arc.boku.ac.at/owncloud/public.php?service=shorty_relay&id=QR5FZSxe0g")

}



