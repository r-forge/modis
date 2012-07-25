# since I currently use this functions purely for the generate the color.legend() in arcStats(...,asMap=TRUE,...) I didn't want to put the package as required. If I find a simpler solution for a similar legend, or I integrate the plotrix functions on more places this will change accordingly.
############################### 
# All the functions here are copied from package plotrix version 3.4-2
# that is released under GPL (>=2)
#################

color.legend <- function (xl, yb, xr, yt, legend, rect.col, cex = 1, align = "lt", 
    gradient = "x", ...) 
{
    oldcex <- par("cex")
    par(xpd = TRUE, cex = cex)
    gradient.rect(xl, yb, xr, yt, col = rect.col, nslices = length(rect.col), 
        gradient = gradient)
    if (gradient == "x") {
        xsqueeze <- (xr - xl)/(2 * length(rect.col))
        textx <- seq(xl + xsqueeze, xr - xsqueeze, length.out = length(legend))
        if (match(align, "rb", 0)) {
            texty <- yb - 0.2 * strheight("O")
            textadj <- c(0.5, 1)
        }
        else {
            texty <- yt + 0.2 * strheight("O")
            textadj <- c(0.5, 0)
        }
    }
    else {
        ysqueeze <- (yt - yb)/(2 * length(rect.col))
        texty <- seq(yb + ysqueeze, yt - ysqueeze, length.out = length(legend))
        if (match(align, "rb", 0)) {
            textx <- xr + 0.2 * strwidth("O")
            textadj <- c(0, 0.5)
        }
        else {
            textx <- xl - 0.2 * strwidth("O")
            textadj <- c(1, 0.5)
        }
    }
    text(textx, texty, labels = legend, adj = textadj, ...)
    par(xpd = FALSE, cex = oldcex)
}


gradient.rect <- function (xleft, ybottom, xright, ytop, reds, greens, blues, 
    col = NULL, nslices = 50, gradient = "x", border = par("fg")) 
{
    if (is.null(col)) 
        col <- color.gradient(reds, greens, blues, nslices)
    else nslices <- length(col)
    nrect <- max(unlist(lapply(list(xleft, ybottom, xright, ytop), 
        length)))
    if (nrect > 1) {
        if (length(xleft) < nrect) 
            xleft <- rep(xleft, length.out = nrect)
        if (length(ybottom) < nrect) 
            ybottom <- rep(ybottom, length.out = nrect)
        if (length(xright) < nrect) 
            xright <- rep(xright, length.out = nrect)
        if (length(ytop) < nrect) 
            ytop <- rep(ytop, length.out = nrect)
        for (i in 1:nrect) gradient.rect(xleft[i], ybottom[i], 
            xright[i], ytop[i], reds, greens, blues, col, nslices, 
            gradient, border = border)
    }
    else {
        if (gradient == "x") {
            xinc <- (xright - xleft)/nslices
            xlefts <- seq(xleft, xright - xinc, length = nslices)
            xrights <- xlefts + xinc
            rect(xlefts, ybottom, xrights, ytop, col = col, lty = 0)
            rect(xlefts[1], ybottom, xrights[nslices], ytop, 
                border = border)
        }
        else {
            yinc <- (ytop - ybottom)/nslices
            ybottoms <- seq(ybottom, ytop - yinc, length = nslices)
            ytops <- ybottoms + yinc
            rect(xleft, ybottoms, xright, ytops, col = col, lty = 0)
            rect(xleft, ybottoms[1], xright, ytops[nslices], 
                border = border)
        }
    }
    invisible(col)
}


color.gradient <- function (reds, greens, blues, nslices = 50) 
{
    return(color.scale(1:nslices, reds, greens, blues))
}


