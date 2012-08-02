\name{file.size}

\docType{methods}

\alias{file.size}

\title{Size in Byte of file(s)}

\description{Function for getting size of any files.}
  
\usage{file.size(file,units="b")}

\arguments{
  \item{file}{Character vector of file(s) with path.}
  \item{units}{Character, default "b" bytes or alternative: "Kb", "Mb", "Gb" for kilo Bytes, mega Bytes and giga Bytes.}} 

\value{
  numeric Vector with the same length of available input files and the unit specified by argument 
}

\author{
  Matteo Mattiuzzi
}

\examples{
\dontrun{
file.size(list.files("./"))
}
}


