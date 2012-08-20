orgTime <- function(files,nDays=16,begin=NULL,end=NULL,pillow=75,pos1=10,pos2=16,format="%Y%j")
{

    if (inherits(files,"Raster"))
    {
        files <- names(files)    
    }
    files <- basename(files)
    
    allDates <- sort(extractDate(files,asDate=TRUE,pos1=pos1,pos2=pos2,format=format)$dates)

    datLim   <- transDate(begin=begin,end=end)
    
    if (!is.null(begin))
    {
        minCalc <- datLim$begin
        minTheo <- minCalc - pillow
        minData <- max(allDates[allDates <= minTheo])
    } else 
    {
        minCalc <- minData <- min(allDates)
    }

    if (!is.null(end))
    {
        maxCalc <- datLim$end
        maxTheo <- (maxCalc + pillow)
        maxData <- min(allDates[allDates >= maxTheo])
    } else 
    {
        maxCalc <- maxData <- max(allDates)
    }
    
    inputLayerDates <- allDates[allDates >= minData & allDates <= maxData]

    if (minTheo < minData)
    {
        if (as.numeric(minData - minTheo) >= pillow)
        {
            warning("'begin' - 'pillow' is earlier by, ",as.numeric(minData - minTheo) ," days, than the available input dates!\nPillow at the start of the time serie is reduced")
        } else if (minCalc == minData)
        {      
            warning("Is is not possible to use the pillow at the begin of the time serie!")
        }
    }
    if (maxTheo > maxData) # TODO check and enhance the warning!
    {
        warning("'end' + 'pillow' is later by, ",as.numeric(maxData - max(inputLayerDates)) ," days, than the available input dates!")
    }

    # equalise the in and out "doys"
    outputLayerDates <- seq(minCalc,maxCalc,by=nDays)
    
    t0     <- min(outputLayerDates,inputLayerDates)
    inSeq  <- as.numeric(inputLayerDates - t0+1)
    outSeq <- as.numeric(outputLayerDates - t0+1)

    return(list(inSeq=inSeq,outSeq=outSeq,inputLayerDates=inputLayerDates,outputLayerDates=outputLayerDates,pos1=pos1,pos2=pos2,format=format))        
}




