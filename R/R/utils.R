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

