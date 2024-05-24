# library(fhircrackr)
# library(data.table)
#
# bundle <- xml2::read_xml(
#   '<Bundle xmlns="http://hl7.org/fhir">
#   <entry>
#     <fullUrl value="Encounter/Polar-WP1.1-01156-E-1"/>
#     <resource>
#       <Encounter xmlns="http://hl7.org/fhir">
#         <id value="ID1"/>
#         <id value="ID2"/>
#         <url value="url1"/>
#         <diagnosis>
#           <condition>
#             <reference value="Ref1a"/>
#           </condition>
#           <condition>
#             <reference value="Ref1b"/>
#           </condition>
#           <use>
#             <coding>
#               <system value="sys1a"/>
#               <system value="sys1b"/>
#               <code value="CM"/>
#               <display value="Comor"/>
#             </coding>
#           </use>
#         </diagnosis>
#         <diagnosis>
#           <condition>
#             <reference value="Ref2"/>
#           </condition>
#           <use>
#             <coding>
#               <system value="sys2"/>
#               <code value="CC"/>
#               <display value="Chief"/>
#             </coding>
#           </use>
#         </diagnosis>
#       </Encounter>
#     </resource>
#     <request>
#       <method value="PUT"/>
#       <url value="Encounter/Polar-WP1.1-01156-E-1"/>
#     </request>
#   </entry>
# </Bundle>'
# )
#
# cols <- c(
#   "id",
#   "url",
#   "diagnosis/condition/reference",
#   "diagnosis/use/coding/system",
#   "diagnosis/use/coding/code",
#   "diagnosis/use/coding/display"
# )
#
# brackets <- c("[", "]")
# sep = "|"
# bundle <- fhircrackr::fhir_bundle_xml(bundle)
# example_bundles6 <- fhircrackr::fhir_bundle_list(list(bundle))
# resource <- "Encounter"
# fhir_table_description <- fhircrackr::fhir_table_description(resource = resource,
#                                                              brackets = brackets,
#                                                              sep = sep, cols = cols
# )
#
# all_fhir_column_names <- fhir_table_description@cols@names
# column_sep <- "."
#
# cracked_data <- fhircrackr::fhir_crack(example_bundles6, fhir_table_description, data.table = TRUE)
#
# melted_data <- cracked_data
#
# # Determine the prefixes for each column
# prefixes <- sapply(all_fhir_column_names, function(column_name) {
#   # melt only columns with type character
#   if (is.character(melted_data[[column_name]])) {
#     # Extract the prefix until the first period for each column
#     prefix <- unlist(strsplit(column_name, paste0("\\", column_sep)))[1]
#     if (length(prefix) == 1) {
#       return(prefix)  # Return the prefix if it's length is 1
#     }
#   }
#   return(NA)  # Return NA if the prefix is not found (will be ignored/removed later)
# })
# unique_prefixes <- na.omit(unique(prefixes))  # Get unique prefixes
#
#
#
# # melte für alle einstufigen Präfixe
# columns_with_prefix <- grep(paste0("^", unique_prefixes[1], "$|^", unique_prefixes[1], "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data1 <- fhircrackr::fhir_melt(melted_data, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle einstufig Präfixe
# columns_with_prefix <- grep(paste0("^", unique_prefixes[2], "$|^", unique_prefixes[2], "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data2 <- fhircrackr::fhir_melt(melted_data1, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle einstufige Präfixe
# columns_with_prefix <- grep(paste0("^", unique_prefixes[3], "$|^", unique_prefixes[3], "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data3 <- fhircrackr::fhir_melt(melted_data2, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle zweistufige Präfixe
# prefix <- "diagnosis.condition"
# columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data4 <- fhircrackr::fhir_melt(melted_data3, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle zweistufige Präfixe
# prefix <- "diagnosis.use"
# columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data5 <- fhircrackr::fhir_melt(melted_data4, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle dreistufige Präfixe
# prefix <- "diagnosis.condition.reference"
# columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data6 <- fhircrackr::fhir_melt(melted_data5, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle dreistufige Präfixe
# prefix <- "diagnosis.use.coding"
# columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data7 <- fhircrackr::fhir_melt(melted_data6, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle dreistufige Präfixe
# prefix <- "diagnosis.use.coding.system"
# columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data8 <- fhircrackr::fhir_melt(melted_data7, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle dreistufige Präfixe
# prefix <- "diagnosis.use.coding.code"
# columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data9 <- fhircrackr::fhir_melt(melted_data8, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# # melte für alle dreistufige Präfixe
# prefix <- "diagnosis.use.coding.display"
# columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
# melted_data10 <- fhircrackr::fhir_melt(melted_data9, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
#
#
#
#
# fhirMeltFull <- function(cracked_data, column_name_separator, fhir_table_description) {
#
#   getEscaped <- function(string) {
#     if (nchar(string) == 0) {
#       return(string)
#     } else if (nchar(string) == 1) {
#       return(paste0("\\", string))
#     } else {
#       chars <- strsplit(string, "")[[1]]
#       escaped_string <- paste0("\\", chars, collapse = "")
#       return(escaped_string)
#     }
#   }
#
#   getColumns <- function(prefix) {
#     grep(paste0("^", prefix, "$|^", prefix, getEscaped(column_name_separator)), column_names, value = TRUE)
#   }
#
#   melted_data <- cracked_data
#
#   column_names <- names(cracked_data)
#
#   brackets <- fhir_table_description@brackets
#   sep <- fhir_table_description@sep
#
#   getUniquePrefixes <- function(step) {
#     # Split each column name by the separator
#     split_names <- strsplit(column_names, getEscaped(column_name_separator))
#
#     # Initialize a vector to store the prefixes
#     prefixes <- c()
#
#     for (name_parts in split_names) {
#       # Check if the number of parts is sufficient for the given step
#       if (length(name_parts) >= step) {
#         # Create the prefix by joining the first `step` parts with the separator
#         prefix <- paste(name_parts[1:step], collapse = column_name_separator)
#         prefixes <- c(prefixes, prefix)
#       }
#     }
#     # Get unique prefixes
#     prefixes <- unique(prefixes)
#     return(prefixes)
#   }
#
#   step <- 1
#   repeat {
#     prefixes <- getUniquePrefixes(step)
#     if (!rlang::is_empty(prefixes)) {
#       for (prefix in prefixes) {
#         columns <- getColumns(prefix)
#         melted_data <- fhircrackr::fhir_melt(melted_data, columns, brackets, sep, all_columns = TRUE)
#       }
#     } else {
#       break
#     }
#     step <- step + 1
#   }
#
#   return(melted_data)
# }
#
# melted_by_meltAll <- meltAll(cracked_data, ".", fhir_table_description)
#
# identical(melted_by_meltAll, melted_data10)
# # Schreibe die Funktion
# #
# # getUniquePrefixes <- function(colum_names, colum_names_separator, step) {
# #
# #   #TODO: liefere alle verschiedenen Präfixe für den jeweilgen step
# # }
# #
# # die folgendes macht:
# #
# # column_names ist ein Vektor von String, die z.B. die Form c("aaa/bbb/ccc/d", "x/y", "oo/ppp/qqqq", "oo/ppp/r")
# # haben.
# # colum_names_separator ist der String, der die einzelnen Teile in diesen Strings trennt, also im Beispiel "/"
# # step gibt an, wieviele colum_names_separator in den Rückgabe Strings vorhanden sind (immer einer weniger als step)
# #
# # Die Funktion würde im Beispiel in step 1 c("aaa", "x", "oo") zurückgeben
# # Die Funktion würde im Beispiel in step 2 c("aaa/bbb", "x/y", "oo/ppp") zurückgeben
# # Die Funktion würde im Beispiel in step 3 c("aaa/bbb/ccc", "oo/ppp/qqqq", "oo/ppp/r") zurückgeben
# # Die Funktion würde im Beispiel in step 4 c("aaa/bbb/ccc/d") zurückgeben
# # Die Funktion würde im Beispiel in step > 4 c() zurückgeben
#
#
# # Beispielaufrufe
# column_names <- c("aaa/bbb/ccc/d", "x/y", "oo/ppp/qqqq", "oo/ppp/r")
#
# # Step 1
# print(getUniquePrefixes(column_names, "/", 1)) # c("aaa", "x", "oo")
#
# # Step 2
# print(getUniquePrefixes(column_names, "/", 2)) # c("aaa/bbb", "x/y", "oo/ppp")
#
# # Step 3
# print(getUniquePrefixes(column_names, "/", 3)) # c("aaa/bbb/ccc", "oo/ppp/qqqq", "oo/ppp/r")
#
# # Step 4
# print(getUniquePrefixes(column_names, "/", 4)) # c("aaa/bbb/ccc/d")
#
# # Step > 4
# print(getUniquePrefixes(column_names, "/", 5)) # c()
#


