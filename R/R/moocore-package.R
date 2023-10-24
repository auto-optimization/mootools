#' SHORT DESCRIPTION
#'
#' LONG DESCRIPTION
#' 
#' @importFrom Rdpack reprompt
#' @importFrom utils modifyList write.table tail
#'
#' @useDynLib moocore, .registration = TRUE
#'
#'@examples
#' @keywords internal
#' @concept multivariate
#' @concept optimize
#' @concept empirical attainment function
"_PACKAGE"


#' Results of Hybrid GA on vanzyl and Richmond water networks
#'
#'@format
#'  A list with two data frames, each of them with three columns, as
#'  produced by [read_datasets()].
#'  \describe{
#'    \item{`$vanzyl`}{data frame of results on vanzyl network}
#'    \item{`$richmond`}{data frame of results on Richmond
#'      network. The second column is filled with `NA`}
#'  }
#' 
#'@source \insertRef{LopezIbanezPhD}{eaf}.
#'
#' @examples
#'data(HybridGA)
#'print(HybridGA$vanzyl)
#'print(HybridGA$richmond)
#' @keywords datasets
"HybridGA"

#'Results of SPEA2 when minimising electrical cost and maximising the
#'minimum idle time of pumps on Richmond water network.
#'
#'@format 
#'  A data frame as produced by [read_datasets()]. The second
#'  column measures time in seconds and corresponds to a maximisation problem.
#'
#' @source \insertRef{LopezIbanezPhD}{eaf}
#'
#'@examples 
#' data(HybridGA)
#' data(SPEA2minstoptimeRichmond)
#' SPEA2minstoptimeRichmond[,2] <- SPEA2minstoptimeRichmond[,2] / 60
#' eafplot (SPEA2minstoptimeRichmond, xlab = expression(C[E]),
#'          ylab = "Minimum idle time (minutes)", maximise = c(FALSE, TRUE),
#'          las = 1, log = "y", legend.pos = "bottomright")
#' @keywords datasets
"SPEA2minstoptimeRichmond"

#' Results of SPEA2 with relative time-controlled triggers on Richmond water
#' network.
#'
#'@format 
#'  A data frame as produced by [read_datasets()].
#'
#' @source \insertRef{LopezIbanezPhD}{eaf}
#'
#'@examples 
#'data(HybridGA)
#'data(SPEA2relativeRichmond)
#' @keywords datasets
"SPEA2relativeRichmond"

#'Results of SPEA2 with relative time-controlled triggers on Vanzyl's
#'water network.
#'
#' @format 
#'  A data frame as produced by [read_datasets()].
#'
#'@source \insertRef{LopezIbanezPhD}{eaf}
#'
#'@examples 
#'data(HybridGA)
#'data(SPEA2relativeVanzyl)
#' @keywords datasets
"SPEA2relativeVanzyl"

#' Metaheuristics for solving the Graph Vertex Coloring Problem
#'
#'  Two metaheuristic algorithms, TabuCol (Hertz et al., 1987) and
#'  simulated annealing \citep{JohAraMcGSch1991}, to find a good
#'  approximation of the chromatic number of two random graphs. The data
#'  here has the only goal of providing an example of use of eafplot for
#'  comparing algorithm performance with respect to both time and quality
#'  when modelled as two objectives in trade off.
#'
#' @format 
#'  A data frame with 3133 observations on the following 6 variables.
#'  \describe{
#'    \item{`alg`}{a factor with levels `SAKempeFI` and `TSinN1`}
#'    \item{`inst`}{a factor with levels `DSJC500.5` and
#'      `DSJC500.9`. Instances are taken from the DIMACS repository.}
#'    \item{`run`}{a numeric vector indicating the run to
#'  which the observation belong. }
#'    \item{`best`}{a numeric vector indicating the best solution in
#'  number of colors found in the corresponding run up to that time.}
#'    \item{`time`}{a numeric vector indicating the time since the
#'  beginning of the run for each observation. A rescaling is applied.}
#'    \item{`titer`}{a numeric vector indicating iteration number
#'  corresponding to the observations.}
#'  }
#'
#'@details
#'  Each algorithm was run 10 times per graph registering the time and
#'  iteration number at which a new best solution was found. A time limit
#'  corresponding to 500*10^5 total iterations of TabuCol was imposed. The
#'  time was then normalized on a scale from 0 to 1 to make it instance
#'  independent.
#'
#'@source \insertRef{ChiarandiniPhD}{eaf} (page 138)
#'
#'@references 
#'  A. Hertz and D. de Werra. Using Tabu Search Techniques for Graph
#'  Coloring. Computing, 1987, 39(4), 345-351.
#'
#' \insertAllCited{}
#'
#'@examples 
#' data(gcp2x2)
#' @keywords datasets
"gcp2x2"

#' Conditional Pareto fronts obtained from Gaussian processes simulations.
#'
#' The data has the only goal of providing an example of use of [vorobT()] and
#' [vorobDev()]. It has been obtained by fitting two Gaussian processes on 20
#' observations of a bi-objective problem, before generating conditional
#' simulation of both GPs at different locations and extracting non-dominated
#' values of coupled simulations.
#'
#' @format 
#'  A data frame with 2967 observations on the following 3 variables.
#'  \describe{
#'    \item{`f1`}{first objective values.}
#'    \item{`f2`}{second objective values.}
#'    \item{`set`}{indices of corresponding conditional Pareto fronts.}
#'  }
#'
#'@source
#'  
#' \insertRef{BinGinRou2015gaupar}{eaf}
#'
#'@examples 
#' data(CPFs)
#' vorobT(CPFs, reference = c(2, 200))
#'@keywords datasets
"CPFs"


