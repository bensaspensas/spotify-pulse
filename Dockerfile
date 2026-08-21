# Spotify Pulse -- containerised Shiny app.
#
#   docker build -t spotify-pulse .
#   docker run --rm -p 3838:3838 spotify-pulse
#
# rocker/shiny ships R + Shiny Server; packages are installed as binaries
# from the Posit Public Package Manager, so the build stays fast.

FROM rocker/shiny:4.4.2

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libcurl4-openssl-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -q -e "install.packages( \
      c('bslib', 'data.table', 'DT', 'ggiraph', 'ggplot2', 'plotly'), \
      repos = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest')"

COPY app.R /srv/shiny-server/spotify-pulse/
COPY R/    /srv/shiny-server/spotify-pulse/R/
COPY data/ /srv/shiny-server/spotify-pulse/data/

RUN rm -rf /srv/shiny-server/index.html /srv/shiny-server/sample-apps

USER shiny
EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
