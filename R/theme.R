# theme.R -- bslib theme and matching ggplot2 styling.

SPOTIFY_GREEN <- "#1DB954"
BG_DARK       <- "#121212"
BG_CARD       <- "#181818"
FG_LIGHT      <- "#F5F5F5"
FG_MUTED      <- "#B3B3B3"

GENRE_COLORS <- c(
  edm   = "#1DB954",
  latin = "#F573A0",
  pop   = "#509BF5",
  "r&b" = "#AF2896",
  rap   = "#FFC864",
  rock  = "#E8115B"
)

#' bslib theme for the whole app.
app_theme <- function() {
  bslib::bs_theme(
    version    = 5,
    bg         = BG_DARK,
    fg         = FG_LIGHT,
    primary    = SPOTIFY_GREEN,
    secondary  = FG_MUTED,
    base_font  = "Inter, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif",
    "card-bg"  = BG_CARD,
    "border-color" = "#282828"
  )
}

#' Shared ggplot2 theme matching the dark UI.
theme_pulse <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background   = ggplot2::element_rect(fill = BG_CARD, colour = NA),
      panel.background  = ggplot2::element_rect(fill = BG_CARD, colour = NA),
      panel.grid.major  = ggplot2::element_line(colour = "#2A2A2A"),
      panel.grid.minor  = ggplot2::element_blank(),
      text              = ggplot2::element_text(colour = FG_LIGHT),
      axis.text         = ggplot2::element_text(colour = FG_MUTED),
      axis.title        = ggplot2::element_text(colour = FG_MUTED),
      legend.position   = "bottom",
      legend.text       = ggplot2::element_text(colour = FG_LIGHT),
      legend.title      = ggplot2::element_blank(),
      plot.title        = ggplot2::element_text(face = "bold"),
      strip.text        = ggplot2::element_text(colour = FG_LIGHT, face = "bold")
    )
}

#' Genre colour scale used across all charts.
scale_genre <- function(aesthetics = "colour") {
  ggplot2::scale_discrete_manual(
    aesthetics = aesthetics,
    values     = GENRE_COLORS,
    labels     = genre_label
  )
}

#' Standard interactivity options for girafe widgets.
girafe_defaults <- function(gg, height_svg = 4.5) {
  ggiraph::girafe(
    ggobj = gg,
    width_svg = 9, height_svg = height_svg,
    options = list(
      ggiraph::opts_hover(css = "stroke-width:2.5px;opacity:1;"),
      ggiraph::opts_hover_inv(css = "opacity:0.35;"),
      ggiraph::opts_tooltip(
        css = paste0(
          "background:", BG_DARK, ";color:", FG_LIGHT, ";",
          "padding:8px 10px;border-radius:6px;border:1px solid #333;",
          "font-family:Inter,sans-serif;font-size:12px;"
        )
      ),
      ggiraph::opts_toolbar(saveaspng = FALSE),
      ggiraph::opts_selection(type = "none")
    )
  )
}
