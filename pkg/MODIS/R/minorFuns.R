
# central setting for stubbornness
.stubborn <- function(level="high"){
if (is.numeric(level)) {
	sturheit <- level	
	} else {
	sturheit <- c(5,15,50,500,10000)[which(level==c("low","medium","high","veryhigh","extreme"))]
	}
}


