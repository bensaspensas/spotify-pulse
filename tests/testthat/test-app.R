# End-to-end smoke test with shinytest2: the app boots, renders its KPIs,
# and reacts to a filter change.

test_that("app starts and KPIs react to genre filters", {
  skip_if_not_installed("shinytest2")
  skip_on_cran()

  app <- shinytest2::AppDriver$new(
    app_dir = test_path("../.."),
    name = "smoke",
    seed = 42,
    load_timeout = 30 * 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle(timeout = 30 * 1000)

  n_all <- app$get_value(output = "overview-n_tracks")
  expect_match(n_all, "^[0-9,]+$")

  # narrow to a single genre -> the track count must change
  app$set_inputs(`filters-genres` = "rock")
  app$wait_for_idle(timeout = 15 * 1000)

  n_rock <- app$get_value(output = "overview-n_tracks")
  expect_match(n_rock, "^[0-9,]+$")
  expect_false(identical(n_all, n_rock))

  # deselecting every genre shows the validation message instead of crashing
  app$set_inputs(`filters-genres` = character(0))
  app$wait_for_idle(timeout = 15 * 1000)
  val <- app$get_value(output = "overview-n_tracks")
  expect_match(val$message, "Select at least one genre")
})
