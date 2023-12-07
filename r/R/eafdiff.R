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
#' @seealso    [read_datasets()], [mooplot::eafdiffplot()]
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
  DIFF
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
  eafdiff
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

