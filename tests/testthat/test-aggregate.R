# Unit tests for the pure aggregation helpers (R/utils_aggregate.R).

test_that("filter_songs applies genre, year and popularity filters together", {
  songs <- make_songs()
  out <- filter_songs(
    songs, genres = c("pop", "rock"),
    years = c(2000, 2025), popularity = c(50, 100)
  )
  expect_setequal(out$track_id, c("a", "b"))
  # rock 'a' row from 2019 stays, rock 'd' row from 1995 is out
  expect_false("d" %in% out$track_id)
})

test_that("kpi_summary counts unique tracks and artists", {
  kpis <- kpi_summary(make_songs())
  expect_identical(kpis$n_tracks, 5L)   # 'a' counted once
  expect_identical(kpis$n_artists, 4L)  # 'Two' counted once
  expect_equal(kpis$avg_popularity, mean(c(80, 80, 60, 40, 90, 10)))
})

test_that("agg_yearly counts unique tracks per genre and year", {
  yearly <- agg_yearly(make_songs())
  expect_identical(
    yearly[playlist_genre == "pop" & release_year == 2019]$n_tracks, 1L
  )
  expect_identical(nrow(yearly), 6L)
})

test_that("feature_by_genre returns per-genre medians of the chosen column", {
  prof <- feature_by_genre(make_songs(), "danceability")
  expect_equal(prof[playlist_genre == "rock"]$value, median(c(0.9, 0.2)))
  expect_error(feature_by_genre(make_songs(), "not_a_column"))
})

test_that("top_tracks deduplicates and orders by popularity", {
  top <- top_tracks(make_songs(), n = 3L)
  expect_identical(top$track_name, c("Delta", "Alpha", "Beta"))
  expect_identical(nrow(top_tracks(make_songs())), 5L)
})

test_that("sample_songs keeps small tables intact and caps large ones", {
  songs <- make_songs()
  expect_identical(sample_songs(songs, max_points = 100L), songs)

  big <- songs[rep(seq_len(.N), 2000)]
  big[, track_id := as.character(.I)]
  sampled <- sample_songs(big, max_points = 400L)
  expect_lt(nrow(sampled), 1000L)
  # stratification: every genre survives sampling
  expect_setequal(unique(sampled$playlist_genre), unique(big$playlist_genre))
  # deterministic
  expect_identical(sample_songs(big, max_points = 400L), sampled)
})
