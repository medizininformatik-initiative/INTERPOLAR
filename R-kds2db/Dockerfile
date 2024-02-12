FROM interpolar/r-etlutils

COPY kds2db kds2db

RUN R CMD build kds2db

RUN R CMD INSTALL --preclean --no-multiarch --with-keep.source kds2db
