#' Hypervolume metric
#'
#' Computes the hypervolume metric with respect to a given reference point
#' assuming minimization of all objectives.
#'
#' @template arg_data
#'
#' @template arg_refpoint
#'
#' @template arg_maximise
#' 
#' @return  A single numerical value.
#'
#' @details The algorithm has \eqn{O(n^{d-2} \log n)} time and linear space
#'   complexity in the worst-case, but experimental results show that the
#'   pruning techniques used may reduce the time complexity even further.
#' 
#' @author Manuel \enc{López-Ibáñez}{Lopez-Ibanez}
#'
#' @references
#'
#' \insertRef{FonPaqLop06:hypervolume}{eaf}
#'
#' \insertRef{BeuFonLopPaqVah09:tec}{eaf}
#'
#' @examples
#'
#' data(SPEA2minstoptimeRichmond)
#' # The second objective must be maximized
#' # We calculate the hypervolume of the union of all sets.
#' hypervolume(SPEA2minstoptimeRichmond[, 1:2], reference = c(250, 0),
#'             maximise = c(FALSE, TRUE))
#'
#' @export
#' @concept metrics
hypervolume <- function(data, reference, maximise = FALSE)
{
  data <- check_dataset(data)
  nobjs <- ncol(data) 
  npoints <- nrow(data)
  if (is.null(reference)) stop("reference cannot be NULL")
  if (length(reference) == 1) reference <- rep_len(reference, nobjs)

  if (any(maximise)) {
    if (length(maximise) == 1) {
      data <- -data
      reference <- -reference
    } else if (length(maximise) != nobjs) {
      stop("length of maximise must be either 1 or ncol(data)")
    }
    data[,maximise] <- -data[,maximise]
    reference[maximise] <- -reference[maximise]
  }
  return(.Call(hypervolume_C,
               as.double(t(data)),
               as.integer(nobjs),
               as.integer(npoints),
               as.double(reference)))
}

#' Hypervolume contribution of a set of points
#'
#' Computes the hypervolume contribution of each point given a set of points
#' with respect to a given reference point assuming minimization of all
#' objectives.  Dominated points have zero contribution. Duplicated points have
#' zero contribution even if not dominated, because removing one of them does
#' not change the hypervolume dominated by the remaining set.
#'
#' @template arg_data
#'
#' @template arg_refpoint
#'
#' @template arg_maximise
#' 
#' @return ([numeric]) A numerical vector
#'
#' @author Manuel \enc{López-Ibáñez}{Lopez-Ibanez}
#'
#'@seealso \code{\link{hypervolume}}
#'
#' @references
#'
#' \insertRef{FonPaqLop06:hypervolume}{eaf}
#'
#' \insertRef{BeuFonLopPaqVah09:tec}{eaf}
#'
#' @examples
#'
#' data(SPEA2minstoptimeRichmond)
#' # The second objective must be maximized
#' # We calculate the hypervolume contribution of each point of the union of all sets.
#' hv_contributions(SPEA2minstoptimeRichmond[, 1:2], reference = c(250, 0),
#'             maximise = c(FALSE, TRUE))
#'
#' # Duplicated points show zero contribution above, even if not
#' # dominated. However, filter_dominated removes all duplicates except
#' # one. Hence, there are more points below with nonzero contribution.
#' hv_contributions(filter_dominated(SPEA2minstoptimeRichmond[, 1:2], maximise = c(FALSE, TRUE)),
#'                  reference = c(250, 0), maximise = c(FALSE, TRUE))
#' 
#' @export
#' @concept metrics
hv_contributions <- function(data, reference, maximise = FALSE)
{
  data <- check_dataset(data)
  nobjs <- ncol(data) 
  npoints <- nrow(data)
  if (is.null(reference)) stop("reference cannot be NULL")
  if (length(reference) == 1) reference <- rep_len(reference, nobjs)
  
  if (any(maximise)) {
    if (length(maximise) == 1) {
      data <- -data
      reference <- -reference
    } else if (length(maximise) != nobjs) {
      stop("length of maximise must be either 1 or ncol(data)")
    }
    data[,maximise] <- -data[,maximise]
    reference[maximise] <- -reference[maximise]
  }
  return(.Call(hv_contributions_C,
               as.double(t(data)),
               as.integer(nobjs),
               as.integer(npoints),
               as.double(reference)
               ))
}
