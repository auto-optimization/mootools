#' Convert input to a matrix with `"double"` storage mode ([base::storage.mode()]).
#' 
#' @param x (`data.frame()`|`matrix()`)\cr A numerical data frame or matrix with at least 1 row and 2 columns.
#' @return `x` is coerced to a numerical `matrix()`.
#' @export
as_double_matrix <- function(x)
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


