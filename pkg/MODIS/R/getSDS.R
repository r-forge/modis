getSDS <- function(HdfName,SDSstring,MRTpath="check") {
######
fsep <- .Platform$file.sep

if (MRTpath=="check") {
	MRTpath <- getPATH(quiet=TRUE)
	}

if (!file.exists(MRTpath)) {stop("'MRTpath' is wrong or MRT not installed? Provide a good path, leave empty or run 'getPATH()' first!")}

if (!file.exists(HdfName)) {
	cat("Hm, I have to search for the file! Next time provide the full path and I'll be very fast!\n")
	HdfName <- normalizePath(list.files(path="~/",pattern=paste(HdfName,"$",sep=""),recursive=TRUE,full.names = TRUE),winslash=fsep)
	}
	
	HdfName <- HdfName[1]
	
if (.Platform$OS=="unix"){
	sdsRaw <- system(paste(file.path(MRTpath,"sdslist",fsep=fsep),HdfName,sep=" "),intern=TRUE)
	
}else if (.Platform$OS=="windows"){
	sdsRaw <- shell(gsub(fsep,"\\\\",paste(file.path(MRTpath,"sdslist",fsep=fsep),HdfName,sep=" ")),intern=TRUE)

} else {
	stop(cat("What OS have you? Please tell me so I can fix this.\n")) 
}

sds <- list()
for (i in 1:length(sdsRaw)){
sds[[i]] <- substr(sdsRaw[i],1,11) == "SDgetinfo: "
}
sds <- sdsRaw[unlist(sds)]
sds <- unlist(lapply(sds,function(x){strsplit(x,": ")[[1]][2]}))
sds <- unlist(lapply(sds,function(x){paste(strsplit(x,", ")[[1]][1:2],collapse=": ")}))

if (!missing(SDSstring)){
	if (inherits(SDSstring,"list")) {
		SDSstring <- paste(SDSstring$SDSstring,collapse="")
		}

SDSstring <- gsub(pattern=" ",replacement="",x=SDSstring) # collapse the spaces

	if (nchar(SDSstring)!= length(sds)) {
		warning("The file has ",length(sds)," layers (SDS), your SDSstring has length ",nchar(SDSstring),"!\nThe string is auto-completed!")
		}
				
	msk <- rep(FALSE,length(sds))
	for (o in 1:length(sds)){
	msk[o] <- substr(SDSstring,o,o)==1
	}
return(list(SDSnames = sds[msk],SDSstring = paste(as.numeric(msk),collapse=" ")))
	} else {
return(sds)}
}
