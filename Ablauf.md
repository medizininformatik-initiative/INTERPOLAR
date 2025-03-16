# Generell gilt:
---

- Alle unten genannten Parameter werden in der jeweiligen toml-Datei des Moduls eingestellt.
- Alle diese Parameter haben immer eine ausführliche Beschreibung direkt in der ausgelieferten toml-Datei.
- Im Testbetrieb kann man DEBUG-Parameter aktivieren. Sie beginnen alle mit dem Präfix "DEBUG_".
- Damit nicht aus Versehen DEBUG-Parameter in den Produktivbetrieb kommen, sollten alle DEBUG-Parameter in einer separaten toml-Datei liegen.
- Soll so eine separate DEBUG-toml Datei zusätzlich zur normalen toml-Datei geladen werden, muss deren Dateipfad in der normalen toml-Datei im Paramter DEBUG_PATH_TO_CONFIG_TOML angegeben werden.
- Die Parameter in der separaten toml-Datei ergänzen die vorhandenen Parameter aus der normalen toml-Datei oder überschreiben sie, falls dieselbe Variable in beiden toml-Dateien steht.
- Im Echtbetrieb sollten keinerlei Parameter in den toml-Dateien aktiviert sein, deren Name mit "DEBUG_" beginnt.
- Stehen alle Debug-Parameter in der separaten toml-Datei, sollte ein Deaktivieren des Parameters DEBUG_PATH_TO_CONFIG_TOML in der normalen toml-Datei zum Deaktivieren aller DEBUG-Parameter reichen.
- Am Ende eines Laufs jedes Moduls gibt es eine Warnung, wenn Debug-Parameter aktiv waren.

# cd2db
---

Ziel: Finde alle Patienten-IDs (PIDs) mit einem offenen Einrichtungskontakt, die während des Einrichtungskontaktes mind. 1 mal auf einer Interpolar-Station waren.

## 1. FHIR-Search Anfrage nach allen Encountern, die zum aktuellen Datum noch nicht beendet sind.

- Die FHIR-Search Anfrage bezieht sich immer auf das aktuelle Datum und sucht nach Encountern mit date=lt<%Aktuelles_Datum%> (date ist dabei immer das start date der period des Encounters).
- Außerdem muss der status der Encounter "in-progress" sein. 
- Sollten ein oder mehrere anderere (nicht KDS-konforme) Status-Werte in den FHIR-Daten vorliegen, kann das über FHIR_SEARCH_ENCOUNTER_STATUS gesetzt werden, so dass statt dessen danach gesucht wird.
- Wird der Paramter FHIR_SEARCH_ENCOUNTER_STATUS gar nicht aktiviert, gilt der Default in "in-progress". Wird er aktiviert, aber der Wert ist leer, dann wird der Status gar nicht abgefragt.
- Über FHIR_SEARCH_ENCOUNTER_CLASS kann auf das class/code Attribute des Encounters eingeschränkt werden. Sollen hier von vornherein nur stationäre Encounter gefunden werden, dann kann man "IMP" angeben oder "IMP,SS", falls auch teilstationäre Encounter gefunden werden sollen. Der Default hier ist ein leerer Wert - also keine Einschränkung.
- Über FHIR_SEARCH_ENCOUNTER_LOCATION_IDS kann man beim FHIR-Search nach Location-IDs in den Encountern filtern, wenn diese in den Encountern als Referenz vorhanden sind (üblicherweise  in Versorgungsstellenkontakten).
- Über FHIR_SEARCH_ENCOUNTER_ADDITIONAL_PARAMETERS kann man irgendwelche weiteren Parameter an die bisherige FHIR-Search Anfrage anhängen. Der eingegebene Parameter-Wert wird wie angegeben an die FHIR-Search-Anfrage angehängt. Damit kann man auch alle anderen FHIR_SEARCH_ENCOUNTER-Parameter ersetzen oder weitere Encounter-search-Parameter hinzufügen.

- Zur testweisen Ausgabe der sich aus allen Einstellungen ergebenden FHIR-Serach-Anfrage (ohne die Toolchain weiter auszuführen), kann man den Debug-Parameter DEBUG_FHIR_SEARCH_ENCOUNTER_REQUEST_TEST auf true setzen.

**Ergebnis:** Die FHIR-Search-Anfrage liefert alle Encounter, die potenziell als aktuelle Interpolar-Encounter in Frage kommen. Sie können, müssen aber nicht bereits auf Interpolar Stationen eingeschränkt sein. 

**Beachte:** Je weniger Einschränkungen durch Parameter gesetzt werden, umso größer ist die Rückgabemenge an Encounter-Ressourcen. Wenig Einschränkung kann bereits beim FHIR-Search langsam sein und dann natürlich bei den weiteren Verarbeitungsschritten.

