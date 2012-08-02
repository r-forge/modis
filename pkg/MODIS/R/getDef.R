# Internal function to gatter Package defaults

.getDef <- function(...)
{
    if(!file.exists("~/.MODIS_Opts.R")) {stop("\nCan't find the MODIS settings file in: \'",path.expand('~/.MODIS_Opts.R'),"\'\nCheck the location or copy and modify: \'",file.path(find.package('MODIS'),'external','MODIS_Opts.R'),"\' to: \'",path.expand('~/.MODIS_Opts.R'), "\'",sep="")}

    defOpts  <- new.env() # opts are loaded to a personal envir
    eval(parse(file.path("~/.MODIS_Opts.R")),envir=defOpts)
    opt2 <- as.list(defOpts)    
    opt1 <- list(...) # if only a subset of opts should be readed

	if (length(opt1)==0)
	{
    	return(opt2)
	} else {
		result <- list()
	
		for (i in 1:length(opt1))
		{
			result[[i]] <- opt2[[grep(names(opt2),pattern=opt1[[i]])]]
		}
		names(result) <- opt1

	return(if(length(result)==1) {unlist(result)} else {result})
	}
}
