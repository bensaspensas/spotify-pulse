# mod_overview.R -- KPIs + release/popularity trends (ggiraph).

overview_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    bslib::layout_column_wrap(
      width = 1 / 4, fill = FALSE,
      bslib::value_box(
        title = "Tracks", value = shiny::textOutput(ns("n_tracks")),
        showcase = shiny::icon("music"), theme = "success"
      ),
      bslib::value_box(
        title = "Artists", value = shiny::textOutput(ns("n_artists")),
        showcase = shiny::icon("user"), theme = "secondary"
      ),
      bslib::value_box(
        title = "Avg. popularity", value = shiny::textOutput(ns("avg_pop")),
        showcase = shiny::icon("fire"), theme = "secondary"
      ),
      bslib::value_box(
        title = "Avg. duration", value = shiny::textOutput(ns("avg_dur")),
        showcase = shiny::icon("clock"), theme = "secondary"
      )
    ),
    bslib::layout_column_wrap(
      width = 1 / 2,
      bslib::card(
        full_screen = TRUE,
        bslib::card_header("Tracks released per year"),
        ggiraph::girafeOutput(ns("trend"), height = "420px")
      ),
      bslib::card(
        full_screen = TRUE,
        bslib::card_header("Average popularity by genre"),
        ggiraph::girafeOutput(ns("genre_pop"), height = "420px")
      )
    )
  )
}

overview_server <- function(id, filtered) {
  shiny::moduleServer(id, function(input, output, session) {

    kpis <- shiny::reactive(kpi_summary(filtered()))

    output$n_tracks  <- shiny::renderText(format(kpis()$n_tracks, big.mark = ","))
    output$n_artists <- shiny::renderText(format(kpis()$n_artists, big.mark = ","))
    output$avg_pop   <- shiny::renderText(sprintf("%.1f / 100", kpis()$avg_popularity))
    output$avg_dur   <- shiny::renderText(sprintf("%.1f min", kpis()$avg_duration))

    output$trend <- ggiraph::renderGirafe({
      yearly <- agg_yearly(filtered())
      yearly[, tooltip := sprintf(
        "%s — %d<br/>%s tracks<br/>avg popularity %.1f",
        genre_label(playlist_genre), release_year,
        format(n_tracks, big.mark = ","), avg_popularity
      )]

      gg <- ggplot2::ggplot(
        yearly,
        ggplot2::aes(release_year, n_tracks, colour = playlist_genre)
      ) +
        ggplot2::geom_line(linewidth = 0.7, alpha = 0.9) +
        ggiraph::geom_point_interactive(
          ggplot2::aes(tooltip = tooltip, data_id = paste(playlist_genre, release_year)),
          size = 1.6
        ) +
        scale_genre() +
        ggplot2::labs(x = NULL, y = "Tracks released") +
        theme_pulse()

      girafe_defaults(gg)
    })

    output$genre_pop <- ggiraph::renderGirafe({
      genres <- agg_genre(filtered())
      genres[, label := genre_label(playlist_genre)]
      genres[, tooltip := sprintf(
        "%s<br/>%s tracks<br/>avg popularity %.1f",
        label, format(n_tracks, big.mark = ","), avg_popularity
      )]

      gg <- ggplot2::ggplot(
        genres,
        ggplot2::aes(
          stats::reorder(label, avg_popularity), avg_popularity,
          fill = playlist_genre
        )
      ) +
        ggiraph::geom_col_interactive(
          ggplot2::aes(tooltip = tooltip, data_id = playlist_genre),
          width = 0.7
        ) +
        ggplot2::coord_flip() +
        scale_genre(aesthetics = "fill") +
        ggplot2::labs(x = NULL, y = "Average popularity (0-100)") +
        theme_pulse() +
        ggplot2::theme(legend.position = "none")

      girafe_defaults(gg)
    })
  })
}
