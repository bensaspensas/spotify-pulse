# Shared fixtures for unit tests: a small synthetic songs table with the
# same shape as the prepared dataset.

make_songs <- function() {
  data.table::data.table(
    track_id         = c("a", "a", "b", "c", "d", "e"),
    track_name       = c("Alpha", "Alpha", "Beta", "Gamma", "Delta", "Epsilon"),
    track_artist     = c("One", "One", "Two", "Two", "Three", "Four"),
    track_popularity = c(80L, 80L, 60L, 40L, 90L, 10L),
    track_album_name = "Album",
    release_year     = c(2019L, 2019L, 2020L, 2020L, 1995L, 2005L),
    playlist_genre   = c("pop", "rock", "pop", "rap", "rock", "edm"),
    playlist_subgenre = "sub",
    danceability     = c(0.9, 0.9, 0.5, 0.7, 0.2, 0.6),
    energy           = c(0.8, 0.8, 0.4, 0.6, 0.9, 0.5),
    speechiness      = 0.1,
    acousticness     = 0.2,
    instrumentalness = 0.0,
    liveness         = 0.15,
    valence          = c(0.7, 0.7, 0.3, 0.5, 0.8, 0.4),
    tempo            = c(120, 120, 95, 140, 170, 128),
    loudness         = -6.5,
    duration_min     = c(3.5, 3.5, 4.0, 2.8, 5.2, 3.1)
  )
}
