% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eafdiff.R
\name{compute_eafdiff_call}
\alias{compute_eafdiff_call}
\title{Same as \code{\link[=eafdiff]{eafdiff()}} but performs no checks and does not transform the input or
the output. This function should be used by other packages that want to
avoid redundant checks and transformations.}
\usage{
compute_eafdiff_call(x, y, cumsizes_x, cumsizes_y, intervals, ret)
}
\arguments{
\item{x, y}{Data frames corresponding to the input data of
left and right sides, respectively. Each data frame has at least three
columns, the third one being the set of each point. See also
\code{\link[=read_datasets]{read_datasets()}}.}

\item{cumsizes_x, cumsizes_y}{Cumulative size of the different sets of points in \code{x}.}

\item{intervals}{(\code{integer(1)}) \cr The absolute range of the differences
\eqn{[0, 1]} is partitioned into the number of intervals provided.}

\item{ret}{(\code{"points"|"rectangles"|"polygons"})\cr The format of the returned EAF differences.}
}
\description{
Same as \code{\link[=eafdiff]{eafdiff()}} but performs no checks and does not transform the input or
the output. This function should be used by other packages that want to
avoid redundant checks and transformations.
}
\seealso{
\code{\link[=as_double_matrix]{as_double_matrix()}} \code{\link[=transform_maximise]{transform_maximise()}}
}
\concept{eaf}
