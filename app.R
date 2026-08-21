# Spotify Pulse -- an interactive explorer of 30k+ Spotify tracks.
#
# Entry point. Files under R/ are auto-sourced by Shiny; the dataset is
# loaded once per R process and shared across sessions.

library(shiny)
library(bslib)
library(data.table)
library(ggplot2)
library(ggiraph)
library(plotly)
library(DT)

# Shiny normally auto-sources R/ next to app.R, but some tooling (e.g.
# shinytest2 when a DESCRIPTION file is present) disables autoloading, so
# the helpers are sourced explicitly. Re-sourcing is idempotent.
invisible(lapply(sort(list.files("R", full.names = TRUE)), source))

songs <- load_songs()

ui <- bslib::page_navbar(
  title = tags$span(
    shiny::icon("spotify", class = "text-success me-1"), "Spotify Pulse"
  ),
  theme = app_theme(),
  fillable = FALSE,
  sidebar = bslib::sidebar(
    title = "Filters", width = 280,
    filters_ui("filters", songs)
  ),
  bslib::nav_panel("Overview", icon = shiny::icon("chart-line"),
                   overview_ui("overview")),
  bslib::nav_panel("Audio features", icon = shiny::icon("wave-square"),
                   features_ui("features")),
  bslib::nav_panel("Tracks", icon = shiny::icon("list"),
                   tracks_ui("tracks")),
  bslib::nav_spacer(),
  bslib::nav_item(
    tags$a(
      shiny::icon("github"), "Source",
      href = "https://github.com/bensaspensas/spotify-pulse",
      target = "_blank", class = "nav-link"
    )
  )
)

server <- function(input, output, session) {
  filters <- filters_server("filters", songs)

  filtered <- reactive({
    f <- filters()
    filter_songs(songs, f$genres, f$years, f$popularity)
  }) |>
    bindCache(filters())

  overview_server("overview", filtered)
  features_server("features", filtered)
  tracks_server("tracks", filtered)
}

shinyApp(ui, server)
