### Datenfluss

Am Ende der Ausführung der Module stehen persistente Daten nur noch in den Tabellen des Schemas "db_log". Dieses Schema bzw. dessen Tabellen bilden den Kern der Datenbank, die alle Datensätze sowie Zeitstempel zu deren Gültigkeit dauerhaft speichert. Das gilt für alle 3 Module, die Daten zur Datenbank hinzufügen ("cds2db", "dataprocessor" und "db2frontend"). Jegliche operationen in den Modulen beziehen sich immer auf zuvor im Kern (Schemas "db_log") persistent gespeicherten Datenstand um eine Nachvollziehbarkeit zu gewährleisten. Damit kann es eine zeitliche abhängigkeit zwischen den Modulen / Prozessschritten geben, bis das "db_log" Schema bedient ist.
Jede zuführung von Informationen in den Schnittstellen wird gespeichert und jede Datenausgabe über die Schnittstelle, läßt sich im nachhinein zu einem bestimmten Zeitpunkt rekonstruieren.

#### Voraussetzungen/Vorbereitung

Die nun beschriebene Initialisierung wurde vom Entwicklerteam einmalig bzw. immer wenn sich an der Struktur der Datenbank etwas geändert hat, ausgeführt. Dieser Abschnitt dient nur der Vollständigkeit und die darin beschriebenen Abläufe werden nur einmal beim initialiesieren der CDS Hub DB ausgeführt. Im Berieb als der eigentlichen Ausführen der "CDS tool chain" werden sie nicht mehr benötigt.

Zur Initialisierung des Prozesses musste die Excel-Datei ["Table_Description_Definition.xlsx"](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-cds2db/cds2db/inst/extdata/Table_Description_Definition.xlsx) definiert werden. Sie bildet den tatsächlichen COI und gibt vor, wie die FHIR-Abfragen gestellt werden und wie die Datenbank zur Speicherung der Ergebnisse dieser Abfragen aufgebaut ist.

Mithilfe eines [R-Generatorskriptes](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-cds2db/cds2db/R/Init_01_Expand_TableDescription.R) wird aus der wesentlich übersichtlicheren "Table_Description_Definition.xlsx" die vollständige ["Table_Description.xlsx"](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-cds2db/cds2db/inst/extdata/Table_Description.xlsx) expandiert. In dieser generierten Datei stehen alle abgefragten FHIR-Ressourcen sowie alle absoluten XML-Pfade dieser Ressourcen, die am Ende als Spalten in die jeweilige Tabelle in die Datenbank geschrieben werden.

Nachdem die vollständige "Table_Description.xlsx" vorliegt, werden mit einem weiteren [Generatorskript](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-cds2db/cds2db/R/Init_02_Create_TableStatements.R) unter Benutzung vorher definierter [SQL-Templates](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/main/Postgres-cds_hub/init/template) wesentliche Teile der [Datenbankskripte](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/main/Postgres-cds_hub/init) generiert, die die Tabellen der Postgres-Datenbank zur Speicherung der FHIR-Abfragen und Funktionen innerhalb der Datenbank anlegen.

Diese beiden Generatorskripte liegen auch im R-Verzeichnis des im folgenden beschriebenen Moduls "cds2db". Die SQL-Templates sowie die fertigen SQL-Skripte befinden sich im "init"-Verzeichnis des Moduls "cds_hub".

Das Vorgehen stellt sicher, dass die umfangreichen FHIR-Abfragen und Strukturen immer genau zur Datenbank passen und sich bei Bedarf einfach anpassen lassen. (MR Konfigurationsdatei mit Tabellenbezeichnung und Rechten nennen?)

Analog werden die Strukturen und Überführungsfunktionen für das Frontend in den verschiedenen Bereichen mit SQL-Skripten bei der initaliesierung angelegt. Derzeit sind diese Skripte noch statisch - evtl. werden diese ebenfalls in Zukunft mit Templates und Codegenerierung erzeugt werden.

#### Modul "cds2db"

