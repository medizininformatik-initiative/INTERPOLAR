terminology_path <- file.path(
  "R-dataprocessor",
  "dataprocessor",
  "inst",
  "extdata",
  "Fachabteilungsschluessel.xlsx"
)
mapping_path <- path.expand(
  "~/Downloads/Interpolar-Station-Fachabteilung_mapped_01.xlsx"
)
survey_column <- "Fachabteilung Usual Care Umfrage"

stopifnot(file.exists(terminology_path), file.exists(mapping_path))

terminology <- etlutils::readExcelFileAsTableList(terminology_path)[[1]]
terminology <- etlutils::removeTableHeader(terminology, c("Code", "Display"))
valid_values <- paste(
  sprintf("%04d", as.integer(terminology$Code)),
  trimws(terminology$Display)
)

mapping <- etlutils::readExcelFileAsTableList(mapping_path)[[1]]
mapping <- etlutils::removeTableHeader(mapping, survey_column)
survey_cells <- mapping[[survey_column]]
survey_cells <- survey_cells[!is.na(survey_cells) & nzchar(trimws(survey_cells))]
survey_values <- trimws(unlist(strsplit(survey_cells, ";", fixed = TRUE)))

comparison <- data.frame(
  fachabteilungsschluessel = sort(unique(survey_values)),
  vorhanden = sort(unique(survey_values)) %in% valid_values,
  row.names = NULL
)

print(comparison)

missing_values <- comparison$fachabteilungsschluessel[!comparison$vorhanden]
if (length(missing_values) == 0L) {
  message("Alle Umfragewerte kommen in der Fachabteilungsschluessel-Datei vor.")
} else {
  message("Nicht gefundene Umfragewerte:")
  message(paste(missing_values, collapse = "\n"))
}
