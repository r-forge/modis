# Author: Matteo Mattiuzzi, Anja Klisch, matteo.mattiuzzi@boku.ac.at
# Date : November 2011
# Licence GPL v3
  
transDATE <- function(begin,end){
#########
if(missing(begin)) {
	begin="1975.01.01" # maybe once MODIS package retrieves other data too!
	}

if (missing(end)) {
	end="2025.12.31" # we have to remember or change it when the time has come ;)
} 

divisor <- substr(begin,5,5)
begin   <- as.Date(begin,format=paste("%Y",divisor,"%m",divisor,"%d",sep=""))
if (is.na(begin)) {stop("\n'begin=",begin,"' is eighter wrong format (not:'YYYY.MM.DD') or a invalid date")}
divisor <- substr(end,5,5)
end     <- as.Date(end,format=paste("%Y",divisor,"%m",divisor,"%d",sep=""))
if (is.na(end)) {stop("\n'end=",end,"' is eighter wrong format (not:'YYYY.MM.DD') or a invalid date")}

if(end<begin){
t <- begin
begin <- end 
end <- t
rm(t)
}
return(list(begin=begin,end=end))
}


