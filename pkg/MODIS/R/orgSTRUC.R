# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date: August 2011
# Licence GPL v3

orgSTRUC <- function(LocalArcPath,deep=FALSE,HdfName,to,move=TRUE,quiet=FALSE) {


if (missing(to)|(!to %in% c(1,2,3))) stop("Provide a valid 'to' argument!")

fsep <- .Platform$file.sep

if (missing(LocalArcPath)) {
	LocalArcPath <- normalizePath("~", winslash = fsep)
	LocalArcPath <- file.path(LocalArcPath,"MODIS_ARC",fsep=fsep)
		if(!quiet){
		cat(paste("No archive path set, using/creating standard archive in: ",LocalArcPath,"\n",sep=""))
		flush.console()
		}
}

LocalArcPath <- paste(strsplit(LocalArcPath,fsep)[[1]],collapse=fsep)# removes "/" or "\" on last position (if present)
dir.create(LocalArcPath,showWarnings=FALSE)
# test local LocalArcPath
try(testDir <- list.dirs(LocalArcPath),silent=TRUE)
if(!exists("testDir")) {stop("'LocalArcPath' not set properly")} 

if (missing(HdfName)) {cat(paste("No 'HdfName' pattern set, moving/coping all MODIS grid data found in '", LocalArcPath,"'.\n",sep=""))} 

#################

if(missing(HdfName)) {
		avFiles <- unlist(list.files(
						if(deep){
						"~"
						} else {
						LocalArcPath
						}
						,pattern="hdf",recursive=TRUE,full.names=TRUE))
	} else {
		avFiles <- unlist(list.files(
						if(deep){
						"~"
						} else {
						LocalArcPath
						}
						,pattern=HdfName,recursive=TRUE,full.names=TRUE))
	}


if (length(avFiles)==0) {stop("No HDF or HDF.XML files found! Maybe check 'LocalArcPath'\n")}
 
data("MODIS_Products")

# tests if MODIS-grid file(s) # maybe using regex methods it becomes much faster!
doit <- sapply(avFiles,function(x) {
	fname <- strsplit(x,fsep)[[1]] # separate name from path
	fname <- fname[length(fname)] # select filename
	secName  <- strsplit(fname,"\\.")[[1]] # decompose filename

	if(secName[1] %in% MODIS_Products[,1]) {
	info <- MODIS_Products[which(MODIS_Products[,1] == secName[1]),]
		
		PF <- substr(secName[1],1,3)
		Tpat <- "h[0-3][0-9]v[0-1][0-9]" # to enhance

		if(info[4]=="CMG" && (sum((substr(secName[2],1,1) == "A") + (PF %in% c("MOD","MYD","MCD"))) == 2 )) #? M[o,O,y,Y,c,C]D
			{ res <- TRUE }
		else if(info[4]=="Tile" && (sum((substr(secName[2],1,1) == "A") + (PF %in% c("MOD","MYD","MCD")) + (grep(secName[3],pattern=Tpat)))==3))
			{ res <- TRUE }
		else 
			{ res <- FALSE }
	
	} else { res <- FALSE }
	return(res)}
	)

avFiles <- avFiles[doit] 
cat("Found",length(avFiles),"files \n")

#########################
moved <- sapply(avFiles,function(x) {

	fname  <- strsplit(x,fsep)[[1]] # separate name from path
	orpath <- fname[-length(fname)]
	orpath <- paste(orpath,collapse=fsep)
	fname   <- fname[length(fname)] # select filename
	secName  <- strsplit(fname,"\\.")[[1]] # decompose filename

	########################
	# generate structure
	info    <- MODIS_Products[which(MODIS_Products[,1] == secName[1]),]
	basedir <- paste(secName[1],".",if (info[4]=="Tile"){secName[4]}else{secName[3]},sep="")
	fdate   <- substr(secName[2],2,nchar(secName[2]))
	fdate   <- as.Date(as.numeric(substr(fdate,5,nchar(fdate)))-1,origin=paste(substr(fdate,1,4),"-01-01",sep=""))
	year    <- format(fdate,format="%Y")
	fdate   <- gsub(x=fdate,"-",".")

	if (to==1) {path <- file.path(LocalArcPath,basedir,fsep=fsep)}
	if (to==2) {path <- file.path(LocalArcPath,basedir,year,fsep=fsep)}
	if (to==3) {path <- file.path(LocalArcPath,basedir,fdate,fsep=fsep)}

	dir.create(path,showWarnings=FALSE,recursive=TRUE)
	###################
	# move files

#if (orpath!=path) {
if (!file.exists(file.path(path,fname,fsep=fsep))) { # do nothing if file is already in dest dir 

		if (.Platform$OS.type == "unix" & move) {
			system(paste("mv ",x," ",path,sep=""))
			moved <- 1
		} else if (.Platform$OS.type == "windows" & move) {
			shell(gsub(fsep,"\\\\",paste("move ",x," ", path,sep="")),intern=TRUE)
			moved <- 1
		} else {
			file.copy(from=x,to=paste(path,fsep,fname,sep=""),overwrite=FALSE)
			moved <- 2

			if (file.exists(paste(path,fsep,fname,sep="")) &  move) {
				unlink(paste(orpath,fname,sep=""))
			moved <- 1
			}

		}
	} else if (file.exists(file.path(path,fname,fsep=fsep)) & orpath!=path) { # if file exists in destdir & inpath!=outPath...it is duplicated, so remove it
			unlink(x)
			moved <- 3
	} else {
			moved <- 0 }

	if (length(list.files(orpath))==0) {unlink(orpath,recursive=TRUE)} # delete emty dir
	return(moved)})

	cat("Moved files", sum(moved==1),"\n")
	cat("Copied files", sum(moved==2),"\n")
	cat("Not moved files", sum(moved==0),"\n")
	cat("Deleted multiple files", sum(moved==3),"\n")
}
#######################
