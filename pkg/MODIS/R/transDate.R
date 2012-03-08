# Author: Matteo Mattiuzzi, Anja Klisch, matteo.mattiuzzi@boku.ac.at
# Date : November 2011
# Licence GPL v3
  
transDate <- function(begin=NULL,end=NULL){
#########
if(is.null(begin)) {
	begin="1975.01.01" # maybe once MODIS package retrieves other data too!
	}

if (is.null(end)) {
	end="2025.12.31" # we have to remember or change it when the time has come ;)
} 

if (nchar(begin)==7) {
	Byear <- substr(begin,1,4)
	Bdoy  <- substr(begin,5,7)
	begin <- format(as.Date(as.numeric(Bdoy)-1,origin=paste(Byear,"-01-01",sep="")),"%Y.%m.%d")   
}
if (nchar(end)==7) {
	Eyear <- substr(end,1,4)
	Edoy  <- substr(end,5,7)
	end   <- format(as.Date(as.numeric(Edoy)-1,origin=paste(Eyear,"-01-01",sep="")),"%Y.%m.%d")  
}

divisor <- substr(begin,5,5)
begin   <- as.Date(begin,format=paste("%Y",divisor,"%m",divisor,"%d",sep=""))

if (is.na(begin)) {stop("\n'begin=",begin,"' is eighter wrong format (not:'YYYY.MM.DD') or a invalid date")}
	divisor <- substr(end,5,5)
	end     <- as.Date(end,format=paste("%Y",divisor,"%m",divisor,"%d",sep=""))
if (is.na(end)) {stop("\n'end=",end,"' is eighter wrong format (not:'YYYY.MM.DD') or a invalid date")}

if(end<begin){
	t     <- begin
	begin <- end 
	end   <- t	
	rm(t)
}

beginDOY <- format(as.Date(begin,format="%Y.%m.%d"), "%Y%j")
endDOY   <- format(as.Date(end,format="%Y.%m.%d"), "%Y%j")

return(list(begin=begin,end=end,beginDOY=beginDOY,endDOY=endDOY))
}