#
#
#
# # viel langsamer, aber richtiges Ergebnis
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   # Split each column name by the separator
#   split_names <- strsplit(column_names, getEscaped(column_name_separator))
#
#   # Use sapply to efficiently create the prefixes
#   prefixes <- sapply(split_names, function(name_parts) {
#     if (length(name_parts) >= step) {
#       return(paste(name_parts[1:step], collapse = column_name_separator))
#     } else {
#       return(NA)
#     }
#   })
#
#   # Remove NA values and get unique prefixes
#   prefixes <- unique(na.omit(prefixes))
#
#   return(prefixes)
# }
#
# # richtiges Ergebnis, ganz minimal langsamer
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   # Split each column name by the separator
#   split_names <- strsplit(column_names, column_name_separator)
#
#   # Use vapply for efficiency
#   prefixes <- vapply(split_names, function(name_parts) {
#     if (length(name_parts) >= step) {
#       return(paste(name_parts[1:step], collapse = column_name_separator))
#     } else {
#       return(NA_character_)
#     }
#   }, character(1))
#
#   # Remove NA values and get unique prefixes
#   prefixes <- unique(prefixes[!is.na(prefixes)])
#
#   return(prefixes)
# }
#
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   # Split each column name by the separator
#   split_names <- strsplit(column_names, column_name_separator)
#
#   # Initialize a list to store the prefixes
#   prefixes <- vector("character", length(column_names))
#   prefix_index <- 1
#
#   for (name_parts in split_names) {
#     # Check if the number of parts is sufficient for the given step
#     if (length(name_parts) >= step) {
#       # Create the prefix by joining the first `step` parts with the separator
#       prefixes[prefix_index] <- paste(name_parts[1:step], collapse = column_name_separator)
#       prefix_index <- prefix_index + 1
#     }
#   }
# }
#
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   # Split each column name by the separator
#   split_names <- strsplit(column_names, column_name_separator)
#
#   # Initialize a list to store the prefixes
#   prefixes <- vector("character", length(column_names))
#   prefix_index <- 1
#
#   for (name_parts in split_names) {
#     # Check if the number of parts is sufficient for the given step
#     if (length(name_parts) >= step) {
#       # Create the prefix by joining the first `step` parts with the separator
#       prefixes[prefix_index] <- paste(name_parts[1:step], collapse = column_name_separator)
#       prefix_index <- prefix_index + 1
#     }
#   }
#
#   # Remove unused elements and get unique prefixes
#   prefixes <- unique(prefixes[1:(prefix_index - 1)])
#
#   return(prefixes)
# }
#
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   # Split each column name by the separator
#   split_names <- strsplit(column_names, column_name_separator)
#
#   # Initialize a list to store the prefixes
#   n <- length(column_names)
#   prefixes <- vector("character", n)
#   prefix_index <- 1
#
#   for (name_parts in split_names) {
#     # Check if the number of parts is sufficient for the given step
#     if (length(name_parts) >= step) {
#       # Create the prefix by joining the first `step` parts with the separator
#       prefixes[prefix_index] <- paste(name_parts[1:step], collapse = column_name_separator)
#       prefix_index <- prefix_index + 1
#     }
#   }
#
#   # Remove unused elements and get unique prefixes
#   prefixes <- unique(prefixes[1:(prefix_index - 1)])
#
#   return(prefixes)
# }
# library(data.table)
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   # Convert column names to a data.table
#   dt <- data.table(column_names = column_names)
#
#   # Split the column names by the separator and create a list of prefixes
#   dt[, prefixes := lapply(strsplit(column_names, column_name_separator), function(parts) {
#     if (length(parts) >= step) {
#       paste(parts[1:step], collapse = column_name_separator)
#     } else {
#       NA_character_
#     }
#   })]
#
#   # Get unique prefixes and remove NA values
#   unique_prefixes <- unique(na.omit(dt$prefixes))
#
#   return(unique_prefixes)
# }
#
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   split_names <- strsplit(column_names, column_name_separator)
#
#   n <- length(column_names)
#   prefixes <- vector("character", n)
#   prefix_index <- 1
#
#   for (i in seq_len(n)) {
#     name_parts <- split_names[[i]]
#     if (length(name_parts) >= step) {
#       prefixes[prefix_index] <- paste(name_parts[1:step], collapse = column_name_separator)
#       prefix_index <- prefix_index + 1
#     }
#   }
#
#   prefixes <- unique(prefixes[1:(prefix_index - 1)])
#
#   return(prefixes)
# }
#
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   prefixes <- vector("character", length(column_names))
#   prefix_index <- 1
#
#   for (name in column_names) {
#     sep_count <- 0
#     end_pos <- nchar(name)
#
#     for (i in seq_len(nchar(name))) {
#       if (substring(name, i, i) == column_name_separator) {
#         sep_count <- sep_count + 1
#         if (sep_count == step) {
#           end_pos <- i - 1
#           break
#         }
#       }
#     }
#
#     if (sep_count < step) {
#       prefixes[prefix_index] <- NA
#     } else {
#       prefixes[prefix_index] <- substring(name, 1, end_pos)
#     }
#
#     prefix_index <- prefix_index + 1
#   }
#
#   # Remove NA values and get unique prefixes
#   prefixes <- unique(na.omit(prefixes))
#
#   return(prefixes)
# }
#
# getUniquePrefixes <- function(column_names, column_name_separator, step) {
#   prefixes <- vector("character", length(column_names))
#   prefix_index <- 1
#
#   for (name in column_names) {
#     sep_count <- 0
#     end_pos <- nchar(name)
#
#     for (i in seq_len(nchar(name))) {
#       if (substring(name, i, i) == column_name_separator) {
#         sep_count <- sep_count + 1
#         if (sep_count == step) {
#           end_pos <- i
#           break
#         }
#       }
#     }
#
#     if (sep_count < step) {
#       prefixes[prefix_index] <- name
#     } else {
#       prefixes[prefix_index] <- substring(name, 1, end_pos - 1)
#     }
#
#     prefix_index <- prefix_index + 1
#   }
#
#   # Remove NA values and get unique prefixes
#   prefixes <- unique(na.omit(prefixes))
#
#   return(prefixes)
# }
#
# # Beispielaufrufe
# column_names <- c("aaa/bbb/ccc/d", "x/y", "oo/ppp/qqqq", "oo/ppp/r")
#
# # Step 1
# print(getUniquePrefixes(column_names, "/", 1)) # c("aaa", "x", "oo")
#
# # Step 2
# print(getUniquePrefixes(column_names, "/", 2)) # c("aaa/bbb", "x/y", "oo/ppp")
#
# # Step 3
# print(getUniquePrefixes(column_names, "/", 3)) # c("aaa/bbb/ccc", "oo/ppp/qqqq", "oo/ppp/r")
#
# # Step 4
# print(getUniquePrefixes(column_names, "/", 4)) # c("aaa/bbb/ccc/d")
#
# # Step 5
# print(getUniquePrefixes(column_names, "/", 5)) # c() == NULL
#
# # Installation und Laden des microbenchmark Pakets
# if (!requireNamespace("microbenchmark", quietly = TRUE)) {
#   install.packages("microbenchmark")
# }
# library(microbenchmark)
#
# getEscaped <- function(string) {
#   if (nchar(string) == 0) {
#     return(string)
#   } else if (nchar(string) == 1) {
#     return(paste0("\\", string))
#   } else {
#     chars <- strsplit(string, "")[[1]]
#     escaped_string <- paste0("\\", chars, collapse = "")
#     return(escaped_string)
#   }
# }
#
#
# # Originale Funktion für den Vergleich
# getUniquePrefixes_original <- function(column_names, column_name_separator, step) {
#   split_names <- strsplit(column_names, getEscaped(column_name_separator))
#   prefixes <- c()
#   for (name_parts in split_names) {
#     if (length(name_parts) >= step) {
#       prefix <- paste(name_parts[1:step], collapse = column_name_separator)
#       prefixes <- c(prefixes, prefix)
#     }
#   }
#   prefixes <- unique(prefixes)
#   return(prefixes)
# }
#
# # Benchmark beider Funktionen
# result <- microbenchmark(
#   original = getUniquePrefixes_original(column_names, "/", 3),
#   optimized = getUniquePrefixes(column_names, "/", 3),
#   times = 1000
# )
#
#
# print(result)
#
#
# # Step > 4
# print(getUniquePrefixes(column_names, "/", 5)) # c()
