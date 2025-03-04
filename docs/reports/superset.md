## Reports mit Apache superset

### Installation
* https://superset.apache.org/docs/quickstart
* https://superset.apache.org/docs/installation/docker-compose

#### Superset clonen (herunterladen)
```
$ git clone https://github.com/apache/superset
```

#### Eine Version auswählen und starten
```
# Enter the repository you just cloned
$ cd superset

# Set the repo to the state associated with the latest official version
$ git checkout tags/4.1.1
$ export TAG=4.1.1

# Fire up Superset using Docker Compose
$ docker compose -f docker-compose-image-tag.yml up
```

### Verbindung mit INTERPOLAR Datenbank herstellen