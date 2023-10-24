#' Identify largest EAF differences
#' 
#' Given a list of datasets, return the indexes of the pair with the largest
#' EAF differences according to the method proposed by \citet{DiaLop2020ejor}.
#' 
#'
#' @param data (`list(1)`) A list of matrices with at least 3 columns
#'
#' @template arg_maximise
#'
#' @param intervals (`integer(1)`) \cr The absolute range of the differences
#'   \eqn{[0, 1]} is partitioned into the number of intervals provided.
#'
#' @template arg_refpoint
#'
#' @template arg_ideal_null
#' 
#' @return  (`list()`) A list with two components `pair` and `value`.
#' 
#'@examples
#' # FIXME: This example is too large, we need a smaller one.
#' files <- c("wrots_l100w10_dat","wrots_l10w100_dat")
#' data <- lapply(files, function(x)
#'                read_datasets(file.path(system.file(package="eaf"),
#'                              "extdata", x)))
#' nadir <- apply(do.call(rbind, data)[,1:2], 2, max)
#' x <- largest_eafdiff(data, reference = nadir)
#' str(x)
#'
#'@references
#' \insertAllCited{}
#' 
#'@concept eaf
#'@export
largest_eafdiff <- function(data, maximise = FALSE, intervals = 5, reference,
                            ideal = NULL)
{
  nobjs <- 2
  maximise <- as.logical(rep_len(maximise, nobjs))
  if (nobjs != 2) stop("Only 2 objectives currently supported")
 
  n <- length(data)
  stopifnot(n > 1)
  best_pair <- NULL
  best_value <- 0
  if (is.null(ideal)) {
    # This should be equivalent to
    # cbind(c(range(data[[1]][,1]),range(data[[2]][,1])),
    #       c(range(data[[1]][,2]),range(data[[2]][,2])))
    data_agg <- t(do.call(cbind, lapply(data, function(x) matrixStats::colRanges(x[,1:nobjs]))))
    ideal <- get_ideal(data_agg, maximise = maximise)
  }
  # Convert to a 1-row matrix
  if (is.null(dim(ideal))) dim(ideal) <- c(1,nobjs)
    
  for (a in 1:(n-1)) {
    for (b in (a+1):n) {
      DIFF <- eafdiff(data[[a]], data[[b]], intervals = intervals,
                      maximise = maximise, rectangles = TRUE)
      # Set color to 1
      a_rectangles <- DIFF[ DIFF[, 5] >= 1L, , drop = FALSE]
      a_rectangles[, ncol(a_rectangles)] <- 1
      
      a_value <- whv_rect(ideal, a_rectangles, reference, maximise)
      
      b_rectangles <- DIFF[ DIFF[, 5] <= -1L, , drop = FALSE]
      b_rectangles[, ncol(b_rectangles)] <- 1
      b_value <- whv_rect(ideal, b_rectangles, reference, maximise)
      value <- min(a_value, b_value)
      if (value > best_value) {
        best_value <- value
        best_pair <- c(a, b)
      }
    }
  }
  list(pair=best_pair, value = best_value)
}


#' @param x (`matrix()`) Matrix of rectangles representing EAF differences
#'   (returned by [eafdiff()] with `rectangles=TRUE`).
#' 
#' @param left (`logical(1)`) With `left=TRUE` return the rectangles with
#'   positive differences, otherwise return those with negative differences but
#'   differences are converted to positive.
#' 
#' @rdname choose_eafdiffplot
#'@concept eaf
#'@export
choose_eafdiff <- function(x, left = stop("'left' must be either TRUE or FALSE"))
{
  if (left) return (x[ x[, ncol(x)] > 0L, , drop = FALSE])
  x <- x[ x[, ncol(x)] < 0L, , drop = FALSE]
  # We always return positive colors.
  x[, ncol(x)] <- abs(x[, ncol(x)])
  x
}

