###############################################################################
#
#                       Copyright (c) 2011-2019
#         Manuel Lopez-Ibanez <manuel.lopez-ibanez@manchester.ac.uk>
#                Marco Chiarandini <marco@imada.sdu.dk>
#
# This program is free software (software libre); you can redistribute
# it and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, you can obtain a copy of the GNU
# General Public License at http://www.gnu.org/copyleft/gpl.html
#
# IMPORTANT NOTE: Please be aware that the fact that this program is
# released as Free Software does not excuse you from scientific
# propriety, which obligates you to give appropriate credit! If you
# write a scientific paper describing research that made substantive use
# of this program, it is your obligation as a scientist to (a) mention
# the fashion in which this software was used in the Methods section;
# (b) mention the algorithm in the References section. The appropriate
# citation is:
# 
#    Manuel Lopez-Ibanez, Luis Paquete, and Thomas Stuetzle.
#    Exploratory Analysis of Stochastic Local Search Algorithms in
#    Biobjective Optimization. In T. Bartz-Beielstein, M. Chiarandini,
#    L. Paquete, and M. Preuss, editors, Experimental Methods for the
#    Analysis of Optimization Algorithms, pages 209-222. Springer,
#    Berlin, Germany, 2010. doi: 10.1007/978-3-642-02538-9_9
# 
# Moreover, as a personal note, I would appreciate it if you would email
# manuel.lopez-ibanez@manchester.ac.uk with citations of papers referencing
# this work so I can mention them to my funding agent and tenure committee.
#
################################################################################
#
# TODO:
#
#  * Follow this style for coding:
#    http://google-styleguide.googlecode.com/svn/trunk/google-r-style.html
#
################################################################################
#dyn.load("../src/eaf.so")

check.eaf.data <- function(x)
{
  name <- deparse(substitute(x))
  if (length(dim(x)) != 2L)
    stop("'", name, "' must be a data.frame or a matrix")
  if (nrow(x) < 1L)
    stop("not enough points (rows) in '", name, "'")
  if (ncol(x) < 3)
    stop("'", name, "' must have at least 3 columns: 2D points and set index")
  # Re-encode the sets so that they are consecutive and numeric
  setcol <- ncol(x)
  x[, setcol] <- as.numeric(as.factor(x[, setcol]))
  x <-  as.matrix(x)
  if (!is.numeric(x))
    stop("The two first columns of '", name, "' must be numeric")
  return(x)
}

compute.eaf <- function(data, percentiles = NULL)
{
  data <- check.eaf.data(data)
  setcol <- ncol(data)
  nobjs <- setcol - 1L
  # The C code expects points within a set to be contiguous.
  data <- data[order(data[, setcol]), , drop=FALSE]
  sets <- data[, setcol]
  nsets <- length(unique(sets))
  npoints <- tabulate(sets)
  if (is.null(percentiles)) {
    # FIXME: We should compute this in the C code.
    percentiles <- 1L:nsets * 100.0 / nsets
  }
  # FIXME: We should handle only integral levels inside the C code. 
  percentiles <- unique.default(sort.int(percentiles))
  return(.Call(compute_eaf_C,
               as.double(t(as.matrix(data[, 1L:nobjs]))),
               as.integer(nobjs),
               as.integer(cumsum(npoints)),
               as.integer(nsets),
               as.numeric(percentiles)))
}

compute.eaf.as.list <- function(data, percentiles = NULL)
{
  eaf <- compute.eaf (data, percentiles = percentiles)
  setcol <- ncol(eaf)
  nobjs <- setcol - 1L
  eaf_sets <- eaf[, setcol]
  uniq_eaf_sets <- unique.default(eaf[, setcol])
  return(split.data.frame(eaf[,1:nobjs, drop=FALSE],
                          factor(eaf_sets,
                                 levels = uniq_eaf_sets,
                                 labels = uniq_eaf_sets)))
}

compute.eafdiff.helper <- function(data, intervals)
{
  # Last column is the set number.
  setcol <- ncol(data)
  nobjs <- setcol - 1L
  # the C code expects points within a set to be contiguous.
  data <- data[order(data[, setcol]), ]
  sets <- data[, setcol]
  nsets <- length(unique(sets))
  npoints <- tabulate(sets)
  # FIXME: Ideally this would be computed by the C code, but it is hard-coded.
  ## division <- nsets %/% 2
  ## nsets1 <- division
  ## nsets2 <- nsets - division
  return(.Call(compute_eafdiff_C,
                as.double(t(as.matrix(data[, 1L:nobjs]))),
                nobjs,
                as.integer(cumsum(npoints)),
                as.integer(nsets),
                as.integer(intervals)))
}

