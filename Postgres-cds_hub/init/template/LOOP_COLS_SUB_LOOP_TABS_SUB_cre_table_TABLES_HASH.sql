<%IF NOT TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "COALESCE(db.to_char_immutable(<%COLUMN_NAME%>), '#NULL#') || '|||' || -- hash from: <%COLUMN_DESCRIPTION%> (<%COLUMN_NAME%>)"%>
