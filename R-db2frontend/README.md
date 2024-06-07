# DB2Frontend - Transfer von Daten aus dem CDS_HUB in das Frontend und zurück

## Konfiguration

Damit dieses R-Script funktioniert, muss zuvor der Token für die REDCap-API in die Konfigurationsdatei R-db2frontend/db2frontend_config.toml eingetragen werden:
```toml
# REDCap API token
REDCAP_TOKEN = "Fill with your REDCap API token"
```
Den API Token finden Sie im importierten REDCap-Projekt unter: Abschnitt "Applications" im Menu am linken Rand -> API -> Reiter "My Token" -> Button "Create API token now".

## Ausführung

Anschließen können Sie die in der CDS_HUB_DB für das Frontend verfügbaren Werte übernehmen:
```console
docker-compose run --rm --no-deps r-env Rscript R-db2frontend/StartDB2Frontend.R
```
