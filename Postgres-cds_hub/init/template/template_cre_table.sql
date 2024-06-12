-----------------------------------------------------
-- Create SQL Tables in Schema "<%OWNER_SCHEMA%>" --
-----------------------------------------------------

<%CREATE_TABLE_STATEMENTS%>
------------------------------------------------------
-- SQL Role / Trigger in Schema "<%OWNER_SCHEMA%>" --
------------------------------------------------------

<%GRANT_STATEMENTS%>
------------------------------------------------------
-- Comments on Tables in Schema "<%OWNER_SCHEMA%>" --
------------------------------------------------------
-- Output off
\o /dev/null

<%COMMENT_STATEMENTS%>

-- Output on
\o
