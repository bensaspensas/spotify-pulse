# data.R -- data loading and preparation
#
# All heavy lifting is done once, up front, with data.table. The prepared
# dataset is cached as an .rds so app startup stays fast.

#' Read the raw TidyTuesday Spotify songs extract.
#'
#' @param path Path to `spotify_songs.csv`.
#' @return A `data.table` with one row per (track, playlist) pair.
read_songs <- function(path) {
  stopifnot(file.exists(path))
  data.table::fread(path, encoding = "UTF-8")
}

#' Prepare the raw songs extract for the app.
#'
#' Steps:
#'   * parse `track_album_release_date` (comes as YYYY, YYYY-MM or YYYY-MM-DD)
#'     into a numeric `release_year`;
#'   * drop rows without a track name/artist or a parseable year;
#'   * de-duplicate: the raw extract has one row per playlist appearance, we
#'     keep one row per (track_id, playlist_genre) so genre-level stats are
#'     not skewed by playlist popularity;
#'   * keep only the columns the app uses and set a key for fast filtering.
#'
#' @param songs Raw `data.table` as returned by [read_songs()].
#' @return A keyed, de-duplicated `data.table`.
prepare_songs <- function(songs) {
  dt <- data.table::copy(songs)

  dt[, release_year := suppressWarnings(
    as.integer(substr(track_album_release_date, 1L, 4L))
  )]

  dt <- dt[
    !is.na(release_year) & release_year >= 1950L & release_year <= 2025L &
      nzchar(track_name) & nzchar(track_artist)
  ]

  dt[, duration_min := duration_ms / 60000]

  keep <- c(
    "track_id", "track_name", "track_artist", "track_popularity",
    "track_album_name", "release_year", "playlist_genre",
    "playlist_subgenre", "danceability", "energy", "speechiness",
    "acousticness", "instrumentalness", "liveness", "valence", "tempo",
    "loudness", "duration_min"
  )
  dt <- unique(dt[, keep, with = FALSE], by = c("track_id", "playlist_genre"))

  data.table::setkey(dt, playlist_genre, release_year)
  dt[]
}

#' Load the prepared dataset, using an on-disk cache when available.
#'
#' @param raw_path Path to the raw csv (used when the cache is missing).
#' @param cache_path Path to the prepared `.rds` cache.
#' @return A prepared `data.table`.
load_songs <- function(raw_path = "data-raw/spotify_songs.csv",
                       cache_path = "data/spotify_songs.rds") {
  if (file.exists(cache_path)) {
    return(data.table::setDT(readRDS(cache_path)))
  }
  prepared <- prepare_songs(read_songs(raw_path))
  saveRDS(prepared, cache_path)
  prepared
}

# Audio feature columns exposed in the UI, with display labels.
AUDIO_FEATURES <- c(
  Danceability     = "danceability",
  Energy           = "energy",
  Valence          = "valence",
  Acousticness     = "acousticness",
  Instrumentalness = "instrumentalness",
  Liveness         = "liveness",
  Speechiness      = "speechiness",
  "Tempo (BPM)"    = "tempo",
  "Loudness (dB)"  = "loudness",
  "Duration (min)" = "duration_min"
)

# Genre display labels (raw values are lowercase).
GENRE_LABELS <- c(
  edm   = "EDM",
  latin = "Latin",
  pop   = "Pop",
  "r&b" = "R&B",
  rap   = "Rap",
  rock  = "Rock"
)

genre_label <- function(x) {
  unname(GENRE_LABELS[x])
}
