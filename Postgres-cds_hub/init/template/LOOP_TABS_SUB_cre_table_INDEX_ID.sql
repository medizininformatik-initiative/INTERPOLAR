------------------------- Index for <%OWNER_SCHEMA%> - <%TABLE_NAME%> ---------------------------------
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "    -- Primary key of the entity - already filled in this schema - History via timestamp"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "    IF EXISTS ( -- target column"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "        SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = '<%TABLE_NAME%>_id'"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "    ) THEN"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "        IF EXISTS ( -- INDEX available"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_id',1,63)"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "        ) THEN -- check current status"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "            IF EXISTS ( -- INDEX nicht auf akuellen Stand"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_id',1,63)"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "		  AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (idx_<%TABLE_NAME%>_id DESC)'"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "		DROP INDEX CONCURRENTLY IF EXISTS <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_id;"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "   	        CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (idx_<%TABLE_NAME%>_id DESC);"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "            END IF; -- check current status"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "	ELSE -- (easy) Create new"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "	    CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (idx_<%TABLE_NAME%>_id DESC);"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "        END IF; -- INDEX available"%>
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "    END IF; -- target column"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "    -- Primary key of the corresponding raw table"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "    IF EXISTS ( -- target column"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "        SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'idx_<%TABLE_NAME%>_raw_id'"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "    ) THEN"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "        IF EXISTS ( -- INDEX available"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_raw_id',1,63)"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "        ) THEN -- check current status"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "            IF EXISTS ( -- INDEX nicht auf akuellen Stand"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_raw_id',1,63)"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "		 AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_raw_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (idx_<%TABLE_NAME%>_raw_id DESC)'"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "		DROP INDEX CONCURRENTLY IF EXISTS <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_raw_id;"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "   	        CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_raw_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (idx_<%TABLE_NAME%>_raw_id DESC);"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "            END IF; -- check current status"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "	ELSE -- (easy) Create new"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "	    CREATE INDEX CONCURRENTLY idx_<%TABLE_NAME%>_raw_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (idx_<%TABLE_NAME%>_raw_id DESC);"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "        END IF; -- INDEX available"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "    END IF; -- target column"%>

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt',1,63)
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt',1,63)
	        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		DROP INDEX CONCURRENTLY IF EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt;
	        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr',1,63)
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr',1,63)
	        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		DROP INDEX CONCURRENTLY IF EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr;
	        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt',1,63)
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt',1,63)
	        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		DROP INDEX CONCURRENTLY IF EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt;
	        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr',1,63)
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr',1,63)
	        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		DROP INDEX CONCURRENTLY IF EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr;
	        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash',1,63)
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash',1,63)
	        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		DROP INDEX CONCURRENTLY IF EXISTS idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash;
	        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX CONCURRENTLY idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table ----------------------------------------------------
<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES_INDEX%>

-- index by definition table ----------------------------------------------------
