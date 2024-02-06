FROM postgres:15

RUN apt-get update && \
	apt-get -y install postgresql-15-cron

# Cleanup
RUN apt-get clean && \
        apt-get autoremove -yq && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
