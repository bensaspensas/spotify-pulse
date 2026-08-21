# utils_aggregate.R -- pure data.table helpers behind every chart and KPI.
#
# These functions are deliberately free of any Shiny code so they can be
# unit-tested in isolation (see tests/testthat/test-aggregate.R).

#' Filter the songs table on the values coming from the sidebar.
#'
#' @param songs Prepared `data.table` (see [prepare_songs()]).
#' @param genres Character vector of raw genre values (e.g. `"pop"`).
#' @param years Length-2 numeric vector: inclusive release-year range.
#' @param popularity Length-2 numeric vector: inclusive popularity range.
#' @return A filtered `data.table` (shallow copy).
filter_songs <- function(songs, genres, years, popularity) {
  stopifnot(length(years) == 2L, length(popularity) == 2L)
  songs[
    playlist_genre %chin% genres &
      release_year %between% years &
      track_popularity %between% popularity
  ]
}

#' Headline KPIs for the current selection.
#'
#' @return A one-row `data.table`: n_tracks, n_artists, avg_popularity,
#'   avg_duration (minutes).
kpi_summary <- function(songs) {
  songs[, .(
    n_tracks       = data.table::uniqueN(track_id),
    n_artists      = data.table::uniqueN(track_artist),
    avg_popularity = mean(track_popularity),
    avg_duration   = mean(duration_min)
  )]
}

#' Tracks released and average popularity per year and genre.
agg_yearly <- function(songs) {
  out <- songs[, .(
    n_tracks       = data.table::uniqueN(track_id),
    avg_popularity = mean(track_popularity)
  ), keyby = .(playlist_genre, release_year)]
  out
}

#' Per-genre summary: track count, popularity and audio-feature means.
agg_genre <- function(songs) {
  songs[, .(
    n_tracks       = data.table::uniqueN(track_id),
    avg_popularity = mean(track_popularity),
    danceability   = mean(danceability),
    energy         = mean(energy),
    valence        = mean(valence),
    acousticness   = mean(acousticness)
  ), keyby = playlist_genre]
}

#' Median value of one audio feature per genre (for the feature profile bars).
feature_by_genre <- function(songs, feature) {
  stopifnot(feature %in% names(songs))
  songs[, .(value = stats::median(.SD[[1L]])),
        keyby = playlist_genre, .SDcols = feature]
}

#' Top-n distinct tracks by popularity for the table tab.
top_tracks <- function(songs, n = 500L) {
  cols <- c(
    "track_name", "track_artist", "track_album_name", "playlist_genre",
    "release_year", "track_popularity", "danceability", "energy",
    "valence", "tempo", "duration_min"
  )
  out <- unique(songs, by = "track_id")[
    order(-track_popularity)
  ][seq_len(min(.N, n)), cols, with = FALSE]
  out
}

#' Down-sample a table for scatter plots so the client stays responsive.
#'
#' Sampling is stratified by genre so small genres do not vanish.
#'
#' @param max_points Overall point budget.
#' @param seed Fixed seed so the same selection always renders the same plot.
sample_songs <- function(songs, max_points = 4000L, seed = 42L) {
  if (nrow(songs) <= max_points) {
    return(songs)
  }
  set.seed(seed)
  songs[, .SD[sample(.N, max(1L, round(.N * max_points / nrow(songs))))],
        by = playlist_genre]
}
