# Use model titles, retaining TOP's English-title execution order.
def title($language): [.titles[]? | select(.lang == $language) | .text | select(length > 0)][0];
[.[] | select(.entityType == "composite_phenotype" and .dataType == "boolean")]
| sort_by(title("en") // .titles[0].text)
| .[]
| [
    $model,
    .id,
    (title("de") // title("en") // .titles[0].text // .id | gsub("[\t\r\n]"; " ")),
    # These boolean helper criteria were reviewed in the pinned TOP models.
    # Recheck this classification when updating image.txt; it is not a title heuristic.
    (if ($model == "delirium" and .id == "5f66498f-afb1-4d7d-b00f-ba5a933d8cda")
        or ($model == "delirium" and .id == "ce5297ae-2f40-4849-8cb3-24b2dd1064ab")
        or ($model == "fall_injuries" and .id == "83f23c3f-062a-45f2-aab4-f5429ef670ca")
     then "Zwischenkriterium"
     elif $model == "encounters" and .id == "d84be769-3f95-48be-925a-78b8df679856"
     then "Fallzählung" else "Algorithmus" end)
  ]
| @tsv
