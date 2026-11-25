# ICD-10-GM-Jahreskataloge 2023–2026

Unveränderte offizielle BfArM-FHIR-Pakete mit den endständigen Jahreskodes.
`sources.json` dokumentiert Herkunft, Paketversion, Prüfsumme und Umfang.

## Nutzungsbedingungen und Quellenangaben

Die Daten unterliegen den beigefügten BfArM-Bedingungen, nicht der Apache-2.0-Lizenz
des Programmcodes. Die beim Download am 14.11.2026 geltenden Bedingungen stehen
unverändert in `BfArM-ICD10GM-conditions.xhtml`; der vorgeschriebene Quellenanhang
ist in `BfArM-ICD10GM-sources.html.gz` archiviert. Die Pakete bleiben unverändert.
Die Werke dürfen gemäß den Bedingungen keine kommerzielle Werbung enthalten.
Bedingungen und Quellenangaben sind zusammen mit den Daten weiterzugeben.

Die vorliegende Ausgabe beruht (1) auf der vollständigen amtlichen Fassung der Internationalen
statistischen Klassifikation der Krankheiten und verwandter Gesundheitsprobleme, 10. Revision,
und (2) auf der australischen ICD -10- AM , First Edition. Die englischsprachige
Originalausgabe zu (1) wurde 1992 von der Weltgesundheitsorganisation ( WHO ) veröffentlicht
als International Statistical Classification of Diseases and Related Health Problems, Tenth
Revision, Geneva, WHO , Vol. 1, 1992; die englischsprachige Originalausgabe zu (2) wurde 1998
vom australischen National Centre for Classification in Health veröffentlicht als Volume 1 of
The International Statistical Classification of Diseases and Related Health Problems, 10th
Revision, Australian Modification ( ICD -10- AM ), First Edition. © zu (1):
Weltgesundheitsorganisation ( WHO ) 1992 © zu (2): Commonwealth of Australia 1998 Der
Generaldirektor der Weltgesundheitsorganisation ( WHO ) hat die Übersetzungsrechte für eine
deutschsprachige Ausgabe an das Bundesinstitut für Arzneimittel und Medizinprodukte ( BfArM )
vergeben, das für die Übersetzung allein verantwortlich ist. Das Commonwealth of Australia hat
die Übersetzungsrechte für eine deutschsprachige Ausgabe an das Bundesinstitut für Arzneimittel
und Medizinprodukte ( BfArM ) vergeben, das für die Übersetzung allein verantwortlich ist.
Herausgegeben vom Bundesinstitut für Arzneimittel und Medizinprodukte ( BfArM ) im Auftrag des
Bundesministeriums für Gesundheit ( BMG ) Die Erstellung bzw. der Druck erfolgt unter
Verwendung der maschinenlesbaren Fassung des Bundesinstituts für Arzneimittel und
Medizinprodukte ( BfArM ).

## Verwendung

`etlutils::loadICDCatalogues()` lädt die endständigen Codes der Jahre 2023–2026.
`etlutils::isTerminalICD()` prüft die Zugehörigkeit zum jeweiligen Jahreskatalog.
Die aufrufende Analyse bestimmt das Jahr. Die Prüfung benötigt keinen Netzwerkzugriff.
