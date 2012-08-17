timeOrg <- function(files,nDays=10,begin=NULL,end=NULL,pos1=10,pos2=16,format="%Y%j")
{

    if (inherits(files,"Raster"))
    {
        files <- names(files)    
    }
    
    files <- basename(files)
    dates <- extractDate(files,pos1=pos1,pos2=pos2,asDate=TRUE,format=format)
    dates <- sort(dates)
    layerDates <- unique(dates)


    if (is.null(begin))
    {
        begin <- min(dates)         
    }
    if (is.null(end))
    {
        end <- max(dates)
    }

    dat   <- transDate(begin=begin,end=end) 
    begin <- as.Date(dat$begin)
    end   <- as.Date(dat$end)
     
    #outD <- layerDates <- dates[dates >= dat$begin & dates <= dat$end]
    if (begin < min(dates))
    {
        warning("'begin' is earlier by, ",as.numeric(min(dates) - begin) ," days, than the available input dates!")
    }
    if (end > max(dates))
    {
        warning("'end' is later by, ",as.numeric(end - max(dates)) ," days, than the available dates dates!")
    }

    # egualise the in and out "doys"
    layerDates <- seq(begin,end,by=nDays)
    
    t0 <- min(layerDates,dates)
    inSeq <- as.numeric(dates - t0+1)
    outSeq <- as.numeric(layerDates - t0+1)

    return(list(inSeq=inSeq,outSeq=outSeq,inputLayerDates=dates,outputLayerDates=layerDates))        
}

