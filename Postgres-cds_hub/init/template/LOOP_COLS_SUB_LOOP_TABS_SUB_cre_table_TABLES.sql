        IF NOT EXISTS ( -- column not exists (<%COLUMN_NAME%>)
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = '<%COLUMN_NAME%>'
        ) THEN
<%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD <%COLUMN_NAME%> VARCHAR;   -- <%COLUMN_DESCRIPTION%> (VARCHAR)"%>
<%IF NOT RIGHTS_DEFINITION:TAGS "\bRAW\b" "            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD <%COLUMN_NAME%> <%COLUMN_TYPE%>;   -- <%COLUMN_DESCRIPTION%> (<%COLUMN_TYPE%>)"%>
        END IF; -- column (<%COLUMN_NAME%>)