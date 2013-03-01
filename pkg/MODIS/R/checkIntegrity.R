checkIntegrity <- function(x,...)
{
    opts <- MODIS:::combineOptions(...)
    
    if (.Platform$OS.type=="windows")
    {   
        if (!is.null(opts$gdalPath))
        {        
            opts$gdalPath <- shortPathName(opts$gdalPath)
            cmd <- paste(opts$gdalPath,"\\gdalinfo",sep="") 
        } else
        {
            cmd <- "gdalinfo" 
        }
        testHdf <- shortPathName(system.file("external", "sdunl.hdf", package="MODIS"))
        try(test <- system(paste(cmd,testHdf),intern=TRUE),silent=TRUE)
                
    } else
    {
        cmd <- paste(opts$gdalPath,"gdalinfo",collapse="/",sep="")            
        testHdf  <- system.file("external", "sdunl.hdf", package="MODIS")
        try(test <- system(paste(cmd,testHdf),intern=TRUE),silent=TRUE)

    }
    
    if(length(grep(test,pattern="Driver: HDF4Image/HDF4 Dataset"))==0)
    {
        stop("Your GDAL installation or the path to your GDAL/bin directory is not valid, please set it using '?MODISoptions'")
    }

    out <- rep(NA,length(x))

    for (i in seq_along(x))
    {

        if (basename(x[i])=="NA" | is.na(basename(x[i])))
        {
            out[i] <- NA
        } else
        {
           if (dirname(x[i])==".")
            {
                x[i] <- paste(MODIS:::genString(x=x[i],remote=FALSE,...)$localPath, basename(x[i]), sep="/")        
            }
    
            if (!file.exists(x[i]))
            {
                out[i] <- NA
            } else
            {
            
                if (.Platform$OS.type=="windows")
                {
                    try(a <- system(paste(cmd," ",shortPathName(x[i]),sep=""),intern=TRUE),silent=TRUE)            
                } else
                {
                    try(a <- system(paste(cmd," ",x[i],sep=""), intern=TRUE), silent=TRUE)
                }
            
                if(length(grep(a,pattern="gdalinfo failed")==1) | length(a)==0)
                {
                    out[i] <- FALSE
                } else 
                {
                    out[i] <- TRUE
                }
            }
        }
    }
return(out)
}
    
    
    # Test gdal installation
    
        
    
