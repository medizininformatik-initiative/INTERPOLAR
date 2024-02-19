FROM interpolar_r-etlutils

RUN apt-get update \
    && apt-get install -y libsodium-dev

RUN /rocker_scripts/bin/install2.r redcapAPI dplyr

COPY db2frontend db2frontend

RUN R CMD build db2frontend

RUN R CMD INSTALL --preclean --no-multiarch --with-keep.source db2frontend

COPY StartDB2Frontend.R /src/StartDB2Frontend.R

COPY db2frontend_config.toml /src/db2frontend_config.toml