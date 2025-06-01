<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "--- idx_<%TABLE_NAME%>_<%COLUMN_NAME%> - create btree index on \bid\b --------------------"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "    IF EXISTS ( -- target column"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "        SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = '<%COLUMN_NAME%>'"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "    ) THEN"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "        IF EXISTS ( -- INDEX available"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63)"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "        ) THEN -- check current status"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "            IF EXISTS ( -- INDEX nicht auf akuellen Stand"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63)"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "		    AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>)'"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "		DROP INDEX CONCURRENTLY IF EXISTS <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_<%COLUMN_NAME%>;"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "   	        CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "            END IF; -- check current status"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "	ELSE -- (easy) Create new"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "	    CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "        END IF; -- INDEX available"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "\bid\b" "    END IF; -- target column"%>

<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "--- idx_<%TABLE_NAME%>_<%COLUMN_NAME%> - create btree index on ^meta/--------------------"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "    IF EXISTS ( -- target column"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "        SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = '<%COLUMN_NAME%>'"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "    ) THEN"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63)"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "        ) THEN -- check current status"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "            IF EXISTS ( -- INDEX nicht auf akuellen Stand"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_<%COLUMN_NAME%>',1,63)"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "		    AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>)'"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "		DROP INDEX CONCURRENTLY IF EXISTS <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_<%COLUMN_NAME%>;"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "   	        CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "            END IF; -- check current status"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "	ELSE -- (easy) Create new"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "	    CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_<%COLUMN_NAME%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%COLUMN_NAME%>);"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "        END IF; -- INDEX available"%>
<%IF TABLE_DESCRIPTION:COLUMN_DESCRIPTION "^meta/" "    END IF; -- target column"%>
