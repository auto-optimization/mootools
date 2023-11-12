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

check_dataset <- function(x)
{
  name <- deparse(substitute(x))
  if (length(dim(x)) != 2L)
    stop("'", name, "' must be a data.frame or a matrix")
  if (nrow(x) < 1L)
    stop("not enough points (rows) in '", name, "'")
  if (ncol(x) < 2L)
    stop("'", name, "' must have at least 2 columns")
  x <-  as.matrix(x)
  if (!is.numeric(x))
    stop("'", name, "' must be numeric")
  if (storage.mode(x) != "double")
    storage.mode(x) <- "double"
  return(x)
}

rbind_datasets <- function(x, y)
{
  # FIXME: We could relax this condition by re-encoding  the column.
  stopifnot(min(x[,3L]) == 1L)
  stopifnot(min(y[,3L]) == 1L)
  # We have to make all sets unique.
  y[,3L] <- y[,3L] + max(x[,3L])
  rbind(x, y)
}

nunique <- function(x) length(unique.default(x))
