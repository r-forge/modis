# Internal function to gatter Package defaults

.getDef <- function(...)
{
    MODIS:::makeOpts(changeStruc=TRUE)
    
    defOpts <- new.env()
    eval(parse(file.path("~/.MODIS_Opts.R")),envir=defOpts)
    opt2 <- as.list(defOpts)    
    
    try(testDir <- normalizePath(opt2$localArcPath,"/",mustWork = TRUE), silent = TRUE)
    if(!exists("testDir")) 
    {
        warning("'localArcPath' not found, it will be created!")
        localArcPath <- normalizePath(opt2$localArcPath, "/", mustWork = FALSE)
        dir.create(localArcPath, recursive = TRUE, showWarnings = TRUE)
    }
    
    try(testDir <- normalizePath(opt2$outDirPath, "/", mustWork=TRUE), silent = TRUE)
    if(!exists("testDir")) 
    {
        warning("'outDirPath' not found, it will be created!")
        outDirPath <- normalizePath(opt2$outDirPath, "/", mustWork = FALSE)
        dir.create(outDirPath, recursive = TRUE, showWarnings = TRUE)
    }
    
    opt1 <- list(...) # if only a subset of opts should be printed

	if (length(opt1)==0)
	{
    	return(opt2)
	} else 
	{
		result <- list()
	
		for (i in 1:length(opt1))
		{
			result[[i]] <- opt2[[grep(names(opt2),pattern=opt1[[i]])]]
		}
		names(result) <- opt1

	    return(if(length(result)==1) {unlist(result)} else {result})
	}
}


