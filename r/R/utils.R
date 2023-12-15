range_df_list <- function(x, col)
{
  # FIXME: How to make this faster?
  do.call(range, lapply(x, `[`, , col))
}

get_ideal <- function(x, maximise)
{
  # FIXME: Is there a better way to do this?
  minmax <- colRanges(as.matrix(x))
  lower <- minmax[,1L]
  upper <- minmax[,2L]
  ifelse(maximise, upper, lower)
}

nunique <- function(x) length(unique.default(x))

# FIXME: There must be something faster than table
unique_counts <- function(x) as.vector(table(x))

#' Transform matrix according to maximise parameter
#'
#' @param x (`data.frame()`|`matrix()`) A numerical matrix or `data.frame`.
#'
#' @template arg_maximise
#'
#' @return `x` transformed such that every column where `maximise` is `TRUE` is multiplied by `-1`.
#'
#' @examples
#' x <- data.frame(f1=1:10, f2=101:110)
#' rownames(x) <- letters[1:10]
#' transform_maximise(x, maximise=c(FALSE,TRUE))
#' transform_maximise(x, maximise=TRUE)
#' x <- as.matrix(x)
#' transform_maximise(x, maximise=c(FALSE,TRUE))
#' transform_maximise(x, maximise=TRUE)
#' 
#' @export
transform_maximise <- function(x, maximise)
{
  if (any(maximise)) {
    if (length(maximise) == 1L)
      return(-x)
    if (length(maximise) != ncol(x))
      stop("length of maximise must be either 1 or ncol(x)")
    if (all(maximise))
      return(-x)
    x[,maximise] <- -x[,maximise, drop=FALSE]
  }
  x
}
