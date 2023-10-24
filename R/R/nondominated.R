check_dataset <- function(x)
{
  name <- deparse(substitute(x))
  if (length(dim(x)) != 2L)
    stop("'", name, "' must be a data.frame or a matrix")
  if (nrow(x) < 1L)
    stop("not enough points (rows) in '", name, "'")
  if (ncol(x) < 2)
    stop("'", name, "' must have at least 2 columns")
  x <-  as.matrix(x)
  if (!is.numeric(x))
    stop("'", name, "' must be numeric")
  return(x)
}


#' Identify, remove and rank dominated points according to Pareto optimality
#'
#' Identify nondominated points with `is_nondominated` and remove dominated
#' ones with `filter_dominated`.
#' 
#' @rdname nondominated
#'
#' @template arg_data
#'
#' @template arg_maximise
#' 
#' @param keep_weakly If `FALSE`, return `FALSE` for any duplicates
#'   of nondominated points.
#' 
#' @return `is_nondominated` returns a logical vector of the same length
#'   as the number of rows of `data`, where `TRUE` means that the
#'   point is not dominated by any other point.
#'
#' @author Manuel \enc{López-Ibáñez}{Lopez-Ibanez}
#'
#' @examples
#' path_A1 <- file.path(system.file(package="eaf"),"extdata","ALG_1_dat.xz")
#' set <- read_datasets(path_A1)[,1:2]
#'
#' is_nondom <- is_nondominated(set)
#' cat("There are ", sum(is_nondom), " nondominated points\n")
#'
#' plot(set, col = "blue", type = "p", pch = 20)
#' ndset <- filter_dominated(set)
#' points(ndset[order(ndset[,1]),], col = "red", pch = 21)
#' 
#' @export
#' @concept dominance
is_nondominated <- function(data, maximise = FALSE, keep_weakly = FALSE)
{
  data <- check_dataset(data)
  nobjs <- ncol(data)
  npoints <- nrow(data)
  maximise <- as.logical(rep_len(maximise, nobjs))

  return(.Call(is_nondominated_C,
               as.double(t(data)),
               as.integer(nobjs),
               as.integer(npoints),
               maximise,
               as.logical(keep_weakly)))
}

#' @rdname nondominated
#' @concept dominance
#' @return `filter_dominated` returns a matrix or data.frame with only mutually nondominated points.
#' @export
filter_dominated <- function(data, maximise = FALSE, keep_weakly = FALSE)
{
  return(data[is_nondominated(data, maximise = maximise, keep_weakly = keep_weakly),
            , drop = FALSE])
}

#' @description `pareto_rank()` ranks points according to Pareto-optimality,
#'   which is also called nondominated sorting \citep{Deb02nsga2}.
#' 
#' @rdname nondominated
#' @concept dominance
#' @return `pareto_rank()` returns an integer vector of the same length as
#'   the number of rows of `data`, where each value gives the rank of each
#'   point.
#'
#' @details `pareto_rank()` is meant to be used like `rank()`, but it
#'   assigns ranks according to Pareto dominance. Duplicated points are kept on
#'   the same front. When `ncol(data) == 2`, the code uses the \eqn{O(n
#'   \log n)} algorithm by \citet{Jen03}.
#' 
#' @references
#'
#' \insertAllCited{}
#' 
#' @examples
#' ranks <- pareto_rank(set)
#' colors <- colorRampPalette(c("red","yellow","springgreen","royalblue"))(max(ranks))
#' plot(set, col = colors[ranks], type = "p", pch = 20)
#' @export
pareto_rank <- function(data, maximise = FALSE)
{
  data <- check_dataset(data)
  nobjs <- ncol(data)
  npoints <- nrow(data)
  maximise <- as.logical(rep_len(maximise, nobjs))
  data <- matrix.maximise(data, maximise)
  return(.Call(pareto_ranking_C,
               as.double(t(data)),
               as.integer(nobjs),
               as.integer(npoints)))
}