##### FHIR Patienten ID Filterung
Als allererstes werden bei der Ausführung des Moduls "cds2db" die Interpolar-relevanten Patienten-IDs (Resource-IDs der Patienten auf dem FHIR-Server) mit ihrer entsprechenden Stationszugehörigkeit ermittelt. Dies kann auf 2 Weisen erfolgen:
1. Die IDs werden anhand von Filtern, die in der zugehörigen Konfigurationsdatei für die jeweilige Stationen definiert wurden, ermittelt. Diese Einstellungen und zugehörige Erklärungen befinden sich im Abschnitt ["[retrieve.patient_id_filtering]"](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/1f404656f0b882947ee0a657ed4eeef7931916c6/R-cds2db/cds2db_config.toml#L101C2-L101C31).
2. Es wird eine Textdatei mit entsprechendem Inhalt bereit gestellt. Der Pfad zur Textdatei wird im selben Abschnitt auch in der [Konfigurationsdatei](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/1f404656f0b882947ee0a657ed4eeef7931916c6/R-cds2db/cds2db_config.toml#L106) definiert. Wenn dieser Pfad aktiviert ist, ist Variante 1 automatsch deaktiviert - egal ob Filter definiert sind. Ein Beispiel für eine solche Datei findet sich unter [source_PIDs.txt](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/main/R-cds2db/source_PIDs.txt#L1).

*Wichtig*: Die Namen der Stationen, die am Ende im Frontend angezeigt werden, entsprechen genau den Namen der Stationen in den Filtern bzw. in der Textdatei.

##### Abfrage der Daten vom FHIR Server und Speicherung als RAW-Daten

Der FHIR-Server wird nun anhand der oben beschriebenen, vollständig expandierten "Table_Description.xlsx" abgefragt und die Daten durch den ["fhircrackr"](https://cran.r-project.org/web/packages/fhircrackr/index.html) von ihrer XML-Struktur in flache Tabellen umgewandelt.

Zuerst werden über das Schema "cds2db_in" diese Daten in dessen Tabellen mit dem Suffix "_raw" geschrieben. Dabei wird der Zeitstempel des Einfügens "input_datetime" hinzugefügt. Die Tabellen heißen wie die FHIR-Ressourcen, außer die spezielle Tabelle "pids_per_ward_raw", die die aktuellen Patienten IDs der Interpolarstationen und eine Zuordnung zum Stationsnamen speichert. Danach läuft in regelmäßigen Abständen (Konfiguration) ein Cron-Job und überprüft die Importierten Daten auf Neue bzw. Aktualiesierte Datensätze. Werden neue Datensätze gefunden, werden diese in die gleich heißenden Tabellen des "db_log" Schemas verschoben und damit aus den Tabellen des "cds2db" Schemas entfernt. Bei Aktualiesierten Daten welche bereits früher in die Tabellen des "db_log" überführt wurden, wird die Spalte "last_check_datetime" neu gesetzt, das zu diesem Zeitpunkt die Daten gegenüber dem "input_datetime" unverändert sind. Aus diesem Vorgehen ergibt sich, das bei Änderung des Datensatzes ein neuer gespeichert wird und somit die Historie abgebildet wird. 

Nach erfolgreichen Cron-Job stehen nur noch Daten in "db_log" Tabellen. Sollten Fehler beim überführen durchd en Cron-Job auftreten, verbleibt der betroffene Datensatz in der _raw Tabelle und wird bei der nächsten Ausführung neu versucht zu überführen. 

Dieses Vorgehen stellt sicher, dass alle Datensätze vorhanden sind, aber eben nur ein mal und bekannt ist, wann der Datensatz das erste und das letzte Mal aus einer Abfrage vom FHIR-Server zurückkam.

Die RAW-Daten sind genau die vom FHIR-Server heruntergeladenen Ressourcen, die nur durch den "fhircrackr" geleitet wurden. Also die größtmöglich unveränderten Daten vom Server, nach der pesistenten Speicherung der Daten in den "db_log" Tabellen, werden auf dieser Grundlage die nächsten verarbeitenden Schritte durchgeführt.

Nach dem Schreiben der RAW-Daten in die Datenbank durch das R-Script wartet das Script ca. 1 Minute, um sicher zu stellen, dass der oben genannte Cron-Job mit dem Verschieben in den Kern der Datenbank gelaufen ist.

##### Zerlegung und Typsisierung der Daten

Danach macht das R-Script damit weiter, mit dem Schema "cds2db_out" über Views alle *neuen* RAW-Daten aus den "db_log"-Tabellen abzurufen. Neu heißt, dass der nun folgende Zerlegungs- und Typisierungsprozess diese Daten noch nicht zerlegt und typisiert hat, was an den jeweiligen primary keys der Ursprungsdaten erkannt wird.

Diese Zerlegung ist ein Prozess, der im "fhircrackr" *fhir_melt()* heißt. Die Herrausforderung ist, dass in den RAW-Daten nach dem *fhir_crack()* alle Ressourcen immer genau nur 1 Zeile in der Tabelle der jeweiligen Ressource einnehmen. Wenn diese Ressource aber eine Liste von Unterelementen hat (z.B. Encounter hat eine Liste von Referenzen auf mehrere Diagnosen (Conditions)), dann stehen diese mit einer speziellen Klammerung und in den Klammern enthaltenen Indizes durch Tilde (" ~ ") getrennt in der zugehörigen Spalte.

Diese Klammerung und Indizes müssen nun alle in eigene Zeilen aufgespaltet werden. Dabei werden alle anderen Daten der Zeile jeweils dupliziert. Da diese Listen an vielen Stellen auftauchen, der Vorgang generisch umgesetzt ist und dieses *fhir_melt()* eine recht teure Operation ist, dauert dieser Punkt unter Umständen etwas länger.

Wenn alle Listen in eigene Zeilen zerlegt sind, dann können sie typisiert werden. Bis dahin waren alle Raw-Daten Strings (bzw. in R character). Anhand der [TableDescription-Excel-Tabelle](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/main/R-cds2db/cds2db/inst/extdata) werden nun alle nicht-String-Daten in Zahlen, Datumsangaben, Uhrzeiten usw. umgewandelt.

Nach der Umwandlung werden die nun fertig aufbereiteten Daten wieder über das Schema "cds2db_in" in die zugehörigen Tabellen *ohne* den "_raw"-Suffix geschrieben. Danach erfolgt eine überführung der Daten mittels eines Cron-Job los in den Kern der Datenbank ("db_log") analog der "Speicherung als RAW-Daten".

Damit ist das Modul "cds2db" fertig und nachdem die Daten ebenfalls persitent in den Kern überführt wurden, bilden diese Daten die Grundlage für die Weiterverarbeitung im Modul "dataprocessor".

#### Modul "dataprocessor"

Der Dataprocessor erstellt aus den vom "cds2db" Modul importierten Daten (gespeichert im Kern), die Ausgabetabellen für das Modul "frontend".  Im Moment sind das die Tabellen "patient_fe" und "fall_fe" (_fe - Daten für FrontEnd). Auch hier werden die Daten wieder durch einen Cron-Job in den Kern ("db_log") in Tabellen mit demselben Namen verschoben und persistiert. Erst danach stehen diese dem Frontend zur Verfügung. Die Logik zum erzeugen der Daten für das Frontend wird dem Dataprocessor über R-Skripte..... zugeführt ....

Bei der erzeugung der Daten, werden identifizierende Primärschlüssel der "Quell"-Datensätze mit in den Daten gespeichert um über referenzierung letztendlich bis auf den ursprünglichen FHIR-Datensatz (-Stand) schließen zu können.

Die Tabelle "patient_fe" sollte alle Patienten enthalten, deren FHIR-interne ID in den Eingangsdaten vorhanden war (pids_per_ward ?).

Die Tabelle "fall_fe" sollte eine Liste aller Fälle enthalten, die für Patienten mit den oben genannten IDs aktuell laufen.

*Voraussetzung*: Das aktuelle Datum muss zu den Start- und Enddaten der Encounter passen. Es werden nur Fälle gefunden, deren Startdatum vor dem aktuellen Datum liegt und deren Enddatum nach dem aktuellen Datum liegt oder nicht gesetzt ist. 

Will man hier für Daten aus der Vergangenheit irgendwas sehen, dann muss in der Konfigurationsdatei für den Dataprocessor ([dataprocessor_cofig.toml](https://github.com/medizininformatik-initiative/INTERPOLAR/tree/main/R-dataprocessor)) unter der Variable  ["DEBUG_CURRENT_DATETIME"](https://github.com/medizininformatik-initiative/INTERPOLAR/blob/378980f19c255dec900f1b670b3c4aa08e4fe3e2/R-dataprocessor/dataprocessor_config.toml#L40) ein entsprechend zu den Daten passendes Datum eingestellt werden. Alle Variablen, die im Echtbetrieb deaktiviert sein sollten, haben den Präfix "DEBUG_".


#### Modul "frontend"
Das Frontend stellt die im Modul "dataprocessor" erzeugten Daten dem Frontend im Schema "db2frontend_out" zur Verfügung. Nach der Ausführung des jeweiligen Skripts (R-Skript) zum Datenaustausch mit dem Frontend (zb. RedCap) werden diese in der Oberfläche angezeigt und können bearbeitet werden.
Danach können Neue bzw. geänderte Daten im Schema "db2frontend_in" wieder in die CDS Hub DB geschrieben werden. Dies Erfolgt analog dem Modul "dataprocessor" und am Ende werden die Daten in den zugehörigen Tabellen im Schema "db_log" persisitent gespeichert.

Auch in diesem Modul werden identifizierende Primärschlüssel der "Quell"-Datensätze an das Frontend mit übergeben um beim "wiederimport" der geänderten Daten einen zusammenhang herstellen zu können.

