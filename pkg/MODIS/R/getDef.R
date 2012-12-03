# Internal function to gatter package defaults

.getDef <- function(...)
{
  opt1 <- list(...) # if only a subset of opts should be printed
  
  if (file.exists("~/.MODIS_Opts.R"))
  {
    # this corrects/modifies (currently only 'arcStructure') ".MODIS_opts.R" file.
    # (It also creates the MODIS_opts.R file)
    makeOpts(changeStruc=TRUE)
  }
  
  localArcPath <- normalizePath(MODIS:::MODISpackageOpts$localArcPath, "/", mustWork = FALSE)
  if(length(dir(localArcPath))==0) 
  {
      warning("'localArcPath' not found, it will be created!")
      dir.create(localArcPath, recursive = TRUE, showWarnings = TRUE)
  }

  outDirPath <- normalizePath(MODIS:::MODISpackageOpts$outDirPath, "/", mustWork = FALSE)  
  if(length(dir(outDirPath))==0)
  {
      warning("'outDirPath' not found, it will be created!")
      dir.create(outDirPath, recursive = TRUE, showWarnings = TRUE)
  }
  
	if (length(opt1)==0)
  {
  	return(MODISpackageOpts)
	} else 
	{
		result <- list()
	
		for (i in 1:length(opt1))
		{
			result[[i]] <- MODISpackageOpts[[grep(names(MODISpackageOpts),pattern=opt1[[i]])]]
		}
		names(result) <- opt1

	  return(if(length(result)==1) {unlist(result)} else {result})
	}
}


