#' Adds the 'cci' column to the passed table.
#'
#' @details
#' If the 'cci' column does not already exist, it will be added.
#' 'cci' includes the Charlson Comorbidity Index as a factor,
#' which is the sum of all relevant risk scores of all diagnoses in the
#' same case. If the 'cci' column already exists, it will be overwritten.
#'
#' @param table a data table
#' @param caseIDColumnName name of the column with the case (or patient) ID in the table
#' @param icdCodeColumnName name of the column with the diagnosis code in the table
#' @param ageColumnName name of the column with the patient age in the table. If NA, then the age score will not
#' be added (default is NA).
#' @param cciColumnName name of the new generated cci column name (default is 'cci')
#'
#' @examples
#' library(data.table)
#' # Combinations of NA values in diagnoses but with valid age
#' table <- data.table(
#'   caseID    = c(      1,       2,       2,       3,  3,       3,       3,       3,       3,
#'                       4,       4,       4,      4),
#'   diagnoses = c(     NA,      NA,      NA,      NA, NA, 'C77.1', 'C77.1', 'C77.2', 'X99.9',
#'                 'C77.1', 'C77.1', 'C77.2', 'X99.9'),
#'   age       = c(     90,      90,      90,      90, 90,      90,      90,      90,      90,
#'                      90,      90,      90,      90)
#' )
#' addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
#' addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
#' print(table)
#'
#' # Check if low and high risk scores work fine (Metastatic_solid_tumor overrides
#' # Any_malignancy_including_lymphoma_and_leukemia_except_malignant_neoplasm_of_skin)
#' table <- data.table(
#'   caseID = c(1),
#'   # low risk diagnoses (some repeated) # high risk diagnoses from here (also repeated)
#'   diagnoses = c('C00.1', 'C00.1', 'C01.1', 'C01.1', 'C77.1', 'C77.1', 'C78.1', 'C78.1',
#'                 'C78.1', 'C78.1'),
#'   age = c(90)
#' )
#' addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
#' addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
#' print(table)
#'
#' @export
addCharlsonScore <- function(table, caseIDColumnName, icdCodeColumnName, ageColumnName = NA, cciColumnName = NA) {

  # Convert variable names with '_' for spaces, '__' for commas, and '___' for slashes to a display format.
  varNameToDisplay <- function(var_name) gsub('_', ' ', gsub('__', ', ', gsub('___', '/', var_name)))

  ########################
  ### Define Diagnoses ###
  ########################


  # List of lists where each sublist is named with a string convertible to human-readable
  # format using varNameToDisplay.
  # Each sublist contains a score followed by all relevant ICD diagnosis codes.
  # In some cases, a sublist is composed of two subsublists indicating pairs of diagnoses,
  # where the first diagnosis is overshadowed by the second if both are present in one case.
  codes <- list(

    Myocardial_infarction =
      c(0, 'I21', 'I22', 'I25.2'),

    Congestive_heart_failure =
      c(2, 'I09.9', 'I11.0', 'I13.0', 'I13.2', 'I25.5', 'I42.0', paste0('I42.', 5:9), 'I43', 'I50', 'P29.0'),

    Peripheral_vascular_disease =
      c(0, 'I70', 'I71', 'I73.1', 'I73.8', 'I73.9', 'I77.1', 'I79.0', 'I79.2', 'K55.1', 'K55.8', 'K55.9', 'Z95.8', 'Z95.9'),

    Cerebrovascular_disease =
      c(0, 'G45', 'G46', 'H34.0', paste0('I', 60:69)),

    Dementia =
      c(2, paste0('F0', 0:3), 'F05.1', 'G30', 'G31.1'),

    Chronic_pulmonary_disease =
      c(1, 'I27.8', 'I27.9', paste0('J', c(40:47, 60:67)), 'J68.4', 'J70.1', 'J70.3'),

    Rheumatic_disease =
      c(1, 'M05', 'M06', 'M31.5', paste0('M', 32:34),'M35.1', 'M35.3', 'M36.0'),

    Peptic_ulcer_disease =
      c(0, c(paste0('K', 25:28))),

    Liver_disease = list(

      Mild_liver_disease =
        c(2, 'B18', paste0('K70.', c(0:3, 9)), paste0('K71.', 3:5), 'K71.7', 'K73', 'K74', paste0('K76.', c(0, 2:4)),
          'K76.8', 'K76.9', 'Z94.4'),

      Moderate_or_severe_liver_disease =
        c(4, 'I85.0', 'I85.9', 'I86.4', 'I98.2', 'K70.4', 'K71.1', 'K72.1', 'K72.9', 'K76.5', 'K76.6', 'K76.7')

    ),

    Diabetes = list(

      Diabetes_without_chronic_complication =
        c(0, paste0(paste0('E', 10:14, '.'), rep(c(0, 1, 6, 8, 9), each = 5))),

      Diabetes_with_chronic_complication =
        c(1, paste0(paste0('E', 10:14, '.'), rep(c(2:5, 7), each = 5)))

    ),

    Cancer = list(

      Any_malignancy__including_lymphoma_and_leukemia__except_malignant_neoplasm_of_skin =
        c(2, paste0('C0', 0:9), paste0('C', c(10:26, 30:34, 37:41, 43, 45:58, 60:76, 81:85, 88, 90:97))),

      Metastatic_solid_tumor =
        c(6, paste0('C', 77:80))

    ),

    Hemiplegia_or_paraplegia =
      c(2, 'G04.1', 'G11.4', 'G80.1', 'G80.2', 'G81', 'G82', paste0('G83.', c(0:4, 9))),

    Renal_disease =
      c(1, 'I12.0', 'I13.1', paste0('N03.', 2:7), paste0('N05.', 2:7), 'N18', 'N19', 'N25.0', paste0('Z49.', 0:2),'Z94.0', 'Z99.2'),

    AIDS___HIV =
      c(4, paste0('B', c(20:22, 24)))
  )

  ############################
  ### Print Expanded Codes ###
  ############################

  # Function to print the defined ICD codes list.
  # @param as_R_code If TRUE (default), the list is printed in R syntax; if FALSE, in a more human-readable format.
  printCodes <- function(as_R_code = TRUE) {

    getSubCodeListString <- function(mainCodesList, subCodeList, name, indentation, subCodeListIndex) {
      code <- unlist(subCodeList)
      indentation <- c(rep(' ', times = indentation))
      indentation <- paste0(indentation, collapse =  '')
      paste0(indentation, name, " =\n", indentation, "  c(", code[1], ", '",
             paste0(code[-1], collapse = "', '"), "')",
             ifelse(as_R_code && subCodeListIndex < length(mainCodesList), ",", ""),
             "\n\n")
    }

    formatName <- function(name) ifelse(as_R_code, name, varNameToDisplay(name))

    codes_string <- ifelse(as_R_code, "codes <- list(\n\n", "")
    for (i in 1:length(codes)) {
      codes_string <- paste0(codes_string, lapply(codes[i], function(subCodeList) {
        subListName <- formatName(names(codes[i]))
        if (is.character(subCodeList)) {
          subcodes_string <- getSubCodeListString(codes, subCodeList, subListName, 2, i)
        } else {
          subSubListNames <- names(subCodeList)
          subcodes_string <- paste0("  ", subListName, " = ", ifelse(as_R_code, "list", ""), "(\n\n")
          for (j in 1:length(subCodeList)) {
            subSubCodeList <- subCodeList[j]
            subSubListName <- formatName(subSubListNames[j])
            subcodes_string <- paste0(subcodes_string, getSubCodeListString(subCodeList, subSubCodeList, subSubListName, 4, j))
          }
          closeBracket <- ifelse(as_R_code, "),", ")")
          if (as_R_code) {
            subcodes_string <- paste0(subcodes_string, "  ", closeBracket, "\n\n")
          }
        }
        subcodes_string
      }))
    }
    if (as_R_code) {
      codes_string <- paste0(codes_string, ")")
    }
    message(codes_string)
  }

  #printCodes()
  #printCodes(FALSE)

  #########################
  ### Fill Column 'cci' ###
  #########################


  # Function to calculate the risk score based on age.
  # @param age The age of the patient.
  # @return NA if age is NA, scores based on age ranges otherwise.
  ageScore <- function(age) {
    ifelse(is.na(age), NA, ifelse(age < 50, 0, ifelse(age < 60, 1, ifelse(age < 70, 2, ifelse(age < 80, 3, 4)))))
  }


  # Function to retrieve all rows with specified subcodes from the column with ICD codes.
  # @param subcodes Subcodes to search for, with the first element being the CCI score (removed before searching).
  getRowsWithSubcodes <- function(subcodes) {
    if (length(subcodes) == 1 && is.na(subcodes)) {                 # if the subcodes parameter is NA
      return(integer())                                             # return empty row indices list
    }
    subcodes <- subcodes[-1]                                        # remove the cci score from the sublist
    subcodes <- paste0(subcodes, collapse = '|')                    # generate grep pattern from all codes
    grep(subcodes, table[[icdCodeColumnName]])                      # get all row indices with a matching diagnosis code
  }

  table[, cci := NA_integer_]                                       # add 'cci' column to the given table

  subCodesListIndex <- 1                                            # needed to prevent adding a score from the same list twice

  # Main loop to calculate CCI scores based on diagnosis codes.
  # Processes each diagnosis code or code pair, adjusts scores for overlapping diagnoses within the same case.
  for (codeOrSubCodeList in codes) {
    if (is.character(codeOrSubCodeList)) {                        # if the sublist is a simple character vector
      lowRiskDiagnoses  <- NA                                     # we have no diagnosis ranked with low risk
      highRiskDiagnoses <- unlist(codeOrSubCodeList)              # we only have diagnoses ranked with high risk
      lowRiskCCIScore   <- 0                                      # no low risk diagnosis -> low risk score 0
      highRiskCCIScore  <- as.integer(codeOrSubCodeList[1])       # get the risk score of the diagnoses (always the first element of the sublist)
    } else {                                                      # if the sublist is a list of subsublists (2 diagnoses patterns with different scores and the second one hides the first one)
      lowRiskDiagnoses  <- unlist(codeOrSubCodeList[1])           # get the diagnosis ranked with low risk (first subsublist)
      highRiskDiagnoses <- unlist(codeOrSubCodeList[2])           # get the diagnosis ranked with high risk (second subsublist)
      lowRiskCCIScore   <- as.integer(lowRiskDiagnoses[1])        # get the risk score of the low risk diagnoses (always the first element of the subsublist)
      highRiskCCIScore  <- as.integer(highRiskDiagnoses[1])       # get the risk score of the high risk diagnoses (always the first element of the subsublist)
    }

    rowsWithLowRisk     <- getRowsWithSubcodes(lowRiskDiagnoses)  # get all row indices matching a low risk diagnosis code
    rowsWithHighRisk    <- getRowsWithSubcodes(highRiskDiagnoses) # get all row indices matching a high risk diagnosis code

    # now remove all row indices with low risk if the same case has a diagnosis with low and high risk
    if (length(rowsWithLowRisk) && length(rowsWithHighRisk)) {    # skip this part if there are no low or no high risk diagnoses
      for (lr in length(rowsWithLowRisk):1) {                     # for every row index with a low risk diagnosis (delete always from end to start)
        lowRiskRow <- rowsWithLowRisk[lr]                         # get the single low risk diagnosis row index
        lowRiskRowCaseID <- table[[caseIDColumnName]][lowRiskRow] # get the case ID of the low risk diagnosis
        for (highRiskRow in rowsWithHighRisk) {                   # for every high risk diagnosis rows
          highRiskCaseID <- table[[caseIDColumnName]][highRiskRow] # get the case ID of the high risk diagnosis
          if (lowRiskRowCaseID == highRiskCaseID) {               # if low risk and high risk diagnoses are in the same case
            rowsWithLowRisk <- rowsWithLowRisk[-lr]               # remove low risk diagnosis row index
            break                                                 # continue with next low risk row index
          }
        }
      }
    }

    # set the low risk score as cci value in this row and store the index of the current sublist
    table[rowsWithLowRisk, c("cci", "cciListIndex") := .(lowRiskCCIScore, subCodesListIndex)]
    # Alte Schreibweise, die aber beim Install zu einer Warnung führt. Die neue Schreibweise hier drüber ist nicht getestet!
    # table[rowsWithLowRisk, ':=' (cci = lowRiskCCIScore, cciListIndex = subCodesListIndex)]
    # set the high risk score as cci value in this row and store the index of the current sublist
    table[rowsWithHighRisk, c("cci", "cciListIndex") := .(highRiskCCIScore, subCodesListIndex)]
    # Alte Schreibweise, die aber beim Install zu einer Warnung führt. Die neue Schreibweise hier drüber ist nicht getestet!
    # table[rowsWithHighRisk, ':=' (cci = highRiskCCIScore, cciListIndex = subCodesListIndex)]


    subCodesListIndex <- subCodesListIndex + 1

  }

  # for all rows with a diagnosis but without a cci score (from a high or relevant low risk diagnosis) -> set the cci score to 0
  table[, cci := ifelse(is.na(cci) & !is.na(table[[icdCodeColumnName]]), 0, cci)]

  # if the same case has multiple diagnoses from the same sublist -> set cci
  # to 0 for all diagnoses from the same sublist in this case
  cols <- c(caseIDColumnName, 'cciListIndex')
  duplicateDiagnoses <- which(duplicated(table[, ..cols]))
  table[duplicateDiagnoses, cci := 0]

  # cci should be NA if all diagnoses are NA. The replacing of duplicated values has also replaced duplicated NA
  # values with an cci of 0 -> correct this cases to NA
  table[, cci := ifelse(is.na(table[[icdCodeColumnName]]), NA, cci)]
  table[, cciListIndex := NULL]                                      # the list index column can be removed now

  # add all diagnoses scores in the same case and set the value for every row in this case
  table[, cci := {
    unique_cci <- unique(cci)
    ifelse(length(unique_cci) == 1 && is.na(unique_cci[1]), NA, sum(cci, na.rm = TRUE))
  },
  by = c(caseIDColumnName)]

  if (!is.na(ageColumnName)) {                                      # if the age column name parameter was not NA -> add the age score
    for (r in 1:nrow(table)) {                                      # for every row in the result table
      table[r, cci := cci + ageScore(table[[ageColumnName]][r])]    # increase the cci score by the age score
    }
  }
  if (!is.na(cciColumnName)) {
    setnames(table, 'cci', cciColumnName)
  }
}

