#.onLoad <- function(lib, pkg)
#{
#    win <- options("warn")
#    options(warn=-1)
#    MODISoptions(save=FALSE, checkPackages=FALSE, quiet=TRUE)
#    options(warn=win$warn)
#}
.onAttach <- function(lib, pkg)
{
    #win <- options("warn")
    #options(warn=-1)
    packageStartupMessage(c("MODIS_manual: http://ivfl-arc.boku.ac.at/owncloud/public.php?service=files&t=c4481aebe031c26fbbc62722ace11da4\n",MODISoptions(save=FALSE, checkPackages=FALSE, quiet=TRUE)))
    #options(warn=win$warn)
	#packageStartupMessage("MODIS_manual: http://ivfl-arc.boku.ac.at/owncloud/public.php?service=shorty_relay&id=QR5FZSxe0g")
}