#' Compute empirical attainment function differences 
#' 
#' Calculate the differences between the empirical attainment functions of two
#' data sets.
#' 
#' @param x,y Data frames corresponding to the input data of
#'   left and right sides, respectively. Each data frame has at least three
#'   columns, the third one being the set of each point. See also
#'   [read_datasets()].
#'
#' @param intervals (`integer(1)`) \cr The absolute range of the differences
#'   \eqn{[0, 1]} is partitioned into the number of intervals provided.
#' 
#' @template arg_maximise
#'
#' @param rectangles If TRUE, the output is in the form of rectangles of the same color.
#' 
#' @details
#'   This function calculates the differences between the EAFs of two
#'   data sets.
#'
#' @return With `rectangle=FALSE`, a `data.frame` containing points where there
#'   is a transition in the value of the EAF differences.  With
#'   `rectangle=TRUE`, a `matrix` where the first 4 columns give the
#'   coordinates of two corners of each rectangle and the last column. In both
#'   cases, the last column gives the difference in terms of sets in `x` minus
#'   sets in `y` that attain each point (i.e., negative values are differences
#'   in favour `y`).
#' 
#' @seealso    [read_datasets()], [eafdiffplot()]
#' 
#' @examples
#'
#' A1 <- read_datasets(text='
#'  3 2
#'  2 3
#'  
#'  2.5 1
#'  1 2
#'  
#'  1 2
#' ')
#' A2 <- read_datasets(text='
#'  4 2.5
#'  3 3
#'  2.5 3.5
#'  
#'  3 3
#'  2.5 3.5
#'  
#'  2 1
#' ')
#' d <- eafdiff(A1, A2)
#' str(d)
#' print(d)
#'
#' d <- eafdiff(A1, A2, rectangles = TRUE)
#' str(d)
#' print(d)
#'
#'@concept eaf
#'@export
eafdiff <- function(x, y, intervals = NULL, maximise = c(FALSE, FALSE),
                    rectangles = FALSE)
{
  maximise <- as.logical(maximise)
  nsets <- (length(unique(x[,ncol(x)])) + length(unique(y[,ncol(y)])))
  if (is.null(intervals)) {
    # Default is nsets / 2
    intervals <- nsets / 2.0
  } else {
    stopifnot(length(intervals) == 1L)
    intervals <- min(intervals, nsets / 2.0)
  }

  data <- rbind_datasets(x, y)
  data <- check.eaf.data(data)
  # FIXME: Is it faster to subset or to multiply the third column by 1?
  data[,1:2] <- matrix.maximise(data[,1:2, drop=FALSE], maximise = maximise)
  
  DIFF <- if (rectangles) compute.eafdiff.rectangles(data, intervals = intervals)
          else compute.eafdiff.helper(data, intervals = intervals)
  # FIXME: We should remove duplicated rows in C code.

  # FIXME: Check that we do not generate duplicated nor overlapping rectangles
  # with different colors. That would be a bug.
  DIFF <- DIFF[!duplicated(DIFF),]
  return(DIFF)
}

compute.eafdiff <- function(data, intervals)
{
  DIFF <- compute.eafdiff.helper(data, intervals)
  #print(DIFF)
  # FIXME: Do this computation in C code. See compute_eafdiff_area_C
  setcol <- ncol(data)
  eafval <- DIFF[, setcol]
  eafdiff <- list(left  = unique(DIFF[ eafval >= 1L, , drop=FALSE]),
                  right = unique(DIFF[ eafval <= -1L, , drop=FALSE]))
  eafdiff$right[, setcol] <- -eafdiff$right[, setcol]
  return(eafdiff)
}


# FIXME: The default intervals should be nsets / 2
compute.eafdiff.rectangles <- function(data, intervals = 1L)
{
  # Last column is the set number.
  nobjs <- ncol(data) - 1L
  # the C code expects points within a set to be contiguous.
  data <- data[order(data[, nobjs + 1L]), ]
  sets <- data[ , nobjs + 1L]
  nsets <- length(unique(sets))
  npoints <- tabulate (sets)
  return(.Call(compute_eafdiff_rectangles_C,
               as.double(t(as.matrix(data[, 1L:nobjs]))),
               nobjs,
               as.integer(cumsum(npoints)),
               as.integer(nsets),
               as.integer(intervals)))
}

