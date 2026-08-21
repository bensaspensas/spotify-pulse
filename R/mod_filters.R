# mod_filters.R -- sidebar filter module.
#
# The module owns the filter widgets and returns a single reactive with the
# validated filter values; the actual filtering happens once in the app
# server so every tab shares the same filtered table.

filters_ui <- function(id, songs) {
  ns <- shiny::NS(id)
  year_rng <- range(songs$release_year)

  list(
    shiny::checkboxGroupInput(
      ns("genres"), "Genre",
      choices  = stats::setNames(names(GENRE_LABELS), GENRE_LABELS),
      selected = names(GENRE_LABELS)
    ),
    shiny::sliderInput(
      ns("years"), "Release year",
      min = year_rng[1], max = year_rng[2],
      value = c(1990, year_rng[2]), step = 1, sep = ""
    ),
    shiny::sliderInput(
      ns("popularity"), "Track popularity",
      min = 0, max = 100, value = c(0, 100), step = 5
    ),
    shiny::actionButton(
      ns("reset"), "Reset filters",
      class = "btn-outline-secondary btn-sm"
    )
  )
}

filters_server <- function(id, songs) {
  shiny::moduleServer(id, function(input, output, session) {
    year_rng <- range(songs$release_year)

    shiny::observeEvent(input$reset, {
      shiny::updateCheckboxGroupInput(
        session, "genres", selected = names(GENRE_LABELS)
      )
      shiny::updateSliderInput(
        session, "years", value = c(1990, year_rng[2])
      )
      shiny::updateSliderInput(session, "popularity", value = c(0, 100))
    })

    shiny::reactive({
      shiny::validate(shiny::need(
        length(input$genres) > 0,
        "Select at least one genre to see results."
      ))
      list(
        genres     = input$genres,
        years      = input$years,
        popularity = input$popularity
      )
    })
  })
}
