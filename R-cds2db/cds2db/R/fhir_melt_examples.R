library(fhircrackr)
library(data.table)

bundle <- xml2::read_xml(
  '<Bundle xmlns="http://hl7.org/fhir">
  <entry>
    <fullUrl value="Encounter/Polar-WP1.1-01156-E-1"/>
    <resource>
      <Encounter xmlns="http://hl7.org/fhir">
        <id value="ID1"/>
        <id value="ID2"/>
        <url value="url1"/>
        <diagnosis>
          <condition>
            <reference value="Ref1a"/>
          </condition>
          <condition>
            <reference value="Ref1b"/>
          </condition>
          <use>
            <coding>
              <system value="sys1a"/>
              <system value="sys1b"/>
              <code value="CM"/>
              <display value="Comor"/>
            </coding>
          </use>
        </diagnosis>
        <diagnosis>
          <condition>
            <reference value="Ref2"/>
          </condition>
          <use>
            <coding>
              <system value="sys2"/>
              <code value="CC"/>
              <display value="Chief"/>
            </coding>
          </use>
        </diagnosis>
      </Encounter>
    </resource>
    <request>
      <method value="PUT"/>
      <url value="Encounter/Polar-WP1.1-01156-E-1"/>
    </request>
  </entry>
</Bundle>'
)

cols <- c(
  "id",
  "url",
  "diagnosis/condition/reference",
  "diagnosis/use/coding/system",
  "diagnosis/use/coding/code",
  "diagnosis/use/coding/display"
)

brackets <- c("[", "]")
sep = "|"
bundle <- fhircrackr::fhir_bundle_xml(bundle)
example_bundles6 <- fhircrackr::fhir_bundle_list(list(bundle))
resource <- "Encounter"
fhir_table_description <- fhircrackr::fhir_table_description(resource = resource,
                                                             brackets = brackets,
                                                             sep = sep, cols = cols
)


all_fhir_column_names <- fhir_table_description@cols@names
column_sep <- "."

cracked_data <- fhircrackr::fhir_crack(example_bundles6, fhir_table_description, data.table = TRUE)

melted_data <- cracked_data

# Determine the prefixes for each column
prefixes <- sapply(all_fhir_column_names, function(column_name) {
  # melt only columns with type character
  if (is.character(melted_data[[column_name]])) {
    # Extract the prefix until the first period for each column
    prefix <- unlist(strsplit(column_name, paste0("\\", column_sep)))[1]
    if (length(prefix) == 1) {
      return(prefix)  # Return the prefix if it's length is 1
    }
  }
  return(NA)  # Return NA if the prefix is not found (will be ignored/removed later)
})
unique_prefixes <- na.omit(unique(prefixes))  # Get unique prefixes



# melte für alle einstufigen Präfixe
columns_with_prefix <- grep(paste0("^", unique_prefixes[1], "$|^", unique_prefixes[1], "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data1 <- fhircrackr::fhir_melt(melted_data, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle einstufig Präfixe
columns_with_prefix <- grep(paste0("^", unique_prefixes[2], "$|^", unique_prefixes[2], "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data2 <- fhircrackr::fhir_melt(melted_data1, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle einstufige Präfixe
columns_with_prefix <- grep(paste0("^", unique_prefixes[3], "$|^", unique_prefixes[3], "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data3 <- fhircrackr::fhir_melt(melted_data2, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle zweistufige Präfixe
prefix <- "diagnosis.condition"
columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data4 <- fhircrackr::fhir_melt(melted_data3, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle zweistufige Präfixe
prefix <- "diagnosis.use"
columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data5 <- fhircrackr::fhir_melt(melted_data4, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle dreistufige Präfixe
prefix <- "diagnosis.condition.reference"
columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data6 <- fhircrackr::fhir_melt(melted_data5, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle dreistufige Präfixe
prefix <- "diagnosis.use.coding"
columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data7 <- fhircrackr::fhir_melt(melted_data6, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle dreistufige Präfixe
prefix <- "diagnosis.use.coding.system"
columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data8 <- fhircrackr::fhir_melt(melted_data7, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle dreistufige Präfixe
prefix <- "diagnosis.use.coding.code"
columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data9 <- fhircrackr::fhir_melt(melted_data8, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
# melte für alle dreistufige Präfixe
prefix <- "diagnosis.use.coding.display"
columns_with_prefix <- grep(paste0("^", prefix, "$|^", prefix, "\\", column_sep), all_fhir_column_names, value = TRUE)
melted_data10 <- fhircrackr::fhir_melt(melted_data9, columns = columns_with_prefix, brackets = brackets, sep = sep, all_columns = TRUE)
