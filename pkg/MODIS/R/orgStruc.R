# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3

orgStruc <- function(source=.getDef("localArcPath"),to=.getDef("localArcPath"),structure=.getDef('arcStructure'),pattern,move=TRUE,quiet=FALSE) {	
	
source <- path.expand(source)
###########################

if(missing(pattern)) {
	cat(paste("No 'pattern' set, moving/coping all MODIS grid data found in '", source,"'.\n",sep=""))
		avFiles <- unlist(list.files(source,pattern=".hdf$",recursive=TRUE,full.names=TRUE))
	} else {
		avFiles <- unlist(list.files(source,pattern=pattern,recursive=TRUE,full.names=TRUE))
	}

if (length(avFiles)==0) {stop("No HDF nor HDF.XML files found!\n")}
 
data("MODIS_Products")

doit <- .isSupported(avFiles)
if (sum(doit)==0) {stop("No supported files Found")}
avFiles <- avFiles[doit]

if (!quiet){
	cat("Found",length(avFiles),"files \n")
}
#########################
moved <- sapply(avFiles,function(x) {

	orpath  <- dirname(x)
	fname   <- basename(x)

	########################
	# generate structure
	path <- MODIS:::.genSTRING(fname,remote=FALSE)$localPath
	dir.create(path,showWarnings=FALSE,recursive=TRUE)
	###################

if (!file.exists(file.path(path,fname,fsep="/"))) { # do nothing if file is already in dest dir 

		if (move) {
			file.rename(from=x,to=paste(path,"/",fname,sep=""))			
			moved <- 1
		} else {
			file.copy(from=x,to=paste(path,"/",fname,sep=""),overwrite=FALSE)
			moved <- 2
		}

	} else if (file.exists(file.path(path,fname,fsep="/")) & orpath!=path) { # if file exists in destdir & inpath!=outPath...it is duplicated in 2 different locations, so remove it
			unlink(x)
			moved <- 3
	} else {
			moved <- 0
	}
	if (length(list.files(orpath))==0) {unlink(orpath,recursive=TRUE)} # delete empty dir
	
	return(moved)
	})
	
	if (sum(moved==0)==length(avFiles)) {
		cat("All files in the query are fine, no files to move or to copy!\n") 
	} else {
		cat("Moved files", sum(moved==1),"\n")
		cat("Copied files", sum(moved==2),"\n")
		cat("Not moved files", sum(moved==0),"\n")
		cat("Deleted multiple files", sum(moved==3),"\n")
	}
}
#######################
