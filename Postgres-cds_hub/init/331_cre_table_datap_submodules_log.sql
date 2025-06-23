-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-06-20 10:25:58
-- Rights definition file size        : 14274 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2025-06-20 10:28:54
-- TABLE_DESCRIPTION:  ./R-dataprocessor/submodules/Dataprocessor_Submodules_Table_Description.xlsx[table_description]
-- SCRIPTNAME:  331_cre_table_datap_submodules_log.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db_log_user
-- OWNER_SCHEMA:  db_log
-- TAGS:  INT_ID
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  db_log_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  332_db_submodules_dp_in_to_db_log.sql
-- COPY_FUNC_TEMPLATE:  template_copy_function.sql
-- COPY_FUNC_NAME:  copy_submodules_dp_in_to_db_log
-- SCHEMA_2:  db2dataprocessor_in
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "db_log" --
-----------------------------------------------------

-- Table "dp_mrp_calculations" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.dp_mrp_calculations (
  dp_mrp_calculations_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations'
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (enc_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'enc_id'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD enc_id varchar;   -- FHIR ID of the associated institution contact (varchar)
        END IF; -- column (enc_id)

        IF NOT EXISTS ( -- column not exists (mrp_calculation_type)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'mrp_calculation_type'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD mrp_calculation_type varchar;   -- Type of MRP (name of the submodule which has calculated the MRP e.g. “Drug_Disease”, “Drug_Drug”, “Drug_DrugGoup”, “Drug_Kidney”) (varchar)
        END IF; -- column (mrp_calculation_type)

        IF NOT EXISTS ( -- column not exists (meda_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'meda_id'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD meda_id varchar;   -- Redcap ID of the medication_analysis_fe (empty if no MedAna exists for this Encounter) (varchar)
        END IF; -- column (meda_id)

        IF NOT EXISTS ( -- column not exists (ret_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'ret_id'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD ret_id varchar;   -- optional – Redcap ID of the generated retrolective_mrpbewertung_fe (varchar)
        END IF; -- column (ret_id)

        IF NOT EXISTS ( -- column not exists (mrp_proxy_type)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'mrp_proxy_type'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD mrp_proxy_type varchar;   -- optional – ICD, ATC, OPS, LOINC (varchar)
        END IF; -- column (mrp_proxy_type)

        IF NOT EXISTS ( -- column not exists (mrp_proxy_code)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'mrp_proxy_code'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD mrp_proxy_code varchar;   -- optional – Code of the proxy (varchar)
        END IF; -- column (mrp_proxy_code)

        IF NOT EXISTS ( -- column not exists (input_file_processed_content_hash)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'input_file_processed_content_hash'
        ) THEN
            ALTER TABLE db_log.dp_mrp_calculations ADD input_file_processed_content_hash varchar;   -- Processed content hash from input_data_files_processed_content of the MRP list (varchar)
        END IF; -- column (input_file_processed_content_hash)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'hash_index_col'
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(enc_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_calculation_type), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_proxy_type), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_proxy_code), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(input_file_processed_content_hash), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.dp_mrp_calculations DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.dp_mrp_calculations ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(enc_id), '#NULL#') || '|||' || -- hash from: FHIR ID of the associated institution contact (enc_id)
          COALESCE(db.to_char_immutable(mrp_calculation_type), '#NULL#') || '|||' || -- hash from: Type of MRP (name of the submodule which has calculated the MRP e.g. “Drug_Disease”, “Drug_Drug”, “Drug_DrugGoup”, “Drug_Kidney”) (mrp_calculation_type)
          COALESCE(db.to_char_immutable(meda_id), '#NULL#') || '|||' || -- hash from: Redcap ID of the medication_analysis_fe (empty if no MedAna exists for this Encounter) (meda_id)
          COALESCE(db.to_char_immutable(ret_id), '#NULL#') || '|||' || -- hash from: optional – Redcap ID of the generated retrolective_mrpbewertung_fe (ret_id)
          COALESCE(db.to_char_immutable(mrp_proxy_type), '#NULL#') || '|||' || -- hash from: optional – ICD, ATC, OPS, LOINC (mrp_proxy_type)
          COALESCE(db.to_char_immutable(mrp_proxy_code), '#NULL#') || '|||' || -- hash from: optional – Code of the proxy (mrp_proxy_code)
          COALESCE(db.to_char_immutable(input_file_processed_content_hash), '#NULL#') || '|||' || -- hash from: Processed content hash from input_data_files_processed_content of the MRP list (input_file_processed_content_hash)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'hash_index_col'
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.dp_mrp_calculations ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(enc_id), '#NULL#') || '|||' || -- hash from: FHIR ID of the associated institution contact (enc_id)
          COALESCE(db.to_char_immutable(mrp_calculation_type), '#NULL#') || '|||' || -- hash from: Type of MRP (name of the submodule which has calculated the MRP e.g. “Drug_Disease”, “Drug_Drug”, “Drug_DrugGoup”, “Drug_Kidney”) (mrp_calculation_type)
          COALESCE(db.to_char_immutable(meda_id), '#NULL#') || '|||' || -- hash from: Redcap ID of the medication_analysis_fe (empty if no MedAna exists for this Encounter) (meda_id)
          COALESCE(db.to_char_immutable(ret_id), '#NULL#') || '|||' || -- hash from: optional – Redcap ID of the generated retrolective_mrpbewertung_fe (ret_id)
          COALESCE(db.to_char_immutable(mrp_proxy_type), '#NULL#') || '|||' || -- hash from: optional – ICD, ATC, OPS, LOINC (mrp_proxy_type)
          COALESCE(db.to_char_immutable(mrp_proxy_code), '#NULL#') || '|||' || -- hash from: optional – Code of the proxy (mrp_proxy_code)
          COALESCE(db.to_char_immutable(input_file_processed_content_hash), '#NULL#') || '|||' || -- hash from: Processed content hash from input_data_files_processed_content of the MRP list (input_file_processed_content_hash)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;

------------------------------------------------------
-- SQL Role / Trigger in Schema "db_log" --
------------------------------------------------------


-- Table "dp_mrp_calculations" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.dp_mrp_calculations TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.dp_mrp_calculations TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.dp_mrp_calculations TO db_user; -- Additional authorizations for testing

------------------------------------------------------
-- Comments on Tables in Schema "db_log" --
------------------------------------------------------

-- Output off
\o /dev/null

COMMENT ON COLUMN db_log.dp_mrp_calculations.dp_mrp_calculations_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.dp_mrp_calculations.enc_id IS 'FHIR ID of the associated institution contact (varchar)';
COMMENT ON COLUMN db_log.dp_mrp_calculations.mrp_calculation_type IS 'Type of MRP (name of the submodule which has calculated the MRP e.g. “Drug_Disease”, “Drug_Drug”, “Drug_DrugGoup”, “Drug_Kidney”) (varchar)';
COMMENT ON COLUMN db_log.dp_mrp_calculations.meda_id IS 'Redcap ID of the medication_analysis_fe (empty if no MedAna exists for this Encounter) (varchar)';
COMMENT ON COLUMN db_log.dp_mrp_calculations.ret_id IS 'optional – Redcap ID of the generated retrolective_mrpbewertung_fe (varchar)';
COMMENT ON COLUMN db_log.dp_mrp_calculations.mrp_proxy_type IS 'optional – ICD, ATC, OPS, LOINC (varchar)';
COMMENT ON COLUMN db_log.dp_mrp_calculations.mrp_proxy_code IS 'optional – Code of the proxy (varchar)';
COMMENT ON COLUMN db_log.dp_mrp_calculations.input_file_processed_content_hash IS 'Processed content hash from input_data_files_processed_content of the MRP list (varchar)';
COMMENT ON COLUMN db_log.dp_mrp_calculations.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.dp_mrp_calculations.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.dp_mrp_calculations.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.dp_mrp_calculations.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.dp_mrp_calculations.last_processing_nr IS 'Last processing number of the data record';

-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "db_log" --
------------------------------------------------------
DO
$$
BEGIN
------------------------------------------------------------------------------------------------

------------------------- Index for db_log - dp_mrp_calculations ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'dp_mrp_calculations_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_dp_mrp_calculations_id',1,63) AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations' AND substr(indexname,1,63)=substr('idx_dp_mrp_calculations_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_dp_mrp_calculations_id ON db_log.dp_mrp_calculations USING btree (dp_mrp_calculations_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_dp_mrp_calculations_id RENAME TO del_idx_dp_mrp_calculations_id;
		DROP INDEX IF EXISTS db_log.del_idx_dp_mrp_calculations_id;
   	        CREATE INDEX idx_dp_mrp_calculations_id ON db_log.dp_mrp_calculations USING btree (dp_mrp_calculations_id DESC);
            END IF; -- check current status
	ELSE -- (easy) Create new
	    CREATE INDEX idx_dp_mrp_calculations_id ON db_log.dp_mrp_calculations USING btree (dp_mrp_calculations_id DESC);
        END IF; -- INDEX available
    END IF; -- target column

-- Index idx_db_log_dp_mrp_calculations_input_dt for Table "dp_mrp_calculations" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_dp_mrp_calculations_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations' AND substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_dp_mrp_calculations_input_dt ON db_log.dp_mrp_calculations USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_dp_mrp_calculations_input_dt RENAME TO del_db_log_dp_mrp_calculations_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_dp_mrp_calculations_i_dt;
	    CREATE INDEX idx_db_log_dp_mrp_calculations_input_dt ON db_log.dp_mrp_calculations USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_dp_mrp_calculations_input_dt ON db_log.dp_mrp_calculations USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_dp_mrp_calculations_input_pnr for Table "dp_mrp_calculations" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations' AND substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_dp_mrp_calculations_input_pnr ON db_log.dp_mrp_calculations USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_dp_mrp_calculations_input_pnr RENAME TO del_db_log_dp_mrp_calculations_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_dp_mrp_calculations_i_pnr;
	    CREATE INDEX idx_db_log_dp_mrp_calculations_input_pnr ON db_log.dp_mrp_calculations USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_dp_mrp_calculations_input_pnr ON db_log.dp_mrp_calculations USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_dp_mrp_calculations_last_dt for Table "dp_mrp_calculations" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations' AND substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_dp_mrp_calculations_last_dt ON db_log.dp_mrp_calculations USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_dp_mrp_calculations_last_dt RENAME TO del_db_log_dp_mrp_calculations_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_dp_mrp_calculations_l_dt;
	    CREATE INDEX idx_db_log_dp_mrp_calculations_last_dt ON db_log.dp_mrp_calculations USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_dp_mrp_calculations_last_dt ON db_log.dp_mrp_calculations USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_dp_mrp_calculations_last_pnr for Table "dp_mrp_calculations" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations' AND substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_dp_mrp_calculations_last_pnr ON db_log.dp_mrp_calculations USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_dp_mrp_calculations_last_pnr RENAME TO del_db_log_dp_mrp_calculations_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_dp_mrp_calculations_l_pnr;
	    CREATE INDEX idx_db_log_dp_mrp_calculations_last_pnr ON db_log.dp_mrp_calculations USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_dp_mrp_calculations_last_pnr ON db_log.dp_mrp_calculations USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_dp_mrp_calculations_hash for Table "dp_mrp_calculations" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'dp_mrp_calculations' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_hash',1,63) AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'dp_mrp_calculations' AND substr(indexname,1,63)=substr('idx_db_log_dp_mrp_calculations_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_dp_mrp_calculations_input_dt ON db_log.dp_mrp_calculations USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_dp_mrp_calculations_hash RENAME TO del_db_log_dp_mrp_calculations_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_dp_mrp_calculations_hash;
	    CREATE INDEX idx_db_log_dp_mrp_calculations_hash ON db_log.dp_mrp_calculations USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_dp_mrp_calculations_hash ON db_log.dp_mrp_calculations USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for dp_mrp_calculations ----------------------------------------------------


------------------------------------------------------------------------------------------------
END
$$;

