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

check_eaf_data <- function(x)
{
  name <- deparse(substitute(x))
  if (length(dim(x)) != 2L)
    stop("'", name, "' must be a data.frame or a matrix")
  if (nrow(x) < 1L)
    stop("not enough points (rows) in '", name, "'")
  if (ncol(x) < 3L)
    stop("'", name, "' must have at least 3 columns: 2D points and set index")
  # Re-encode the sets so that they are consecutive and numeric
  setcol <- ncol(x)
  x[, setcol] <- as.numeric(as.factor(x[, setcol]))
  x <- as.matrix(x)
  if (!is.numeric(x))
    stop("The two first columns of '", name, "' must be numeric")
  if (storage.mode(x) != "double")
    storage.mode(x) <- "double"
  return(x)
}

compute_eaf <- function(data, percentiles = NULL)
{
  data <- check_eaf_data(data)
  setcol <- ncol(data)
  nobjs <- setcol - 1L
  sets <- data[, setcol]
  order_sets <- order(sets)
  # The C code expects points within a set to be contiguous.
  data <- data[order_sets, 1L:nobjs, drop=FALSE]
  sets <- sets[order_sets]
  nsets <- nunique(sets)
  npoints <- tabulate(sets)
  if (is.null(percentiles)) {
    # FIXME: We should compute this in the C code.
    percentiles <- 1L:nsets * (100 / nsets)
  } else {
    # FIXME: We should handle only integral levels inside the C code. 
    percentiles <- unique.default(sort.int(percentiles))
  }
  .Call(compute_eaf_C,
    t(data),
    nobjs,
    as.integer(cumsum(npoints)),
    nsets,
    as.numeric(percentiles))
}

compute_eaf_as_list <- function(data, percentiles = NULL)
{
  eaf <- compute_eaf(data, percentiles = percentiles)
  setcol <- ncol(eaf)
  nobjs <- setcol - 1L
  eaf_sets <- eaf[, setcol]
  uniq_eaf_sets <- unique.default(eaf[, setcol])
  split.data.frame(eaf[,1:nobjs, drop=FALSE],
    factor(eaf_sets,
      levels = uniq_eaf_sets,
      labels = uniq_eaf_sets))
}

compute_eafdiff_helper <- function(data, intervals)
{
  # Last column is the set number.
  setcol <- ncol(data)
  nobjs <- setcol - 1L
  sets <- data[, setcol]
  order_sets <- order(sets)
  # The C code expects points within a set to be contiguous.
  data <- as.matrix(data[order_sets, 1L:nobjs])
  sets <- sets[order_sets]
  nsets <- nunique(sets)
  npoints <- tabulate(sets)
  # FIXME: Ideally this would be computed by the C code, but it is hard-coded.
  ## division <- nsets %/% 2
  ## nsets1 <- division
  ## nsets2 <- nsets - division
  .Call(compute_eafdiff_C,
    t(data),
    nobjs,
    as.integer(cumsum(npoints)),
    nsets,
    as.integer(intervals))
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
#' @seealso    [read_datasets()], [eaf::eafdiffplot()]
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
  data <- check_eaf_data(data)
  # FIXME: Is it faster to subset or to multiply the third column by 1?
  data[,1L:2L] <- matrix_maximise(data[,1L:2L, drop=FALSE], maximise = maximise)
  
  DIFF <- if (rectangles) compute_eafdiff_rectangles(data, intervals = intervals)
          else compute_eafdiff_helper(data, intervals = intervals)
  # FIXME: We should remove duplicated rows in C code.

  # FIXME: Check that we do not generate duplicated nor overlapping rectangles
  # with different colors. That would be a bug.
  DIFF <- DIFF[!duplicated(DIFF),]
  return(DIFF)
}

compute_eafdiff <- function(data, intervals)
{
  DIFF <- compute_eafdiff_helper(data, intervals)
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
compute_eafdiff_rectangles <- function(data, intervals = 1L)
{
  # Last column is the set number.
  setcol <- ncol(data)
  nobjs <- setcol - 1L
  sets <- data[, setcol]
  order_sets <- order(sets)
  # The C code expects points within a set to be contiguous.
  data <- as.matrix(data[order_sets, 1L:nobjs, drop=FALSE])
  sets <- sets[order_sets]
  nsets <- nunique(sets)
  npoints <- tabulate (sets)
  .Call(compute_eafdiff_rectangles_C,
    t(data),
    nobjs,
    as.integer(cumsum(npoints)),
    nsets,
    as.integer(intervals))
}

# FIXME: The default intervals should be nsets / 2
compute_eafdiff_polygon <- function(data, intervals = 1L)
{
  # Last column is the set number.
  setcol <- ncol(data)
  nobjs <- setcol - 1L
  sets <- data[, setcol]
  order_sets <- order(sets)
  # The C code expects points within a set to be contiguous.
  data <- data[order_sets, 1L:nobjs, drop=FALSE]
  sets <- sets[order_sets]
  nsets <- nunique(sets)
  npoints <- tabulate(sets)
  # FIXME: Ideally this would be computed by the C code, but it is hard-coded.
  ## division <- nsets %/% 2
  ## nsets1 <- division
  ## nsets2 <- nsets - division
  # FIMXE: This function may require a lot of memory for 900 sets. Is there a
  # way to save memory?
  .Call(compute_eafdiff_area_C,
    t(data),
    nobjs,
    as.integer(cumsum(npoints)),
    nsets,
    as.integer(intervals))
}


matrix_maximise <- function(z, maximise)
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
#' @note There are several examples of data sets in
#'   `system.file(package="moocore","extdata")`. The current implementation
#'   only supports two and three dimensional points.
#'
#' @references
#' 
#' \insertRef{Grunert01}{moocore}
#'
#' \insertRef{FonGueLopPaq2011emo}{moocore}
#'  
#'@seealso [read_datasets()]
#'
#'@examples
#' extdata_path <- system.file(package="moocore", "extdata")
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
    sets <- if (is.factor(sets)) as.numeric(levels(sets))[sets]
    else suppressWarnings(as.numeric(sets))
  }
  if (anyNA(sets)) stop("'sets' must have only non-NA numerical values")
  
  points <- cbind(points, sets)
  if (is.null(groups)) {
    attsurfs <- compute_eaf (points, percentiles)
  } else {
    attsurfs <- data.frame()
    groups <- factor(groups)
    for (g in levels(groups)) {
      tmp <- compute_eaf(points[groups == g,], percentiles)
      attsurfs <- rbind(attsurfs, data.frame(tmp, groups = g))
    }
  }
  attsurfs
}

#' Convert a list of attainment surfaces to a single `data.frame`.
#'
#' @param x (`list()`) List of `data.frames` or matrices. The names of the list
#'   give the percentiles of the attainment surfaces.  This is the format
#'   returned by [eaf::eafplot()] (and the internal function `compute_eaf_as_list`).
#'
#' @return A `data.frame` with as many columns as objectives and an additional column `percentiles`.
#'
#' @examples
#'
#' data(SPEA2relativeRichmond)
#' # attsurfs <- eafplot (SPEA2relativeRichmond, percentiles = c(0,50,100),
#' #                      xlab = expression(C[E]), ylab = "Total switches",
#' #                      lty=0, pch=21, xlim = c(90, 140), ylim = c(0, 25))
#' # attsurfs <- attsurf2df(attsurfs)
#' # text(attsurfs[,1:2], labels = attsurfs[,3], adj = c(1.5,1.5))
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