color.scale <- function (x, cs1 = c(0, 1), cs2 = c(0, 1), cs3 = c(0, 1), alpha = 1, 
    extremes = NA, na.color = NA, xrange = NULL, color.spec = "rgb") 
{
    naxs <- is.na(x)
    if (!is.na(extremes[1])) {
        colmat <- col2rgb(extremes)
        cs1 <- colmat[1, ]/255
        cs2 <- colmat[2, ]/255
        cs3 <- colmat[3, ]/255
        color_spec <- "rgb"
    }
    maxcs1 <- ifelse(color.spec == "hcl", 360, 1)
    maxcs2 <- ifelse(color.spec == "hcl", 100, 1)
    maxcs3 <- ifelse(color.spec == "hcl", 100, 1)
    ncolors <- length(x)
    if (is.null(xrange)) {
        xrange <- range(x, na.rm = TRUE)
        drop.extremes <- FALSE
    }
    else {
        if (xrange[1] > min(x, na.rm = TRUE) || xrange[2] < max(x, 
            na.rm = TRUE)) 
            stop("An explicit range for x must include the range of x values.")
        x <- c(xrange, x)
        drop.extremes = TRUE
    }
    ncs1 <- length(cs1)
    if (ncs1 > 1) {
        cs1s <- rep(cs1[ncs1], ncolors)
        xstart <- xrange[1]
        xinc <- diff(xrange)/(ncs1 - 1)
        for (seg in 1:(ncs1 - 1)) {
            segindex <- which((x >= xstart) & (x <= (xstart + 
                xinc)))
            cs1s[segindex] <- rescale(x[segindex], cs1[c(seg, 
                seg + 1)])
            xstart <- xstart + xinc
        }
        if (min(cs1s) < 0 || max(cs1s) > maxcs1) 
            cs1s <- rescale(cs1s, c(0, maxcs1))
    }
    else cs1s <- rep(cs1, ncolors)
    ncs2 <- length(cs2)
    if (ncs2 > 1) {
        cs2s <- rep(cs2[ncs2], ncolors)
        xstart <- xrange[1]
        xinc <- diff(xrange)/(ncs2 - 1)
        for (seg in 1:(ncs2 - 1)) {
            segindex <- which((x >= xstart) & (x <= (xstart + 
                xinc)))
            cs2s[segindex] <- rescale(x[segindex], cs2[c(seg, 
                seg + 1)])
            xstart <- xstart + xinc
        }
        if (min(cs2s) < 0 || max(cs2s) > maxcs2) 
            cs2s <- rescale(cs2s, c(0, maxcs2))
    }
    else cs2s <- rep(cs2, ncolors)
    ncs3 <- length(cs3)
    if (ncs3 > 1) {
        cs3s <- rep(cs3[ncs3], ncolors)
        xstart <- xrange[1]
        xinc <- diff(xrange)/(ncs3 - 1)
        for (seg in 1:(ncs3 - 1)) {
            segindex <- which((x >= xstart) & (x <= (xstart + 
                xinc)))
            cs3s[segindex] <- rescale(x[segindex], cs3[c(seg, 
                seg + 1)])
            xstart <- xstart + xinc
        }
        if (min(cs3s) < 0 || max(cs3s) > maxcs3) 
            cs3s <- rescale(cs3s, c(0, maxcs3))
    }
    else cs3s <- rep(cs3, ncolors)
    if (drop.extremes) {
        cs1s <- cs1s[-(1:2)]
        cs2s <- cs2s[-(1:2)]
        cs3s <- cs3s[-(1:2)]
    }
    xdim <- dim(x)
    colors <- do.call(color.spec, list(cs1s, cs2s, cs3s, alpha = alpha))
    if (!is.null(xdim)) 
        colors <- matrix(colors, nrow = xdim[1])
    if (length(naxs)) 
        colors[naxs] <- na.color
    return(colors)
}

rescale <- function (x, newrange) 
{
    if (missing(x) | missing(newrange)) {
        usage.string <- paste("Usage: rescale(x,newrange)\n", 
            "\twhere x is a numeric object and newrange is the new min and max\n", 
            sep = "", collapse = "")
        stop(usage.string)
    }
    if (is.numeric(x) && is.numeric(newrange)) {
        xna <- is.na(x)
        if (all(xna)) 
            return(x)
        if (any(xna)) 
            xrange <- range(x[!xna])
        else xrange <- range(x)
        if (xrange[1] == xrange[2]) 
            return(x)
        mfac <- (newrange[2] - newrange[1])/(xrange[2] - xrange[1])
        return(newrange[1] + (x - xrange[1]) * mfac)
    }
    else {
        warning("Only numeric objects can be rescaled")
        return(x)
    }
}