# FIXME: The default intervals should be nsets / 2
compute.eafdiff.polygon <- function(data, intervals = 1L)
{
  # Last column is the set number.
  nobjs <- ncol(data) - 1L
  # the C code expects points within a set to be contiguous.
  data <- data[order(data[, nobjs + 1L]), ]
  sets <- data[ , nobjs + 1L]
  nsets <- length(unique(sets))
  npoints <- tabulate(sets)
  # FIXME: Ideally this would be computed by the C code, but it is hard-coded.
  ## division <- nsets %/% 2
  ## nsets1 <- division
  ## nsets2 <- nsets - division
  # FIMXE: This function may require a lot of memory for 900 sets. Is there a
  # way to save memory?
  return(.Call(compute_eafdiff_area_C,
               as.double(t(as.matrix(data[, 1L:nobjs]))),
               nobjs,
               as.integer(cumsum(npoints)),
               as.integer(nsets),
               as.integer(intervals)))
}


rm.inf <- function(x, xmax)
{
  x[is.infinite(x)] <- xmax
  return(x)
}


# FIXME: Accept ...
max.finite <- function (x)
{
  x <- as.vector(x)
  x <- x[is.finite(x)]
  if (length(x)) return(max(x))
  return(NULL)
}

# FIXME: Accept ...
min.finite <- function (x)
{
  x <- as.vector(x)
  x <- x[is.finite(x)]
  if (length(x)) return(min(x))
  return(NULL)
}

# FIXME: Accept ...
range.finite <- function(x)
{
  x <- as.vector(x)
  x <- x[is.finite(x)]
  if (length(x)) return(range(x))
  return(NULL)
}

matrix.maximise <- function(z, maximise)
{
  stopifnot(ncol(z) == length(maximise))
  if (is.data.frame(z)) {
    # R bug?: If z is data.frame with rownames != NULL, and
    # maximise == (FALSE, FALSE), then -z[, which(FALSE)]
    # gives error: Error in
    # data.frame(value, row.names = rn, check.names = FALSE, check.rows = FALSE) : 
    # row names supplied are of the wrong length
    row_names <- rownames(z)
    rownames(z) <- NULL
    x <- which(maximise)
    z[, x] <- -z[, x]
    rownames(z) <- row_names
  } else {
    x <- ifelse(maximise, -1L, 1L)
    z <- t(t(z) * x)
  }
  return(z)
}


rbind_datasets <- function(x,y)
{
  stopifnot(min(x[,3]) == 1)
  stopifnot(min(y[,3]) == 1)
  # We have to make all sets unique.
  y[,3] <- y[,3] + max(x[,3])
  rbind(x, y)
}

## Calculate the intermediate points in order to plot a staircase-like
## polygon.
## Example: given ((1,2), (2,1)), it returns ((1,2), (2,2), (2,1)).
## Input should be already in the correct order.
points.steps <- function(x)
{
  n <- nrow(x)
  if (n == 1L) return(x)
  x <- rbind(x, cbind(x=x[-1L, 1L, drop=FALSE], y=x[-n, 2L, drop=FALSE]))
  idx <- c(as.vector(outer(c(0L, n), 1L:(n - 1L), "+")), n)
  stopifnot(length(idx) == nrow(x))
  stopifnot(!anyDuplicated(idx))
  x[idx, ]
}



#' Exact computation of the EAF in 2D or 3D
#'
#' This function computes the EAF given a set of 2D or 3D points and a vector `set`
#' that indicates to which set each point belongs.
#'
#' @param points Either a matrix or a data frame of numerical values, where
#'   each row gives the coordinates of a point.
#' 
#' @param sets A vector indicating which set each point belongs to.
#'
#' @param groups Indicates that the EAF must be computed separately for data
#'   belonging to different groups.
#'
#' @param percentiles (`numeric()`) Vector indicating which percentiles are computed.
#' `NULL` computes all.
#'
#' @return  A data frame (`data.frame`) containing the exact representation
#'  of EAF. The last column gives the percentile that corresponds to each
#'  point. If groups is not `NULL`, then an additional column
#'  indicates to which group the point belongs.
#'
#' @author  Manuel \enc{López-Ibáñez}{Lopez-Ibanez}
#'
#'@note There are several examples of data sets in `system.file(package="eaf","extdata")`. The current implementation only supports two and three dimensional points.
#'
#' @references
#' 
#' \insertRef{Grunert01}{eaf}
#'
#' \insertRef{FonGueLopPaq2011emo}{eaf}
#'  
#'@seealso [read_datasets()]
#'
#'@examples
#' extdata_path <- system.file(package="eaf", "extdata")
#' 
#' x <- read_datasets(file.path(extdata_path, "example1_dat"))
#' # Compute full EAF
#' str(eafs(x[,1:2], x[,3]))
#' 
#' # Compute only best, median and worst
#' str(eafs(x[,1:2], x[,3], percentiles = c(0, 50, 100)))
#'
#' x <- read_datasets(file.path(extdata_path, "spherical-250-10-3d.txt"))
#' y <- read_datasets(file.path(extdata_path, "uniform-250-10-3d.txt"))
#' x <- rbind(data.frame(x, groups = "spherical"),
#'            data.frame(y, groups = "uniform"))
#' # Compute only median separately for each group
#' z <- eafs(x[,1:3], sets = x[,4], groups = x[,5], percentiles = 50)
#' str(z)
#' # library(plotly)
#' # plot_ly(z, x = ~X1, y = ~X2, z = ~X3, color = ~groups,
#' #         colors = c('#BF382A', '#0C4B8E')) %>% add_markers()
#'@concept eaf
#'@export
eafs <- function (points, sets, groups = NULL, percentiles = NULL)
{
  if (!is.numeric(sets)) {
    if (is.factor(sets)) sets <- as.numeric(levels(sets))[sets]
    else sets <- suppressWarnings(as.numeric(sets))
  }
  if (anyNA(sets)) stop("'sets' must have only non-NA numerical values")
  
  points <- cbind(points, sets)
  if (is.null(groups)) {
    attsurfs <- compute.eaf (points, percentiles)
  } else {
    attsurfs <- data.frame()
    groups <- factor(groups)
    for (g in levels(groups)) {
      tmp <- compute.eaf(points[groups == g,], percentiles)
      attsurfs <- rbind(attsurfs, data.frame(tmp, groups = g))
    }
  }
  attsurfs
}


