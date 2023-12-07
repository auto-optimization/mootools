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
  x
}

check_points <- function(x)
{
  name <- deparse(substitute(x))
  if (length(dim(x)) != 2L)
    stop("'", name, "' must be a data.frame or a matrix")
  if (nrow(x) < 1L)
    stop("not enough points (rows) in '", name, "'")
  if (ncol(x) < 2L)
    stop("'", name, "' must have at least 2 columns")
  x <- as.matrix(x)
  if (!is.numeric(x))
    stop("'", name, "' must be numeric")
  if (storage.mode(x) != "double")
    storage.mode(x) <- "double"
  x
}

check_sets <- function(sets, order_sets)
{
  if (anyNA(sets)) stop("'sets' must have only non-NA numerical values")
  as.integer(factor(sets))[order_sets]
}

