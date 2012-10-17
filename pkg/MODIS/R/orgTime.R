# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : August 2012
# Licence GPL v3

orgTime <- function(files,nDays="asIn",begin=NULL,end=NULL,pillow=75,pos1=10,pos2=16,format="%Y%j")
{

    if (inherits(files,"Raster"))
    {
        files <- names(files)    
    }
    files <- basename(files)
    
    allDates <- sort(extractDate(files,asDate=TRUE,pos1=pos1,pos2=pos2,format=format)$inputLayerDates)

    datLim   <- transDate(begin=begin,end=end)
    
    if (!is.null(begin))
    {
        minCalc <- datLim$begin
        minTheo <- minCalc - pillow
        minData <- min(allDates[allDates >= minTheo])
   
    } else 
    {
        minTheo <- minCalc <- minData <- min(allDates)
    }

    if (!is.null(end))
    {
        maxCalc <- datLim$end
        maxTheo <- (maxCalc + pillow)
        maxData <- max(allDates[allDates <= maxTheo])
    } else 
    {
        maxTheo <- maxCalc <- maxData <- max(allDates)
    }
    
    inputLayerDates <- allDates[allDates >= minData & allDates <= maxData]

    if (minTheo < minData)
    {
        if (as.numeric(minData - minTheo) >= pillow)
        {
            warning("'begin' - 'pillow' is earlier by, ",as.numeric(minData - minTheo) ," days, than the available input dates!\nPillow at the start of the time serie is reduced")
        } else if (minCalc == minData)
        {      
            warning("Is is not possible to use the pillow at the begin of the time series since there is no data available!")
        }
    }
    if (maxTheo > maxData)
    {
        warning("'end' + 'pillow' is later by, ",as.numeric(maxData - max(inputLayerDates)) ," days, than the available input dates!")
    }

    if (nDays=="asIn")
    {
        outputLayerDates <- inputLayerDates[datLim$begin <= inputLayerDates & datLim$end > inputLayerDates]
    } else 
    {
        outputLayerDates <- seq(minCalc,maxCalc,by=nDays)
    }
    
    t0     <- min(outputLayerDates,inputLayerDates)
    inSeq  <- as.numeric(inputLayerDates - t0+1)
    outSeq <- as.numeric(outputLayerDates - t0+1)

    return(list(inSeq=inSeq,outSeq=outSeq,inputLayerDates=inputLayerDates,outputLayerDates=outputLayerDates,pos1=pos1,pos2=pos2,format=format,asDate=TRUE))        
}




