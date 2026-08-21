# Test runner. From the project root:
#
#   Rscript tests/testthat.R
#
# App code under R/ is sourced first so the pure helpers are available to
# the unit tests without installing anything.

library(testthat)
library(data.table)

if (!dir.exists("R")) {
  stop("Run the tests from the project root: Rscript tests/testthat.R")
}
for (f in list.files("R", full.names = TRUE)) {
  source(f)
}

test_dir("tests/testthat", stop_on_failure = TRUE)
