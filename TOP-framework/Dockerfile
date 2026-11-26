FROM ghcr.io/onto-med/top-interpolar-algorithms:1
RUN apk add --no-cache postgresql-client zip unzip
COPY run-and-archive.sh /opt/app/run-and-archive.sh
ENTRYPOINT ["/bin/bash", "/opt/app/run-and-archive.sh"]