########################################
# More Examples for addCharlsonScore() #
########################################

# # Combinations of NA values in diagnoses but with valid age
# table <- data.table(
#   caseID    = c( 1,       2,       2,       3,       3,       3,       3,       3,        3,
#                  4,       4,       4,       4),
#   diagnoses = c(NA,      NA,      NA,      NA,      NA, 'C77.1', 'C77.1', 'C77.2',  'X99.9',
#                 'C77.1', 'C77.1', 'C77.2', 'X99.9'),
#   age       = c(90,      90,      90,      90,      90,      90,      90,      90,       90,
#                 90,      90,      90,      90)
# )
# addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
# addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
# print(table)
#
# # Combinations of NA values in diagnoses but with invalid age
# table <- data.table(
#   caseID    = c( 1,       2,       2,       3,       3,       3,       3,       3,        3,
#                  4,       4,       4,       4),
#   diagnoses = c(NA,      NA,      NA,      NA,      NA, 'C77.1', 'C77.1', 'C77.2',  'X99.9',
#                 'C77.1', 'C77.1', 'C77.2', 'X99.9'),
#   age       = c(NA)
# )
# addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
# addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
# print(table)
#
#
# # Multiple patients with different diagnoses and cases of NA values
# # (only the diagnose 'Y66.0' is not relevant)
# # If age is NA then the CCI without age can be calculated, but with age not -> NA
# table <- data.table(
#   caseID       = c(      1,       1,       1,       1,       1,       1,       1,       1,
#                          2,       2,       2,       2,       3,       4,       5,       6,
#                          7,       8,      8),
#   diagnoses    = c(     NA, 'C77.1', 'C77.1', 'C77.2', 'Z94.4', 'E10.4', 'J47.0', 'Z94.4',
#                    'C77.1', 'E10.5', 'Z94.4', 'K76.7', 'E10.7', 'Y66.0',      NA, 'E10.7',
#                         NA,      NA, 'I85.9'),
#   age          = c(     20,      20,      20,      20,      20,      20,      20,      20,
#                         50,      50,      50,      50,      60,      90,     100,      NA,
#                         NA,      70,     70),
#   other_column = c(     20,      20,      20,      20,      20,      20,      20,      20,
#                         50,      50,      50,      50,      60,      90,     100,      NA,
#                         NA,      70,      70)
# )
# addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
# addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
# print(table)
#
# # Multiple patients with different diagnoses and all cases of NA values
# # (only the diagnose 'Y66.0' is not relevant)
# # If age is NA then the CCI without age can be calculated, but with age not -> NA
# table <- data.table(
#   caseID    = c(      1,       1,       1,       1,       1,       1,       1,       1,
#                       2,       2,       2,       2,       3,       4,       5,       6,
#                       7,       8,       8),
#   diagnoses = c('C77.1', 'C77.1', 'C77.1', 'C77.1', 'Z94.4', 'E10.4', 'J47.0', 'Z94.4',
#                 'C77.1', 'E10.5', 'Z94.4', 'K76.7', 'E10.7', 'Y66.0',      NA, 'E10.7',
#                      NA,      NA, 'I85.9'),
#   age       = c(     20,      20,      20,      20,      20,      20,      20,      20,
#                      50,      50,      50,      50,      60,      90,     100,      NA,
#                      NA,      70,      70),
#   test      = c(     20,      20,      20,      20,      20,      20,      20,      20,
#                      50,      50,      50,      50,      60,      90,     100,      NA,
#                      NA,      70,      70)
# )
# addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
# addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
# print(table)
#
#
# # extract all dignoses from the CCI codes list in one large vector
# all_cci_diagnoses <- as.character(unlist(codes))
# all_cci_diagnoses <- all_cci_diagnoses[nchar(all_cci_diagnoses) > 1] # remove the scores from the list
# all_cci_diagnoses <- rep(all_cci_diagnoses, 2) # all diagnoses are twice in the full list
#
# # 2 patients, first has maximum age (age scrore 4) and second minimum age (age score 0)
# # both patients have all CCI diagnoses and every diagnoses code twice in their only case
# # first patient must have max CCI (= 24) + age score (= 4) -> CCI = 28
# # second patient must have max CCI (= 24) + age score (= 0) -> CCI = 24
# table <-data.table(
#   caseID = c(rep(1, length(all_cci_diagnoses)), rep(2, length(all_cci_diagnoses))),
#   diagnoses = c(all_cci_diagnoses, all_cci_diagnoses),
#   age = c(rep(100, length(all_cci_diagnoses)), rep(20, length(all_cci_diagnoses)))
# )
# addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
# addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
# print(table)
#
# # check if repeating diagnoses from the same list will not adding the same score multiple times
# table <-data.table(
#   caseID = c(1),
#   diagnoses = c('I09.9', 'I11.0', 'I09.9', 'I11.0', 'I09.9', 'I11.0', 'I09.9', 'I11.0', 'I09.9', 'I11.0'),
#   age = c(20)
# )
# addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
# addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
# print(table)
#
# # check if low and high risk scores work fine
# # (Metastatic_solid_tumor hides Any_malignancy__including_lymphoma_and_leukemia__except_malignant_neoplasm_of_skin)
# table <-data.table(
#   caseID = c(1),
#   #             #low risk diagnoses (some repeated) #high risk diagnoses from here (also repeated)
#   diagnoses = c('C00.1', 'C00.1', 'C01.1', 'C01.1', 'C77.1', 'C77.1', 'C78.1', 'C78.1', 'C78.1', 'C78.1'),
#   age = c(90)
# )
# addCharlsonScore(table, 'caseID', 'diagnoses', cciColumnName = 'cci.without.age')
# addCharlsonScore(table, 'caseID', 'diagnoses', 'age')
# print(table)

