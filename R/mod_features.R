# mod_features.R -- audio-feature exploration (plotly scatter + ggiraph bars).

features_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    bslib::card(
      full_screen = TRUE,
      bslib::card_header("Feature landscape"),
      bslib::layout_sidebar(
        sidebar = bslib::sidebar(
          position = "right", open = TRUE, width = 220,
          shiny::selectInput(
            ns("x"), "X axis", choices = AUDIO_FEATURES, selected = "energy"
          ),
          shiny::selectInput(
            ns("y"), "Y axis", choices = AUDIO_FEATURES, selected = "valence"
          ),
          shiny::helpText(
            "Points are down-sampled (stratified by genre) to keep the",
            "plot responsive on 30k+ tracks."
          )
        ),
        plotly::plotlyOutput(ns("scatter"), height = "460px")
      )
    ),
    bslib::card(
      full_screen = TRUE,
      bslib::card_header("Median feature value by genre"),
      bslib::layout_sidebar(
        sidebar = bslib::sidebar(
          position = "right", open = TRUE, width = 220,
          shiny::selectInput(
            ns("profile_feature"), "Feature",
            choices = AUDIO_FEATURES, selected = "danceability"
          )
        ),
        ggiraph::girafeOutput(ns("profile"), height = "380px")
      )
    )
  )
}

features_server <- function(id, filtered) {
  shiny::moduleServer(id, function(input, output, session) {

    sampled <- shiny::reactive(sample_songs(filtered()))

    output$scatter <- plotly::renderPlotly({
      dt <- sampled()
      x <- input$x
      y <- input$y

      plotly::plot_ly(
        data = dt,
        x = dt[[x]], y = dt[[y]],
        color = ~genre_label(playlist_genre),
        colors = stats::setNames(GENRE_COLORS, genre_label(names(GENRE_COLORS))),
        type = "scatter", mode = "markers",
        marker = list(size = 5, opacity = 0.55),
        text = ~sprintf(
          "%s<br>%s (%d)<br>popularity %d",
          track_name, track_artist, release_year, track_popularity
        ),
        hoverinfo = "text"
      ) |>
        plotly::layout(
          paper_bgcolor = BG_CARD, plot_bgcolor = BG_CARD,
          font = list(color = FG_LIGHT, family = "Inter, sans-serif"),
          xaxis = list(title = names(which(AUDIO_FEATURES == x)), gridcolor = "#2A2A2A"),
          yaxis = list(title = names(which(AUDIO_FEATURES == y)), gridcolor = "#2A2A2A"),
          legend = list(orientation = "h", y = -0.18)
        ) |>
        plotly::config(displaylogo = FALSE)
    })

    output$profile <- ggiraph::renderGirafe({
      feature <- input$profile_feature
      prof <- feature_by_genre(filtered(), feature)
      prof[, label := genre_label(playlist_genre)]
      prof[, tooltip := sprintf("%s<br/>median %.2f", label, value)]

      gg <- ggplot2::ggplot(
        prof,
        ggplot2::aes(stats::reorder(label, value), value, fill = playlist_genre)
      ) +
        ggiraph::geom_col_interactive(
          ggplot2::aes(tooltip = tooltip, data_id = playlist_genre),
          width = 0.7
        ) +
        ggplot2::coord_flip() +
        scale_genre(aesthetics = "fill") +
        ggplot2::labs(x = NULL, y = names(which(AUDIO_FEATURES == feature))) +
        theme_pulse() +
        ggplot2::theme(legend.position = "none")

      girafe_defaults(gg, height_svg = 3.8)
    })
  })
}
