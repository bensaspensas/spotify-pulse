# mod_tracks.R -- searchable top-tracks table (DT).

tracks_ui <- function(id) {
  ns <- shiny::NS(id)

  bslib::card(
    full_screen = TRUE,
    bslib::card_header("Top tracks in the current selection"),
    DT::DTOutput(ns("table"))
  )
}

tracks_server <- function(id, filtered) {
  shiny::moduleServer(id, function(input, output, session) {

    output$table <- DT::renderDT({
      dt <- top_tracks(filtered())
      dt[, playlist_genre := genre_label(playlist_genre)]
      dt[, duration_min := round(duration_min, 2)]

      DT::datatable(
        dt,
        colnames = c(
          "Track", "Artist", "Album", "Genre", "Year", "Popularity",
          "Danceability", "Energy", "Valence", "Tempo", "Duration (min)"
        ),
        rownames = FALSE,
        selection = "none",
        options = list(
          pageLength = 15,
          dom = "ftip",
          order = list(list(5, "desc")),
          scrollX = TRUE
        ),
        style = "bootstrap4"
      ) |>
        DT::formatRound(c("danceability", "energy", "valence"), 2) |>
        DT::formatRound("tempo", 0) |>
        DT::formatStyle(
          "track_popularity",
          background = DT::styleColorBar(c(0, 100), "#1DB95455"),
          backgroundSize = "95% 70%",
          backgroundRepeat = "no-repeat",
          backgroundPosition = "center"
        )
    })
  })
}
