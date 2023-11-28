source("helper-common.R")

test_that("eaf", {

  test_eaf_dataset <- function(name, percentiles = NULL) {
    dataset <- get(name)
    x <- moocore:::compute_eaf(dataset, percentiles)
    # FIXME: work-around for change in the computation
    x[,3] <- floor(x[,3])
    #saveRDS(x, paste0(name, "-eaf.rds"))
    return(x)
  }
  test_eaf_file <- function(file, percentiles = NULL) {
    dataset <- read_datasets(file)
    x <- moocore:::compute_eaf(dataset, percentiles)
    #saveRDS(x, paste0(basename(file), "-eaf.rds"))
    return(x)
  }
  expect_equal(test_eaf_file(extdata_path("ALG_1_dat.xz")),
               readRDS("ALG_1_dat-eaf.rds"))
  expect_equal(test_eaf_dataset("SPEA2relativeRichmond"),
               readRDS("SPEA2relativeRichmond-eaf.rds"))

  for (i in seq_len(399))
    expect_equal(anyDuplicated(eafs(cbind(0:i, 0:i), 0:i)[,1]), 0L)
})

test_that("eafs_sets_numeric", {
  expect_error(eafs(matrix(1:10, ncol=2), sets=letters[1:5]),
               "sets")
})

test_that("eaf3d", {
  lin <- read_datasets("lin.S.txt")
  sph <- read_datasets("sph.S.txt")
  nobjs <- ncol(lin) - 1
  nruns_left <- max(lin[, nobjs + 1])
  data_combined <- sph
  data_combined[, nobjs + 1] <- data_combined[, nobjs + 1] + nruns_left
  data_combined <- rbind(lin, data_combined)
  # This may stop working once we filter uninteresting values in the C code directly.
  DIFF <- moocore:::compute_eafdiff_helper(data_combined, intervals = nruns_left)
  x <- as.matrix(read.table("lin.S-sph.S-diff.txt.xz", header = FALSE))
  dimnames(x) <- NULL
  x[, nobjs + 1] <- x[, nobjs + 1] - x[, nobjs + 2]
  expect_equal(DIFF[, 1 : (nobjs + 1)], x[, 1 : (nobjs + 1)])
})
