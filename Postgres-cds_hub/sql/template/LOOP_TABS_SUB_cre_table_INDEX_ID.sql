------------------------- Index for <%OWNER_SCHEMA%> - <%TABLE_NAME%> ---------------------------------
<%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = '<%TABLE_NAME%>_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_id',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_id',1,63)
          AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%TABLE_NAME%>_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
        ALTER INDEX <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_id RENAME TO del_idx_<%TABLE_NAME%>_id;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_idx_<%TABLE_NAME%>_id;
               CREATE INDEX idx_<%TABLE_NAME%>_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%TABLE_NAME%>_id DESC);
            END IF; -- check current status
      ELSE -- (easy) Create new
        CREATE INDEX idx_<%TABLE_NAME%>_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%TABLE_NAME%>_id DESC);
        END IF; -- INDEX available
    END IF; -- target column"%>
<%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "    -- Primary key of the corresponding raw table
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = '<%TABLE_NAME%>_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_raw_id',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_raw_id',1,63)
         AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_raw_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%TABLE_NAME%>_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
        ALTER INDEX <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_id RENAME TO del_idx_<%TABLE_NAME%>_id;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_idx_<%TABLE_NAME%>_id;
               CREATE INDEX idx_<%TABLE_NAME%>_raw_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%TABLE_NAME%>_id DESC);
            END IF; -- check current status
     ELSE -- (easy) Create new
        CREATE INDEX idx_<%TABLE_NAME%>_raw_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (<%TABLE_NAME%>_id DESC);
        END IF; -- INDEX available
    END IF; -- target column"%>
<%IF RIGHTS_DEFINITION:TAGS "\bRAW\b" "      -- Primary key of the corresponding raw table
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'raw_already_processed'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_already_processed',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_already_processed',1,63)
                  AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_already_processed ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (raw_already_processed DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
                ALTER INDEX <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_already_processed RENAME TO del_idx_<%TABLE_NAME%>_already_processed;
                DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_idx_<%TABLE_NAME%>_already_processed;
                   CREATE INDEX idx_<%TABLE_NAME%>_already_processed ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (raw_already_processed DESC);
              END IF; -- check current status
       ELSE -- (easy) Create new
                 CREATE INDEX idx_<%TABLE_NAME%>_already_processed ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (raw_already_processed DESC);
          END IF; -- INDEX available
      END IF; -- target column"%>
<%IF RIGHTS_DEFINITION:TAGS "\bFE_RC_ID\b" "      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_record_id',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_record_id',1,63)
                  AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_record_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
                ALTER INDEX <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_record_id RENAME TO del_idx_<%TABLE_NAME%>_record_id;
                DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_idx_<%TABLE_NAME%>_record_id;
                   CREATE INDEX idx_<%TABLE_NAME%>_record_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (record_id DESC);
              END IF; -- check current status
       ELSE -- (easy) Create new
                 CREATE INDEX idx_<%TABLE_NAME%>_record_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_rc_re_id',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%TABLE_NAME%>_rc_re_id',1,63)
                  AND indexdef != 'CREATE INDEX idx_<%TABLE_NAME%>_rc_re_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
                ALTER INDEX <%OWNER_SCHEMA%>.idx_<%TABLE_NAME%>_rc_re_id RENAME TO del_idx_<%TABLE_NAME%>_rc_re_id;
                DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_idx_<%TABLE_NAME%>_rc_re_id;
                   CREATE INDEX idx_<%TABLE_NAME%>_rc_re_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
       ELSE -- (easy) Create new
                 CREATE INDEX idx_<%TABLE_NAME%>_rc_re_id ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column"%>

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt',1,63)
        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX <%OWNER_SCHEMA%>.idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt RENAME TO del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_i_dt;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_i_dt;
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr',1,63)
        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX <%OWNER_SCHEMA%>.idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr RENAME TO del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_i_pnr;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_i_pnr;
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt',1,63)  AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt',1,63)
        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX <%OWNER_SCHEMA%>.idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt RENAME TO del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_l_dt;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_l_dt;
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr',1,63)
        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX <%OWNER_SCHEMA%>.idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr RENAME TO del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_l_pnr;
            DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_l_pnr;
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_last_pnr ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash for Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash',1,63) AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = '<%OWNER_SCHEMA%>' AND tablename = '<%TABLE_NAME%>' AND substr(indexname,1,63)=substr('idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash',1,63)
        AND indexdef != 'CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_input_dt ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX <%OWNER_SCHEMA%>.idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash RENAME TO del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash;
        DROP INDEX IF EXISTS <%OWNER_SCHEMA%>.del_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash;
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_<%OWNER_SCHEMA%>_<%TABLE_NAME%>_hash ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for <%TABLE_NAME%> ----------------------------------------------------
<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES_INDEX%>
