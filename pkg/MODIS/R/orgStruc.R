# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3

orgStruc <- function(from,to,structure, pattern, move=TRUE, quiet=FALSE)
{	
	
	opts <- combineOptions()
    if (missing(from))
    {
        from <- opts$localArcPath
    }
    from <- MODIS:::setPath(from)
    
    if (missing(to))
    {
        to <- opts$localArcPath
    }
    to <- MODIS:::setPath(to)
    
    if (!missing(structure))
    {
      opts$acrStructure <- structure
    }
    ###########################
    
    if(missing(pattern)) 
    {
    	cat(paste("No 'pattern' set, moving/coping all MODIS grid data found in '", from,"'.\n",sep=""))
    	avFiles <- unlist(list.files(from, pattern=".hdf$", recursive=TRUE, full.names=TRUE))
    } else 
    {
    	avFiles <- unlist(list.files(from, pattern=pattern, recursive=TRUE, full.names=TRUE))
    }
    
    if (length(avFiles)==0) {stop("No HDF nor HDF.XML files found!\n")}
    doit <- MODIS:::isSupported(avFiles)
    if (sum(doit)==0) {stop("No supported files Found")}
    avFiles <- avFiles[doit]
    
    if (!quiet)
    {
    	cat("Found",length(avFiles),"files \n")
    }
    #########################
    moved <- sapply(avFiles,function(x) 
    {

    	orpath  <- dirname(x)
	    fname   <- basename(x)
	    ########################
	    # generate and create local path to file!
	    path <- MODIS:::genString(x=fname,remote=FALSE,localArcPath=to,opts)$localPath
	    dir.create(path,showWarnings=FALSE,recursive=TRUE)
	    ###################
    
    if (!file.exists(file.path(path,fname,fsep="/"))) 
    { # if file doesn't exist in destdir copy/move

		if (move) 
		{
			file.rename(from=x,to=paste(path,"/",fname,sep=""))			
			if (file.exists(paste(x,".xml",sep=""))) 
			{
				file.rename(from=paste(x,".xml",sep=""),to=paste(path,"/",fname,".xml",sep=""))	
			}
			moved <- 1
		} else 
		{
			file.copy(from=x,to=paste(path,"/",fname,sep=""),overwrite=FALSE)
			if (file.exists(paste(x,".xml",sep=""))) 
			{
				file.copy(from=paste(x,".xml",sep=""),to=paste(path,"/",fname,".xml",sep=""))	
			}
			moved <- 2
		}

	} else if (file.exists(file.path(path,fname,fsep="/")) & orpath!=path) 
	{ # if file exists in destdir & inpath!=outPath...it is duplicated in 2 different locations, so remove it
	    unlink(x)
		if (file.exists(paste(x,".xml",sep=""))) 
		{
			unlink(paste(x,".xml",sep=""))	
		}
		moved <- 3
	} else 
	{
		moved <- 0
	}
	if (length(list.files(orpath))==0) 
	{
		if (.Platform$OS=="unix") 
		{ # I'm looking for a windows/MAC(?) eqal to the linux "rmdir -p" command!!
			warn <- options("warn") 
			options(warn=-2)
			try(xxx <- invisible(system(paste("rmdir -p --ignore-fail-on-non-empty ", orpath,sep=""),intern=TRUE)),silent=TRUE)
			options(warn=warn$warn)
		} else 
		{ # work arount for rmdir -p on windows/MAC(?)
			unlink(orpath,recursive=TRUE)
			secPath <- strsplit(orpath,"/")[[1]]
			
			for (o in length(secPath):1)
			{
				delpath <- paste(secPath[-o:-length(secPath)],sep="",collapse="/")

				if (length(list.files(delpath))==0)
				{
					unlink(delpath,recursive=TRUE)
				} else
				{
				    break
				}
			}
		} 
	}
	return(moved)
	})
	
	if (sum(moved==0)==length(avFiles)) 
	{
		cat("All files in the query are fine, no files to move or to copy!\n") 
	} else 
	{
		cat("Moved files", sum(moved==1),"\n")
		cat("Copied files", sum(moved==2),"\n")
		cat("Not moved files", sum(moved==0),"\n")
		cat("Deleted multiple files", sum(moved==3),"\n")
	}
}

