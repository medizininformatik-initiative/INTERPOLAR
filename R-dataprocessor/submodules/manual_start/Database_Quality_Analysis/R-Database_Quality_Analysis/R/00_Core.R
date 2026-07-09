DATABASE_QUALITY_ANALYSIS_COUNT_COLUMNS <- c(
  resource_id = "count per resource_id",
  pid = "count per PID",
  case_id = "count per Fall-Id"
)

DATABASE_QUALITY_ANALYSIS_ENCOUNTER_COUNT_COLUMNS <- c(
  encounter_einrichtungskontakt = "count per Einrichtungskontakt",
  encounter_einrichtungskontakt_imp = "count per Einrichtungskontakt class IMP",
  encounter_einrichtungskontakt_ss = "count per Einrichtungskontakt class SS",
  encounter_einrichtungskontakt_amb = "count per Einrichtungskontakt class AMB",
  encounter_einrichtungskontakt_other = "count per Einrichtungskontakt class Andere",
  encounter_abteilungskontakt = "count per Abteilungskontakt",
  encounter_abteilungskontakt_imp = "count per Abteilungskontakt class IMP",
  encounter_abteilungskontakt_ss = "count per Abteilungskontakt class SS",
  encounter_abteilungskontakt_amb = "count per Abteilungskontakt class AMB",
  encounter_abteilungskontakt_other = "count per Abteilungskontakt class Andere",
  encounter_versorgungsstellenkontakt = "count per Versorgungsstellenkontakt",
  encounter_versorgungsstellenkontakt_imp = "count per Versorgungsstellenkontakt class IMP",
  encounter_versorgungsstellenkontakt_ss = "count per Versorgungsstellenkontakt class SS",
  encounter_versorgungsstellenkontakt_amb = "count per Versorgungsstellenkontakt class AMB",
  encounter_versorgungsstellenkontakt_other = "count per Versorgungsstellenkontakt class Andere"
)

DATABASE_QUALITY_ANALYSIS_ENCOUNTER_TYPE_SYSTEM <- "http://fhir.de/CodeSystem/Kontaktebene"
DATABASE_QUALITY_ANALYSIS_ENCOUNTER_CLASS_SYSTEM <- "http://terminology.hl7.org/CodeSystem/v3-ActCode"

DATABASE_QUALITY_ANALYSIS_ENCOUNTER_TYPE_GROUPINGS <- c(
  encounter_einrichtungskontakt = "einrichtungskontakt",
  encounter_einrichtungskontakt_imp = "einrichtungskontakt",
  encounter_einrichtungskontakt_ss = "einrichtungskontakt",
  encounter_einrichtungskontakt_amb = "einrichtungskontakt",
  encounter_einrichtungskontakt_other = "einrichtungskontakt",
  encounter_abteilungskontakt = "abteilungskontakt",
  encounter_abteilungskontakt_imp = "abteilungskontakt",
  encounter_abteilungskontakt_ss = "abteilungskontakt",
  encounter_abteilungskontakt_amb = "abteilungskontakt",
  encounter_abteilungskontakt_other = "abteilungskontakt",
  encounter_versorgungsstellenkontakt = "versorgungsstellenkontakt",
  encounter_versorgungsstellenkontakt_imp = "versorgungsstellenkontakt",
  encounter_versorgungsstellenkontakt_ss = "versorgungsstellenkontakt",
  encounter_versorgungsstellenkontakt_amb = "versorgungsstellenkontakt",
  encounter_versorgungsstellenkontakt_other = "versorgungsstellenkontakt"
)

DATABASE_QUALITY_ANALYSIS_ENCOUNTER_CLASS_GROUPINGS <- c(
  encounter_einrichtungskontakt = NA_character_,
  encounter_einrichtungskontakt_imp = "IMP",
  encounter_einrichtungskontakt_ss = "SS",
  encounter_einrichtungskontakt_amb = "AMB",
  encounter_einrichtungskontakt_other = "OTHER",
  encounter_abteilungskontakt = NA_character_,
  encounter_abteilungskontakt_imp = "IMP",
  encounter_abteilungskontakt_ss = "SS",
  encounter_abteilungskontakt_amb = "AMB",
  encounter_abteilungskontakt_other = "OTHER",
  encounter_versorgungsstellenkontakt = NA_character_,
  encounter_versorgungsstellenkontakt_imp = "IMP",
  encounter_versorgungsstellenkontakt_ss = "SS",
  encounter_versorgungsstellenkontakt_amb = "AMB",
  encounter_versorgungsstellenkontakt_other = "OTHER"
)

DATABASE_QUALITY_ANALYSIS_CHECKED_VALUE <- "Checked"

DATABASE_QUALITY_ANALYSIS_FRONTEND_CHECKBOX_GROUPS <- list(
  mrpdokumentation_validierung_fe = list(
    mrp_pigrund = paste0("mrp_pigrund___", 1:27),
    mrp_massn_am = paste0("mrp_massn_am___", 1:10),
    mrp_massn_orga = paste0("mrp_massn_orga___", 1:8)
  ),
  retrolektive_mrpbewertung_fe = list(
    ret_gewiss_trigger1_falsch = paste0("ret_gewiss_trigger1_falsch___", 1:4),
    ret_gewiss_datengrundl1_1 = paste0("ret_gewiss_datengrundl1_1___", 1:4),
    ret_gewiss_datengrundl1_2 = paste0("ret_gewiss_datengrundl1_2___", 1:4),
    ret_gewiss_grund_abl_klin1_neg = "ret_gewiss_grund_abl_klin1_neg___1",
    ret_massn_am1 = paste0("ret_massn_am1___", 1:10),
    ret_massn_orga1 = paste0("ret_massn_orga1___", 1:8),
    ret_2ndbewertung = "ret_2ndbewertung___1",
    ret_gewiss_trigger2_falsch = paste0("ret_gewiss_trigger2_falsch___", 1:4),
    ret_gewiss_datengrundl2_1 = paste0("ret_gewiss_datengrundl2_1___", 1:4),
    ret_gewiss_datengrundl2_2 = paste0("ret_gewiss_datengrundl2_2___", 1:4),
    ret_gewiss_grund_abl_klin2_neg = "ret_gewiss_grund_abl_klin2_neg___1",
    ret_massn_am2 = paste0("ret_massn_am2___", 1:10),
    ret_massn_orga2 = paste0("ret_massn_orga2___", 1:8)
  )
)

DATABASE_QUALITY_ANALYSIS_VALUE_DATETIME_COLUMNS <- c(
  first_import = "first value import datetime",
  last_import = "last value import datetime",
  first_meta_last_updated = "first value meta last updated",
  last_meta_last_updated = "last value meta last updated"
)

DATABASE_QUALITY_ANALYSIS_GROUPING_ROLE_COLUMN <- "USED_AS_GROUPING_FOR"

logProgress <- function(...) {
  cat("[Database Quality Analysis] ", ..., "\n", sep = "")
}

formatDuration <- function(start_time, end_time = Sys.time()) {
  paste0(round(as.numeric(difftime(end_time, start_time, units = "secs")), 2), "s")
}

formatCountLabel <- function(count, singular, plural = paste0(singular, "s")) {
  paste(count, if (identical(as.integer(count), 1L)) singular else plural)
}
