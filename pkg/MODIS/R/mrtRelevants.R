doHdflist <- function(HdfName)
{
    if (.Platform$OS=="unix")
    {
        sdsRaw <- system(paste("hdflist",HdfName,sep=" "),intern=TRUE)
    
    } else if (.Platform$OS=="windows")
    {
        sdsRaw <- shell(gsub(fsep,"\\\\",paste('hdflist "',HdfName,'"',sep="")),intern=TRUE)
    }
    p0 <- grep(pattern="numbertypes",x=sdsRaw)
    projCode <- grep(pattern="projcode",x=sdsRaw)
    projparm <- grep(pattern="projparm",x=sdsRaw)
    
    sds <- list()
    for (i in (p0+1):(projCode-1))
    {
        sds[[i]] <- strsplit(sdsRaw[i],":")[[1]][1]
    }
    sds <- unlist(sds)

    projCode <- strsplit(sdsRaw[projCode],",")[[1]]          
    
    projparam <- strsplit(sdsRaw[projparm],":")[[1]][2]         
    
    list(projparam = projparam,projcode=projCode,sds=sds)
}
