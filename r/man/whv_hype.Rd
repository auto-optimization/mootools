% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/whv.R
\name{whv_hype}
\alias{whv_hype}
\title{Approximation of the (weighted) hypervolume by Monte-Carlo sampling (2D only)}
\usage{
whv_hype(
  data,
  reference,
  ideal,
  maximise = FALSE,
  dist = list(type = "uniform"),
  nsamples = 100000L
)
}
\arguments{
\item{data}{(\code{matrix} | \code{data.frame}) \cr Matrix or data frame of numerical
values, where each row gives the coordinates of a point.}

\item{reference}{(\code{numeric()}) \cr Reference point as a vector of numerical values.}

\item{ideal}{(\code{numeric()}) \cr Ideal point as a vector of numerical values.}

\item{maximise}{(\code{logical()} | \code{logical(1)}) \cr Whether the objectives must be
maximised instead of minimised. Either a single logical value that applies
to all objectives or a vector of logical values, with one value per
objective.}

\item{dist}{(\code{list()}) weight distribution. See Details.}

\item{nsamples}{(\code{integer(1)}) number of samples for Monte-Carlo sampling.}
}
\value{
A single numerical value.
}
\description{
Return an estimation of the hypervolume of the space dominated by the input
data following the procedure described by \citet{AugBadBroZit2009gecco}. A
weight distribution describing user preferences may be specified.
}
\details{
The current implementation only supports 2 objectives.

A weight distribution  \citep{AugBadBroZit2009gecco} can be provided via the \code{dist} argument. The ones currently supported are:
\itemize{
\item \code{type="uniform"} corresponds to the default hypervolume (unweighted).
\item \code{type="point"} describes a goal in the objective space, where \code{mu} gives the coordinates of the goal. The resulting weight distribution is a multivariate normal distribution centred at the goal.
\item \code{type="exponential"} describes an exponential distribution with rate parameter \code{1/mu}, i.e., \eqn{\lambda = \frac{1}{\mu}}.
}
}
\examples{

whv_hype (matrix(2, ncol=2), reference = 4, ideal = 1)

whv_hype (matrix(c(3,1), ncol=2), reference = 4, ideal = 1)

whv_hype (matrix(2, ncol=2), reference = 4, ideal = 1,
          dist = list(type="exponential", mu=0.2))

whv_hype (matrix(c(3,1), ncol=2), reference = 4, ideal = 1,
          dist = list(type="exponential", mu=0.2))

whv_hype (matrix(2, ncol=2), reference = 4, ideal = 1,
          dist = list(type="point", mu=c(1,1)))

whv_hype (matrix(c(3,1), ncol=2), reference = 4, ideal = 1,
          dist = list(type="point", mu=c(1,1)))

}
\references{
\insertAllCited{}
}
\seealso{
\code{\link[=read_datasets]{read_datasets()}}, \code{\link[=eafdiff]{eafdiff()}}, \code{\link[=whv_rect]{whv_rect()}}
}
\concept{metrics}
