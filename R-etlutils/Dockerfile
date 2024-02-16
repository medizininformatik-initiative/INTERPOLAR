FROM rocker/r-ver:4.3.2

RUN apt-get update \
    && apt-get install -y libssl-dev libcurl4-openssl-dev libpq-dev

RUN /rocker_scripts/bin/install2.r fhircrackr memuse openxlsx RcppTOML DBI lubridate RPostgres

COPY etlutils etlutils

RUN R CMD build etlutils

RUN R CMD INSTALL --preclean --no-multiarch --with-keep.source etlutils

RUN apt-get autoremove && apt-get clean