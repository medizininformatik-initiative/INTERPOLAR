<%IF NOT TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "COALESCE(db.to_char_immutable(<%COLUMN_NAME%>), ''#NULL#'') || ''|||'' ||"%>