**2. fhir_crack() = Verflachen der FHIR-Encounter in Tabellenform**

- Die entstehende Tabelle enthält ein paar wenige Standardspalten (id, subject/reference, period/start, period/end) + die Spalten, die für die im nächsten Schritt benötigten Encounter-Filter angegeben sind
- Die Tabelle läuft nicht durch fhir_melt(). Dadurch stehen Listenwerte aus der FHIR-Ressource (z.B. mehrere Identifier im Feld identifier/value) immer nur in einer einzigen Tabellenzelle und sind durch den Separator " ~ " voneinander getrennt.

**3. Erstellen der internen Tabelle pids_per_ward über ENCOUNTER_FILTER_PATTERN**

- Ziel: Tabelle mit den Spalten ward_name, encounter_id, patient_id, also eine Zuordnung für Encounter mit ihrer zugehörigen PID zu einem Stationsnamen.
- Diese Zuordnung muss nicht eindeutig sein, d.h. derselbe Encounter kann mehreren Station(sname)en gleichzeitig zugeordnet sein (idealerweise sollte das aber eindeutig sein).
- Welche Arten Encounter gefunden und welchem Stationsnamen sie zugeordnet werden, wird durch die toml-Parameter mit dem Präfix ENCOUNTER_FILTER_PATTERN festgelegt.
Funktionsweise der ENCOUNTER_FILTER_PATTERNs:
- Für jede Station muss ein eigenes Pattern angelegt und darin ein eindeutiger ward_name festgelegt werden. 
- Der Stationsname im Pattern wird später im Redcap für die gefundenen Fälle angezeigt. 
- Die Pattern selbst stellen zeilenweise ODER-Bedingungen dar, die bei einem zu findenden Encounter erfüllt sein müssen.
- Innerhalb einer Zeile bzw. einer einzelnen ODER-Bedingung können mehrere Bedingungen durch + als UND verknüpft werden.
- Eine einzelne Bedingung ist immer in "key = value" gegliedert. 
- key ist ein xpath-Ausdruck aus der Encounter-Ressource (z.B. location/location/reference).
- value ist der Wert, der bei den zu findenden Encounter in dem unter key angegebenen xpath stehen muss und muss in einfachen Anführungszeichen stehen.
- value wird als grep-Pattern interpretiert
- Solange value keinerlei Sonderzeichen enthält, kann hier einfach der zu findende String angebene werden.
- Sonderzeichen müssen den grep-Pattern Regeln entsprechend escaped werden (Hilfe: siehe ChatGPT und Co :)

- Alle in 2. gefundenen Encounter werden anhand der ENCOUNTER_FILTER_PATTERNs gefiltert. Trifft eine der ODER-Bedignungen eines Patterns zu, wird der Encounter mit seiner zugehörigen PID dem jeweiligen Stationsnamen zugeordnet.

**Ergebnis:** Tabelle pids_per_ward mit Stationsnamen, PIDs und Encountern, aus denen die PID extrahiert wurde. Die Encounter können Einrichtungs-, Abteilungs- und Versorgungsstellenkontakte sein. Dieselbe PID kann über verschiedene Encounterarten gefunden werden. Sollten sich 2 Encounter-Filter inhaltlich überschneiden, können dieselben Encounter mehreren Stationen zugeordnet sein (was i.d.R. nicht sinnvoll ist).

**4. Laden aller Ressourcen zu den gefundenen PIDs und aller von diesen Ressourcen referenzierten Ressourcen**

- Anhand der PIDs in der in Schritt 3. erstellten Tabelle werden alle FHIR-Ressourcen geladen.
- Das sind alle Resourcen die in der Tabelle [Table_Description.xlsx](LINK???) stehen (Patient, Encounter, Condition, Observation, MedicationRequest, ...).
- Um den Download- und Weiterverarbeitungsaufwand zu minimieren, werden alle Ressourcen anhand des lastUpdateDate geladen.
- Das lastUpdateDate ergibt sich aus dem spätesten Zeitpunkt, an dem die Patient-Ressource mit der jeweiligen PID das letzte Mal in die Datenbank geschrieben wurde - 1 Tag.
- Danach werden alle Ressourcen geladen, die von den PID-abhängigen Ressourcen referenziert werden und ebenfalls in der Table_Description.xlsx stehen (Medication, Location).

**5. fhir_crack() = Verflachen aller Ressourcen in Tabellenform**

- Die entstehenden Tabellen enthalten genau die Spalten, die in der Table_Description.xlsx jeweils angegeben sind.
- 

- Die Tabelle läuft nicht durch fhir_melt(). Dadurch stehen Listenwerte aus der FHIR-Ressource (z.B. mehrere Identifier im Feld identifier/value) immer nur in einer einzigen Tabellenzelle und sind durch den Separator " ~ " voneinander getrennt.


