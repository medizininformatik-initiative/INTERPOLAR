# "MRP_Recalculation" - additive Neuberechnung retrospektiver MRPs

## Funktion

Berechnet retrospektive MRPs fuer einen konfigurierbaren Aufnahmezeitraum erneut und schreibt nur solche MRP-Bewertungen in die Datenbank, die fachlich noch nicht vorhanden sind.

Es werden keine bestehenden Daten in REDCap oder in der Datenbank geloescht. Bereits vorhandene retrospektive MRP-Bewertungen werden anhand von Patient/Record, Medikationsanalyse, Referenzzeitpunkt, Kurzbeschreibung, ATC und MRP-Klasse erkannt und nicht erneut geschrieben.

## Ablauf

Das Modul fuehrt die folgenden Schritte aus:

1. Es liest `start-date` und optional `end-date` ein.
   Ohne Angabe wird fuer beide Parameter das aktuelle Datum verwendet.

2. Es selektiert alle Einrichtungskontakte, deren Beginn und Ende in diesem Zeitraum liegen.
   Dabei wird bewusst nicht vorab ausgeschlossen, ob fuer den Fall bereits retrospektive MRP-Bewertungen existieren.

3. Fuer diese Einrichtungskontakte wird die normale retrospektive MRP-Berechnung erneut ausgefuehrt.
   Dadurch koennen auch bereits bekannte MRPs erneut als Kandidaten entstehen.

4. Die neu berechneten MRP-Kandidaten werden mit den bereits vorhandenen Eintraegen in
   `v_retrolektive_mrpbewertung_fe` verglichen.
   Als fachlicher Schluessel werden `record_id`, `ret_meda_id`, `ret_meda_dat_referenz`,
   `ret_kurzbeschr`, `ret_atc1`, `ret_ip_klasse_01`, `ret_ip_klasse_disease` und `ret_atc2`
   verwendet.

5. Nur fachlich neue retrospektive MRP-Bewertungen bleiben erhalten.
   Die zugehoerigen Eintraege aus `dp_mrp_calculations` werden auf dieselben neuen `ret_id`
   reduziert.

6. Fuer die verbleibenden neuen Zeilen wird `redcap_repeat_instance` pro `record_id`
   neu fortlaufend vergeben.
   Dadurch kollidieren neue Wiederholungsinstanzen nicht mit bereits nach REDCap exportierten
   Eintraegen.

7. Die verbleibenden neuen Tabellenzeilen werden additiv in die Datenbank geschrieben.
   Bereits vorhandene Daten werden dabei nicht geloescht oder ueberschrieben.

8. Anschliessend startet automatisch `db2frontend`, damit die neuen retrospektiven
   MRP-Bewertungen nach REDCap exportiert werden.

## Ausfuehrung

Aufruf des Dataprocessors mit `MRP_Recalculation` als manual-start-Submodul:

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R MRP_Recalculation
```

Alternativ kann das dedizierte Startskript verwendet werden:

``` console
docker compose run --rm --no-deps r-env Rscript R-cdstoolchain/StartMRPRecalculation.R
```

Optional kann ein Zeitraum gesetzt werden. Der Zeitraum bezieht sich auf den Beginn des Einrichtungskontakts. Ohne Angabe wird fuer `start-date` und `end-date` jeweils das aktuelle Datum verwendet.

``` console
docker compose run --rm --no-deps r-env Rscript R-dataprocessor/StartDataProcessor.R MRP_Recalculation start-date=2025-09-01 end-date=2025-09-08
```

Mit dediziertem Startskript:

``` console
docker compose run --rm --no-deps r-env Rscript R-cdstoolchain/StartMRPRecalculation.R start-date=2025-09-01 end-date=2025-09-08
```

Nach der additiven Neuberechnung werden die neu verfuegbaren DB-Daten automatisch nach REDCap exportiert.
