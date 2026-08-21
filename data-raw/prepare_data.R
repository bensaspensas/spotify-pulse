# Rebuilds the prepared dataset cache (data/spotify_songs.rds) from the raw
# TidyTuesday extract. Run from the project root:
#
#   Rscript data-raw/prepare_data.R
#
# Raw data source (TidyTuesday 2020-01-21, collected via {spotifyr}):
# https://github.com/rfordatascience/tidytuesday/tree/master/data/2020/2020-01-21

for (f in list.files("R", full.names = TRUE)) source(f)

raw      <- read_songs("data-raw/spotify_songs.csv")
prepared <- prepare_songs(raw)

dir.create("data", showWarnings = FALSE)
saveRDS(prepared, "data/spotify_songs.rds", compress = "xz")

cat(sprintf(
  "Prepared %s rows (%s unique tracks) -> data/spotify_songs.rds\n",
  format(nrow(prepared), big.mark = ","),
  format(data.table::uniqueN(prepared$track_id), big.mark = ",")
))
