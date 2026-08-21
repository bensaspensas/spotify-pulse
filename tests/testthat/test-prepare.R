# Unit tests for the raw -> prepared transformation (R/data.R).

make_raw <- function() {
  dt <- data.table::data.table(
    track_id                 = c("t1", "t1", "t1", "t2", "t3", "t4"),
    track_name               = c("Song A", "Song A", "Song A", "Song B", "", "Song D"),
    track_artist             = c("Artist 1", "Artist 1", "Artist 1", "Artist 2", "X", "Artist 4"),
    track_popularity         = c(70L, 70L, 70L, 55L, 10L, 30L),
    track_album_id           = "al",
    track_album_name         = "Album",
    track_album_release_date = c("2019-06-14", "2019-06-14", "2019-06-14",
                                 "2001", "2010-01-01", "1899-01-01"),
    playlist_name            = "pl",
    playlist_id              = "plid",
    playlist_genre           = c("pop", "pop", "rock", "rap", "pop", "edm"),
    playlist_subgenre        = "sub",
    danceability = 0.5, energy = 0.5, loudness = -7,
    mode = 1L, speechiness = 0.05, acousticness = 0.1,
    instrumentalness = 0, liveness = 0.1, valence = 0.5,
    tempo = 120, duration_ms = 210000
  )
  # `key` clashes with the data.table() argument of the same name,
  # so the musical-key column is added after construction.
  dt[, key := 1L]
  dt[]
}

test_that("release years are parsed from full dates and bare years", {
  prepared <- prepare_songs(make_raw())
  expect_setequal(unique(prepared[track_id == "t1"]$release_year), 2019L)
  expect_equal(prepared[track_id == "t2"]$release_year, 2001L)
})

test_that("rows with blank names or implausible years are dropped", {
  prepared <- prepare_songs(make_raw())
  # t3 has an empty track_name, t4 is from 1899
  expect_false(any(prepared$track_id %in% c("t3", "t4")))
})

test_that("duplicates collapse to one row per (track, genre)", {
  prepared <- prepare_songs(make_raw())
  # t1 appears in two pop playlists and one rock playlist -> 2 rows
  expect_identical(nrow(prepared[track_id == "t1"]), 2L)
  expect_setequal(prepared[track_id == "t1"]$playlist_genre, c("pop", "rock"))
})

test_that("duration is converted to minutes", {
  prepared <- prepare_songs(make_raw())
  expect_equal(prepared$duration_min, rep(3.5, nrow(prepared)))
})

test_that("the raw input is not modified by reference", {
  raw <- make_raw()
  before <- data.table::copy(raw)
  invisible(prepare_songs(raw))
  expect_identical(raw, before)
})
