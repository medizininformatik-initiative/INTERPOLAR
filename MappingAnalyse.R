##############################################################################################
# Drug-Disease Checking
##############################################################################################

drug_disease_org <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_300925.xlsx")$`Drug-Disease_final`
drug_disease_org <- etlutils::removeTableHeader(drug_disease_org, c("SMPC_NAME", "SMPC_VERSION", "ATC_DISPLAY"))
loinc_mapping <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx")$`Sheet 1`
primary_loincs_from_mapping <- unique(loinc_mapping$LOINC_PRIMARY)

# behalte alle Zeilen aus drug_disease_org, deren LOINC_PRIMARY_PROXY dem primary_loincs_from_mapping mit dem Index 1 entspricht
mapping_loinc_rows_from_drug_disease <- unique(drug_disease_org[LOINC_PRIMARY_PROXY == primary_loincs_from_mapping[4], ]$LOINC_CUTOFF_REFERENCE)

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


##########################################################################################
# Überprüfung nach doppelten Zeilen über den Spalten ATC_PRIMARY und LOINC_PRIMARY_PROXY #
##########################################################################################
drug_disease_LOINC <- drug_disease_org[
  !is.na(ATC_PRIMARY) & !is.na(LOINC_PRIMARY_PROXY)
]

drug_disease_LOINC_dup <- drug_disease_LOINC[
  , .N, by = .(ATC_PRIMARY, LOINC_PRIMARY_PROXY)
][N > 1][drug_disease_LOINC, on = .(ATC_PRIMARY, LOINC_PRIMARY_PROXY)]

drug_disease_LOINC_dup <- drug_disease_LOINC_dup[
  !is.na(N)
]

drug_disease_ATC_and_LOINC_duplicates <- drug_disease_LOINC_dup[
  !is.na(ATC_PRIMARY) & !is.na(LOINC_PRIMARY_PROXY)
]

setorder(drug_disease_ATC_and_LOINC_duplicates, ATC_PRIMARY, LOINC_PRIMARY_PROXY)

etlutils::writeExcelFile(drug_disease_ATC_and_LOINC_duplicates, "~/Projekte/INTERPOLAR/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_content/Drug_Disease_by_ATC_PRIMARY_and_LOINC_PRIMARY_PROXY.xlsx", TRUE)

##########################################################################################
# Überprüfung nach doppelten Zeilen über den Spalten ATC_PRIMARY und ICD_PROXY_ATC #
##########################################################################################
drug_disease_ATC <- drug_disease_org[
  !is.na(ATC_PRIMARY) & !is.na(ICD_PROXY_ATC)
]

drug_disease_ATC_dup <- drug_disease_ATC[
  , .N, by = .(ATC_PRIMARY, ICD_PROXY_ATC)
][N > 1][drug_disease_ATC, on = .(ATC_PRIMARY, ICD_PROXY_ATC)]

drug_disease_ATC_dup <- drug_disease_ATC_dup[
  !is.na(N)
]

drug_disease_ATC_and_ATC_duplicates <- drug_disease_ATC_dup[
  !is.na(ATC_PRIMARY) & !is.na(ICD_PROXY_ATC)
]

setorder(drug_disease_ATC_and_ATC_duplicates, ATC_PRIMARY, ICD_PROXY_ATC)

etlutils::writeExcelFile(drug_disease_ATC_and_ATC_duplicates, "~/Projekte/INTERPOLAR/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_content/Drug_Disease_by_ATC_PRIMARY_and_ICD_PROXY_ATC.xlsx", TRUE)

##########################################################################################
# Überprüfung nach doppelten Zeilen über den Spalten ATC_PRIMARY und ICD_PROXY_OPS #
##########################################################################################
drug_disease_OPS <- drug_disease_org[
  !is.na(ATC_PRIMARY) & !is.na(ICD_PROXY_OPS)
]

drug_disease_OPS_dup <- drug_disease_OPS[
  , .N, by = .(ATC_PRIMARY, ICD_PROXY_OPS)
][N > 1][drug_disease_OPS, on = .(ATC_PRIMARY, ICD_PROXY_OPS)]

drug_disease_OPS_dup <- drug_disease_OPS_dup[
  !is.na(N)
]

drug_disease_ATC_and_OPS_duplicates <- drug_disease_OPS_dup[
  !is.na(ATC_PRIMARY) & !is.na(ICD_PROXY_OPS)
]

