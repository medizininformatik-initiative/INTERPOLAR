FROM interpolar_r-etlutils

COPY kds2db kds2db

RUN R CMD build kds2db

RUN R CMD INSTALL --preclean --no-multiarch --with-keep.source kds2db

COPY StartRetrieval.R /src/StartRetrieval.R

COPY kds2db_config.toml /src/kds2db_config.toml