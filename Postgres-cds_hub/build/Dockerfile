FROM postgres:15

RUN apt-get update && \
	apt-get -y install postgresql-15-cron

RUN apt-get update && \
apt-get install -y postgresql-15-pg-background
	
# Cleanup
RUN apt-get clean && \
        apt-get autoremove -yq && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
