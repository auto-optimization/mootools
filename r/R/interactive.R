#' Identify largest EAF differences
#' 
#' Given a list of datasets, return the indexes of the pair with the largest
#' EAF differences according to the method proposed by \citet{DiaLop2020ejor}.
#' 
#'
#' @param x (`list()`) A list of matrices with at least 3 columns
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
#' data(tpls50x20_1_MWT)
#' nadir <- apply(tpls50x20_1_MWT[,2:3], 2L, max)
#' x <- largest_eafdiff(split.data.frame(tpls50x20_1_MWT[,2:4], tpls50x20_1_MWT[, 1L]),
#'                      reference = nadir)
#' str(x)
#'
#'@references
#' \insertAllCited{}
#' 
#'@concept eaf
#'@export
largest_eafdiff <- function(x, maximise = FALSE, intervals = 5L, reference,
                            ideal = NULL)
{
  # FIXME: Check the input data makes sense
  nobjs <- 2L
  maximise <- as.logical(rep_len(maximise, nobjs))
  if (nobjs != 2L) stop("Only 2 objectives currently supported")

  n <- length(x)
  stopifnot(n > 1L)
  best_pair <- NULL
  best_value <- 0
  if (is.null(ideal)) {
    r1 <- range_df_list(x, 1L)
    r2 <- range_df_list(x, 2L)
    upper <- c(r1[2L], r2[2L])
    lower <- c(r1[1L], r2[1L])
    ideal <- ifelse(maximise, upper, lower)
  }
  # Convert to a 1-row matrix
  if (is.null(dim(ideal))) dim(ideal) <- c(1L,nobjs)
    
  for (a in seq_len(n-1)) {
    for (b in (a+1):n) {
      DIFF <- eafdiff(x[[a]], x[[b]], intervals = intervals,
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


