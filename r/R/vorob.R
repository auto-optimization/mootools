#' Compute Vorob'ev threshold, expectation and deviation. Also, displaying the
#' symmetric deviation function is possible.  The symmetric deviation
#' function is the probability for a given target in the objective space to
#' belong to the symmetric difference between the Vorob'ev expectation and a
#' realization of the (random) attained set.
#' 
#' @title Vorob'ev computations
#' @param x Either a matrix of data values, or a data frame, or a list of data
#'   frames of exactly three columns.  The third column gives the set (run,
#'   sample, ...) identifier.
#' @template arg_refpoint
#' @return `vorobT` returns a list with elements `threshold`,
#'   `VE`, and `avg_hyp` (average hypervolume)
#' @rdname Vorob
#' @author Mickael Binois
#' @examples
#' data(CPFs)
#' res <- vorobT(CPFs, reference = c(2, 200))
#' print(res$threshold)
#' 
#' ## Display Vorob'ev expectation and attainment function
#' # First style
#' # eafplot(CPFs[,1:2], sets = CPFs[,3], percentiles = c(0, 25, 50, 75, 100, res$threshold),
#' #         main = substitute(paste("Empirical attainment function, ",beta,"* = ", a, "%"),
#' #                           list(a = formatC(res$threshold, digits = 2, format = "f"))))
#' # 
#' # # Second style
#' # eafplot(CPFs[,1:2], sets = CPFs[,3], percentiles = c(0, 20, 40, 60, 80, 100),
#' #         col = gray(seq(0.8, 0.1, length.out = 6)^0.5), type = "area", 
#' #         legend.pos = "bottomleft", extra.points = res$VE, extra.col = "cyan",
#' #         extra.legend = "VE", extra.lty = "solid", extra.pch = NA, extra.lwd = 2,
#' #         main = substitute(paste("Empirical attainment function, ",beta,"* = ", a, "%"),
#' #                           list(a = formatC(res$threshold, digits = 2, format = "f"))))
#' @references
#' \insertRef{BinGinRou2015gaupar}{moocore}
#'
#' C. Chevalier (2013), Fast uncertainty reduction strategies relying on
#' Gaussian process models, University of Bern, PhD thesis.
#'
#' \insertRef{Molchanov2005theory}{moocore}
#'
#' @concept eaf
#' @export
vorobT <- function(x, reference)
{
  x <- check_eaf_data(x)
  setcol <- ncol(x)
  nobjs <- setcol - 1L

  # First step: compute average hypervolume over conditional Pareto fronts
  avg_hyp <- mean(sapply(split.data.frame(x[,1:nobjs], x[, setcol]),
                         hypervolume, reference = reference))

  prev_hyp <- diff <- Inf # hypervolume of quantile at previous step
  a <- 0
  b <- 100
  while (diff != 0) {
    c <- (a + b) / 2
    eaf_res <- eafs(x[,1:nobjs], x[,setcol], percentiles = c)[,1:nobjs]
    tmp <- hypervolume(eaf_res, reference = reference)
    if (tmp > avg_hyp) a <- c else b <- c
    diff <- prev_hyp - tmp
    prev_hyp <- tmp
  }
  
  list(threshold = c, VE = eaf_res, avg_hyp = avg_hyp)
} 

#' @concept eaf
#' @rdname Vorob
#' @param VE Vorob'ev expectation, e.g., as returned by [vorobT()].
#' @return `vorobDev` returns the Vorob'ev deviation.
#' @examples
#' 
#' # Now print Vorob'ev deviation
#' VD <- vorobDev(CPFs, VE = res$VE, reference = c(2, 200))
#' print(VD)
#' @export
vorobDev <- function(x, reference, VE = NULL)
{
  if (is.data.frame(x)) x <- as.matrix(x)
  if (is.null(VE)) VE <- vorobT(x, reference)$VE
  
  setcol <- ncol(x)
  nobjs <- setcol - 1L

  # Hypervolume of the symmetric difference between A and B:
  # 2 * H(AUB) - H(A) - H(B)
  H2 <- hypervolume(VE, reference = reference)
  x_split <- split.data.frame(x[,1:nobjs, drop=FALSE], x[,setcol])
  H1 <- mean(sapply(x_split, hypervolume, reference = reference))

  hv_union_VE <- function(y)
    hypervolume(rbind(y[, 1:nobjs, drop=FALSE], VE), reference = reference)
  
  VD <- 2 * sum(sapply(x_split, hv_union_VE))
  nruns <- length(x_split)
  ((VD / nruns) - H1 - H2)
}
