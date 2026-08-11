getTestFallvignetteMapping <- function() {
  mapping_path <- getFallvignetteMappingPath(
    "WP8MRP_Liste_Daten_Mapping20260722.xlsx"
  )
  loadFallvignetteMapping(mapping_path)
}
