<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "--- idx_<%TABLE_NAME%>_<%COLUMN_NAME%> - create btree index on \bid\b --------------------
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = '<%COLUMN_NAME%>'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63)
        AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
        ALTER INDEX <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_<%COLUMN_NAME%> RENAME TO del_<%TABLE_NAME%>_<%COLUMN_NAME%>;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_<%TABLE_NAME%>_<%COLUMN_NAME%>;
        CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);
    END IF; -- INDEX available
END IF; -- target column
"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "--- idx_<%TABLE_NAME%>_<%COLUMN_NAME%> - create btree index on ^meta/--------------------
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = '<%COLUMN_NAME%>'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63)
        AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
        ALTER INDEX <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_<%COLUMN_NAME%> RENAME TO del_<%TABLE_NAME%>_<%COLUMN_NAME%>;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_<%TABLE_NAME%>_<%COLUMN_NAME%>;
        CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);
    END IF; -- INDEX available
END IF; -- target column
"%>

