FROM postgres:18

RUN apt-get update && \
	apt-get -y install postgresql-17-cron

RUN apt-get update && \
	apt-get -y install build-essential git postgresql-server-dev-17 libkrb5-dev

RUN git clone --branch v1.9.3 --depth 1 \
    https://github.com/vibhorkum/pg_background.git /usr/src/pg_background

WORKDIR /usr/src/pg_background

RUN make && make install

# Cleanup
RUN apt-get clean && \
        apt-get autoremove -yq && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
