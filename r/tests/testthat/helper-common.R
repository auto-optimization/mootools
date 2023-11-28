# This file is loaded automatically by testthat (supposedly)
extdata_path <- function(file)
  file.path(system.file(package = "moocore"), "extdata", file)

read_extdata <- function(file) read_datasets(extdata_path(file))

