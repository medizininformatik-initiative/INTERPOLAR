##############################################################################################
# Drug-Disease Checking
##############################################################################################

drug_disease_org <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_300925.xlsx")$`Drug-Disease_final`
drug_disease_org <- etlutils::removeTableHeader(drug_disease_org, c("SMPC_NAME", "SMPC_VERSION", "ATC_DISPLAY"))
loinc_mapping <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx")$`Sheet 1`
primary_loincs_from_mapping <- unique(loinc_mapping$LOINC_PRIMARY)

# behalte alle Zeilen aus drug_disease_org, deren LOINC_PRIMARY_PROXY dem primary_loincs_from_mapping mit dem Index 1 entspricht
mapping_loinc_rows_from_drug_disease <- unique(drug_disease_org[LOINC_PRIMARY_PROXY == primary_loincs_from_mapping[4], ]$LOINC_CUTOFF_REFERENCE)

# behalte aus drug_disease_org nur die beiden Spalten LOINC_PRIMARY_PROXY und LOINC_CUTOFF_REFERENCE
drug_disease_org_sub <- unique(drug_disease_org[grepl("^(<|>)", LOINC_CUTOFF_REFERENCE), c("ATC_PRIMARY", "LOINC_PRIMARY_PROXY", "LOINC_CUTOFF_REFERENCE")])


cutoffs <- unique(drug_disease_org$LOINC_CUTOFF_ABSOLUTE)


# Definiere die Spalten
other_cols <- c("ATC_SYSTEMIC_SY",
                "ATC_DERMATIC_D",
                "ATC_OPHTHALMOLOGIC_OP",
                "ATC_INHALATIVE_I",
                "ATC_OTHER_OT")

# Zeilenweise prüfen
drug_disease_org[
  ,
  match_flag := apply(.SD, 1, function(row_vals) {
    primary <- row_vals[["ATC_PRIMARY"]]   # der Code aus dieser Zeile
    others  <- row_vals[other_cols]        # die Strings aus den anderen Spalten
    any(sapply(others, function(val) {
      if (is.na(val) || val == "") return(FALSE)
      codes <- unlist(strsplit(val, "\\s+"))
      primary %in% codes
    }))
  }),
  .SDcols = c("ATC_PRIMARY", other_cols)
]

# Ergebnis 1: Zeilennummern
matching_idx <- which(drug_disease_org$match_flag)

# Ergebnis 2: extrahierte Tabelle
matching_rows <- drug_disease_org[matching_idx]

# Optional: Flag-Spalte wieder löschen
drug_disease_org[, match_flag := NULL]


# Alle Codes aus den "anderen" Spalten extrahieren
all_other_codes <- unique(unlist(
  strsplit(
    paste(na.omit(unlist(drug_disease_org[, ..other_cols])), collapse = " "),
    "\\s+"
  )
))

# Finde Zeilen, deren ATC_PRIMARY auch in den "anderen" Codes vorkommt
matching_idx <- which(drug_disease_org$ATC_PRIMARY %in% all_other_codes)

# Ergebnis 1: Zeilennummern
matching_idx

# Ergebnis 2: gefilterte Tabelle
matching_rows <- drug_disease_org[matching_idx]


etlutils::writeExcelFile(matching_rows, "~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_primary_ATC_in_secondary_ATC_2.xlsx", TRUE)








##############################################################################################
# LOINC Mapping
##############################################################################################


drug_disease <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_content/Drug_Disease_MRP_Table_processed.xlsx")$`Sheet 1`
mapping <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx")$`Sheet 1`

# mapping names = "LOINC", "LOINC_PRIMARY", "COMPARABILITY_TO_LOINC_PRIMARY", "GERMAN_NAME_LOINC_PRIMARY", "UNIT", "CONVERSION_FACTOR", "CONVERSION_UNIT"

mapping_conversion_cols <- unique(mapping[, c("LOINC_PRIMARY", "UNIT", "CONVERSION_FACTOR", "CONVERSION_UNIT")])
# Keep only rows where CONVERSION_FACTOR can be converted to a number
mapping_non_conversion_cols <- mapping_conversion_cols[
  is.na(suppressWarnings(as.numeric(CONVERSION_FACTOR)))
]
drug_disease_without_conversion <- drug_disease[LOINC_PRIMARY_PROXY %in% mapping_non_conversion_cols$LOINC_PRIMARY]
drug_disease_without_conversion[, ATC_FOR_CALCULATION := NULL]
drug_disease_without_conversion <- unique(drug_disease_without_conversion)
drug_disease_without_conversion <- drug_disease_without_conversion[!is.na(LOINC_CUTOFF_ABSOLUTE)]
unique(drug_disease_without_conversion$LOINC_PRIMARY_PROXY)


mapping_loinc <- mapping$LOINC
mapping_loinc_primary <- mapping$LOINC_PRIMARY
mapping_loinc_primary_unique <- unique(mapping$LOINC_PRIMARY)
mapping_loinc_secondary <- setdiff(mapping_loinc, mapping_loinc_primary_unique)

drug_disease_loinc_primary <- unique(drug_disease$LOINC_PRIMARY_PROXY)
drug_disease_loinc_primary <- drug_disease_loinc_primary[!is.na(drug_disease_loinc_primary)]

missing_mapping_loinc <- setdiff(drug_disease_loinc_primary, mapping_loinc_primary_unique)
unused_mapping_loinc <- setdiff(mapping_loinc_primary_unique, drug_disease_loinc_primary)

mapping_loinc_secondary_in_drug_disease_loinc <- intersect(mapping_loinc_secondary, drug_disease_loinc_primary)

#Lass aus der Tabelle drug_disease nur die Spalten übrig c("LOINC_PRIMARY_PROXY", "LOINC_UNIT", "LOINC_CUTOFF_ABSOLUTE")
drug_disease_atc_and_loinc_with_value_and_unit <- unique(drug_disease[, c("ATC_PRIMARY", "LOINC_PRIMARY_PROXY", "LOINC_UNIT", "LOINC_CUTOFF_ABSOLUTE")])
drug_disease_atc_and_loinc_with_value_and_unit <- drug_disease_atc_and_loinc_with_value_and_unit[!is.na(LOINC_PRIMARY_PROXY), ]
drug_disease_atc_and_loinc_with_value_and_unit <- drug_disease_atc_and_loinc_with_value_and_unit[!is.na(LOINC_UNIT) | !is.na(LOINC_CUTOFF_ABSOLUTE), ]

# Sortiere die Tabelle nach der Spalte "LOINC_PRIMARY_PROXY"
drug_disease_atc_and_loinc_with_value_and_unit <- drug_disease_atc_and_loinc_with_value_and_unit[order(LOINC_PRIMARY_PROXY), ]


etlutils::writeExcelFile(drug_disease_atc_and_loinc_with_value_and_unit, "~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_content/Drug_Disease_ATC_and_Loinc_with_value_and_unit.xlsx", TRUE)
