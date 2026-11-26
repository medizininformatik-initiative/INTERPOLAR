# Use model titles, retaining TOP's English-title execution order.
def title($language): [.titles[]? | select(.lang == $language) | .text | select(length > 0)][0];
[.[] | select(.entityType == "composite_phenotype" and .dataType == "boolean")]
| sort_by(title("en") // .titles[0].text)
| .[]
| [
    $model,
    .id,
    (title("de") // title("en") // .titles[0].text // .id | gsub("[\t\r\n]"; " "))
  ]
| @tsv