# Get correct xlim or ylim when maximising / minimising.
get.xylim <- function(lim, maximise, data)
{
  # FIXME: This seems too complicated.
  if (!is.null(lim) && maximise) lim <- -lim 
  if (is.null(lim)) lim <- range(data)
  if (maximise) lim <- range(-lim)
  lim
}
  
get.extremes <- function(xlim, ylim, maximise, log)
{
  if (length(log) && log != "")
    log <- strsplit(log, NULL)[[1L]]
  if ("x" %in% log) xlim <- log(xlim)
  if ("y" %in% log) ylim <- log(ylim)
  
  extreme1 <- ifelse(maximise[1],
                     xlim[1] - 0.05 * diff(xlim),
                     xlim[2] + 0.05 * diff(xlim))
  extreme2 <- ifelse(maximise[2],
                     ylim[1] - 0.05 * diff(ylim),
                     ylim[2] + 0.05 * diff(ylim))
  
  if ("x" %in% log) extreme1 <- exp(extreme1)
  if ("y" %in% log) extreme2 <- exp(extreme2)
  c(extreme1, extreme2)
}

add.extremes <- function(x, extremes, maximise)
{
  best1 <- if (maximise[1]) max else min
  best2 <- if (maximise[2]) max else min
  rbind(c(best1(x[,1]), extremes[2]), x, c(extremes[1], best2(x[,2])))
}

#' Convert a list of attainment surfaces to a data.frame
#'
#' Convert a list of attainment surfaces to a single data.frame.
#'
#' @param x (`list()`) List of data.frames or matrices. The names of the list
#'   give the percentiles of the attainment surfaces.  This is the format
#'   returned by [eafplot()] (and the internal function `compute.eaf.as.list`).
#'
#' @return A data.frame with as many columns as objectives and an additional column `percentiles`.
#'
#' @examples
#'
#' data(SPEA2relativeRichmond)
#' attsurfs <- eafplot (SPEA2relativeRichmond, percentiles = c(0,50,100),
#'                      xlab = expression(C[E]), ylab = "Total switches",
#'                      lty=0, pch=21, xlim = c(90, 140), ylim = c(0, 25))
#' attsurfs <- attsurf2df(attsurfs)
#' text(attsurfs[,1:2], labels = attsurfs[,3], adj = c(1.5,1.5))
#' 
#' @concept eaf
#' @export
attsurf2df <- function(x)
{
  if (!is.list(x) || is.data.frame(x))
    stop("'x' must be a list of data.frames or matrices")

  percentiles <- as.numeric(names(x))
  percentiles <- rep.int(percentiles, sapply(x, nrow))
  x <- do.call("rbind", x)
  # Remove duplicated points (keep only the higher values)
  uniq <- !duplicated(x, fromLast = TRUE)
  cbind(x[uniq, , drop = FALSE], percentiles = percentiles[uniq])
}


### Local Variables:
### ess-indent-level: 2
### ess-continued-statement-offset: 2
### ess-brace-offset: 0
### ess-expression-offset: 4
### ess-else-offset: 0
### ess-brace-imaginary-offset: 0
### ess-continued-brace-offset: 0
### ess-arg-function-offset: 2
### ess-close-brace-offset: 0
### indent-tabs-mode: nil
### ess-fancy-comments: nil
### End:
