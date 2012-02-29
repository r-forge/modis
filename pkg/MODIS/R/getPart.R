# Author: Matteo Mattiuzzi, matteo.mattiuzzi@boku.ac.at
# Date : February 2012
# Licence GPL v3

################################
# getPATH takes as argument ONLY a .defineName() or a getProduct() result, or basicaly a vector with named "nodes"
################################
.getPart <- function(x , what = c("YYYY","DDD","DATE","SENSOR","PF1","PF2","PLATFORM","TILE","C","CCC","PRODUCT","FORMAT","COMPRESSION","DATE1DATE2","PROCESSINGDATE","REGION","TIME")){    
      if (missing(x)){return(cat("Available 'placeholders' are:",what,"\n",sep=" "))}
      
       what <- match.arg(what)
if(inherits(x,"vector")) {
       switch(what,
              YYYY = substring(x["DATE"],2,5), # works with AYYYYDDD input
              DDD  = substring(x["DATE"],6,8), # works with AYYYYDDD input
              DATE = gsub(transDate(begin=substring(x["DATE"],2,8),)$begin,pattern="-",replacement="."), # works with AYYYYDDD input
              SENSOR = product$SENSOR,
              PF1 = getProduct(x=x[1],quiet=TRUE)$PF1,
              PF2 = getProduct(x=x[1],quiet=TRUE)$PF2,
              PLATFORM = getProduct(x=x[1])$PLATFORM,
              TILE = x["TILE"],
              C = as.numeric(x["CCC"]),
              CCC = x["CCC"],
              PRODUCT = x["PRODUCT"],
              FORMAT = x["FORMAT"],
              COMPRESSION = x["COMPRESSION"],
              DATE1DATE2 = x["DATE1DATE2"],
              PROCESSINGDATE = x["PROCESSINGDATE"],
              #REGION = getTILE(x["TILE"]) # TODO get REGION by Tile
              REGION = "EuropeAfrica", # the only supported for now!
              TIME = x["TIME"]
              )
} else {
      switch(what,
              YYYY = substring(x$DATE,2,5), # works with AYYYYDDD input
              DDD  = substring(x$DATE,6,8), # works with AYYYYDDD input
              DATE = gsub(transDate(begin=substring(x$DATE,2,8),)$begin,pattern="-",replacement="."), # works with AYYYYDDD input
              SENSOR = product$SENSOR,
              PF1 = getProduct(x=x[1],quiet=TRUE)$PF1,
              PF2 = getProduct(x=x[1],quiet=TRUE)$PF2,
              PLATFORM = getProduct(x=x[1])$PLATFORM,
              TILE = x$TILE,
              C = as.numeric(x$CCC),
              CCC = x$CCC,
              PRODUCT = x$PRODUCT,
              FORMAT = x$FORMAT,
              COMPRESSION = x$COMPRESSION,
              DATE1DATE2 = x$DATE1DATE2,
              PROCESSINGDATE = x$PROCESSINGDATE,
              #REGION = getTILE(x$TILE) # TODO get REGION by Tile
              REGION = "EuropeAfrica", # the only supported for now!
              TIME = x$TIME
              )



}

}

