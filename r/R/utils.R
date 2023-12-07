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

#' Combine datasets `x` and `y` by row taking care of making all sets unique.
#'
#' @param x,y Datasets.
#' @return A dataset.
#' @export
rbind_datasets <- function(x, y)
{
  setcol <- ncol(x)
  stopifnot(setcol > 2L)
  stopifnot(ncol(x) == ncol(y))
  # FIXME: We could relax this condition by re-encoding  the column.
  stopifnot(min(x[,setcol]) == 1L)
  stopifnot(min(y[,setcol]) == 1L)
  # We have to make all sets unique.
  y[,setcol] <- y[,setcol] + max(x[,setcol])
  rbind(x, y)
}

nunique <- function(x) length(unique.default(x))
