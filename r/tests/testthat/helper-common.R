# This file is loaded automatically by testthat (supposedly)
extdata.path <- function(file)
  return(file.path(system.file(package = "moocore"), "extdata", file))

read_extdata <- function(file) read_datasets(extdata.path(file))