setorder(drug_disease_ATC_and_OPS_duplicates, ATC_PRIMARY, ICD_PROXY_OPS)

etlutils::writeExcelFile(drug_disease_ATC_and_OPS_duplicates, "~/Projekte/INTERPOLAR/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_content/Drug_Disease_by_ATC_PRIMARY_and_ICD_PROXY_OPS.xlsx", TRUE)

##################################################################################################################################
# Überprüfung nach doppelten Zeilen über den Spalten ATC_PRIMARY und ICD_FULL_LIST, die unterschiedliche ICD_VALIDITY_DAYS haben #
##################################################################################################################################

drug_disease_ICD <- drug_disease_org[
  !is.na(ATC_PRIMARY) & !is.na(ICD)
]

drug_disease_ICD <- unique(drug_disease_ICD)

drug_disease_ICD_dup <- drug_disease_ICD[
  , .N, by = .(ATC_PRIMARY, ICD)
][N > 1][drug_disease_ICD, on = .(ATC_PRIMARY, ICD)]

drug_disease_ICD_dup <- drug_disease_ICD_dup[
  !is.na(N)
]

drug_disease_ICD_dup <- drug_disease_ICD_dup[
  !is.na(ATC_PRIMARY) & !is.na(ICD)
]

drug_disease_ATC_and_ICD_duplicates <- drug_disease_ICD_dup[
  , if (length(unique(ICD_VALIDITY_DAYS[!is.na(ICD_VALIDITY_DAYS)])) > 1) .SD,
  by = .(ATC_PRIMARY, ICD)
]

setorder(drug_disease_ATC_and_ICD_duplicates, ATC_PRIMARY, ICD)

etlutils::writeExcelFile(drug_disease_ATC_and_ICD_duplicates, "~/Projekte/INTERPOLAR/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_content/Drug_Disease_with_different_ICD_VALIDITY_DAYS_by_ATC_PRIMARY_and_ICD.xlsx", TRUE)


##############################################################################################
# Drug-Drug & Drug-DrugGroup
##############################################################################################

drug_drug_processed <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Drug/Drug_Drug_content/Drug_Drug_MRP_Table_processed.xlsx")$`Sheet 1`

# Create a copy of the table to avoid modifying the original
drug_drug_pairs <- data.table::copy(drug_drug_processed)

# Ensure consistent order of pairs by sorting the two columns row-wise
drug_drug_pairs[, `:=`(
  atc_min = pmin(ATC_FOR_CALCULATION, ATC2_FOR_CALCULATION),
  atc_max = pmax(ATC_FOR_CALCULATION, ATC2_FOR_CALCULATION)
)]


# Sort table by two columns in ascending order
drug_drug_pairs <- drug_drug_pairs[order(ATC_FOR_CALCULATION, ATC2_FOR_CALCULATION)]

# Count occurrences of each unique ordered pair
pair_counts <- drug_drug_pairs[, .N, by = .(atc_min, atc_max)][N > 1]

etlutils::writeExcelFile(pair_counts, "~/Projekte/Interpolar/drug_drug_multiple_pairs.xlsx", TRUE)

##############################################################################################
# LOINC Mapping
##############################################################################################


drug_disease <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/MRP_Drug_Disease/Drug_Disease_content/Drug_Disease_MRP_Table_processed.xlsx")$`Sheet 1`
mapping <- etlutils::readExcelFileAsTableList("~/Projekte/Interpolar/Input-Repo/INTERPOLAR-WP7/LOINC_Mapping/LOINC_Mapping_content/LOINC_Mapping_Table_processed.xlsx")$`Sheet 1`

# mapping names = "LOINC", "LOINC_PRIMARY", "COMPARABILITY_TO_LOINC_PRIMARY", "GERMAN_NAME_LOINC_PRIMARY", "UNIT", "CONVERSION_FACTOR", "CONVERSION_UNIT"

mapping_conversion_cols <- unique(mapping[, c("UNIT", "CONVERSION_FACTOR", "CONVERSION_UNIT")])
mapping_conversion_cols <- mapping_conversion_cols[
  grepl("^-?\\d+(\\.\\d+)?([eE][-+]?\\d+)?$", CONVERSION_FACTOR)
]

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
