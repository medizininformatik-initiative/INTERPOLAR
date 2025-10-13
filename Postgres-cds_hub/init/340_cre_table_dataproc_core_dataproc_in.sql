-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-07-01 13:49:10
-- Rights definition file size        : 16391 Byte
--
-- Create SQL Tables in Schema "db2dataprocessor_in"
-- Create time: 2025-10-06 22:48:50
-- TABLE_DESCRIPTION:  ./R-dataprocessor/dataprocessor/inst/extdata/Dataprocessor_Table_Description.xlsx[table_description]
-- SCRIPTNAME:  340_cre_table_dataproc_core_dataproc_in.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db2dataprocessor_user
-- OWNER_SCHEMA:  db2dataprocessor_in
-- TAGS:  
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- RIGHTS (3):  SELECT
-- GRANT_TARGET_USER:  db2dataprocessor_user
-- GRANT_TARGET_USER (2):  db_user
-- GRANT_TARGET_USER (3):  db_log_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "db2dataprocessor_in" --
-----------------------------------------------------

-- Table "input_data_files" in schema "db2dataprocessor_in"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.input_data_files (
  input_data_files_id int PRIMARY KEY DEFAULT nextval('db.db_seq') -- Primary key of the entity
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (file_name)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'file_name'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD file_name varchar;   -- table file name (varchar)
        END IF; -- column (file_name)

        IF NOT EXISTS ( -- column not exists (content_hash)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'content_hash'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD content_hash varchar;   -- hashed table content (varchar)
        END IF; -- column (content_hash)

        IF NOT EXISTS ( -- column not exists (content)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'content'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD content varchar;   -- table content (varchar)
        END IF; -- column (content)

        IF NOT EXISTS ( -- column not exists (processed_content_hash)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'processed_content_hash'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files ADD processed_content_hash varchar;   -- optional – hashed processed table content (varchar)
        END IF; -- column (processed_content_hash)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(file_name), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(content_hash), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(content), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(processed_content_hash), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db2dataprocessor_in.input_data_files DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db2dataprocessor_in.input_data_files ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(file_name), '#NULL#') || '|||' || -- hash from: table file name (file_name)
          COALESCE(db.to_char_immutable(content_hash), '#NULL#') || '|||' || -- hash from: hashed table content (content_hash)
          COALESCE(db.to_char_immutable(content), '#NULL#') || '|||' || -- hash from: table content (content)
          COALESCE(db.to_char_immutable(processed_content_hash), '#NULL#') || '|||' || -- hash from: optional – hashed processed table content (processed_content_hash)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db2dataprocessor_in.input_data_files ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(file_name), '#NULL#') || '|||' || -- hash from: table file name (file_name)
          COALESCE(db.to_char_immutable(content_hash), '#NULL#') || '|||' || -- hash from: hashed table content (content_hash)
          COALESCE(db.to_char_immutable(content), '#NULL#') || '|||' || -- hash from: table content (content)
          COALESCE(db.to_char_immutable(processed_content_hash), '#NULL#') || '|||' || -- hash from: optional – hashed processed table content (processed_content_hash)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
-- Table "input_data_files_processed_content" in schema "db2dataprocessor_in"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db2dataprocessor_in.input_data_files_processed_content (
  input_data_files_processed_content_id int PRIMARY KEY DEFAULT nextval('db.db_seq') -- Primary key of the entity
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (processed_content_hash)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'processed_content_hash'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD processed_content_hash varchar;   -- hashed processed table content (varchar)
        END IF; -- column (processed_content_hash)

        IF NOT EXISTS ( -- column not exists (processed_content)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'processed_content'
        ) THEN
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD processed_content varchar;   -- processed table content (varchar)
        END IF; -- column (processed_content)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(processed_content_hash), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(processed_content), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(processed_content_hash), '#NULL#') || '|||' || -- hash from: hashed processed table content (processed_content_hash)
          COALESCE(db.to_char_immutable(processed_content), '#NULL#') || '|||' || -- hash from: processed table content (processed_content)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db2dataprocessor_in.input_data_files_processed_content ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(processed_content_hash), '#NULL#') || '|||' || -- hash from: hashed processed table content (processed_content_hash)
          COALESCE(db.to_char_immutable(processed_content), '#NULL#') || '|||' || -- hash from: processed table content (processed_content)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;

------------------------------------------------------
-- SQL Role / Trigger in Schema "db2dataprocessor_in" --
------------------------------------------------------


-- Table "input_data_files" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.input_data_files TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.input_data_files TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.input_data_files TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.input_data_files TO db_log_user; -- Additional authorizations for testing

-- Table "input_data_files_processed_content" in schema "db2dataprocessor_in"
----------------------------------------------------
GRANT TRIGGER ON db2dataprocessor_in.input_data_files_processed_content TO db2dataprocessor_user;
GRANT USAGE ON SCHEMA db2dataprocessor_in TO db2dataprocessor_user;
GRANT USAGE ON db.db_seq TO db2dataprocessor_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.input_data_files_processed_content TO db2dataprocessor_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db2dataprocessor_in.input_data_files_processed_content TO db_user; -- Additional authorizations for testing
GRANT SELECT ON TABLE db2dataprocessor_in.input_data_files_processed_content TO db_log_user; -- Additional authorizations for testing

------------------------------------------------------
-- Comments on Tables in Schema "db2dataprocessor_in" --
------------------------------------------------------

-- Output off
\o /dev/null

DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------

COMMENT ON COLUMN db2dataprocessor_in.input_data_files.input_data_files_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.file_name IS 'table file name (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.content_hash IS 'hashed table content (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.content IS 'table content (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.processed_content_hash IS 'optional – hashed processed table content (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files.last_processing_nr IS 'Last processing number of the data record';
--------------------------------------------------------------------
    END IF; -- do migration
END
$$;
DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
--------------------------------------------------------------------

COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.input_data_files_processed_content_id IS 'Primary key of the entity';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.processed_content_hash IS 'hashed processed table content (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.processed_content IS 'processed table content (varchar)';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db2dataprocessor_in.input_data_files_processed_content.last_processing_nr IS 'Last processing number of the data record';
--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "db2dataprocessor_in" --
------------------------------------------------------
DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
------------------------------------------------------------------------------------------------

------------------------- Index for db2dataprocessor_in - input_data_files ---------------------------------

-- Index idx_db2dataprocessor_in_input_data_files_input_dt for Table "input_data_files" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db2dataprocessor_in_input_data_files_input_dt',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_input_dt ON db2dataprocessor_in.input_data_files USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_input_dt RENAME TO del_db2dataprocessor_in_input_data_files_i_dt;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_i_dt;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_input_dt ON db2dataprocessor_in.input_data_files USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_input_dt ON db2dataprocessor_in.input_data_files USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_input_pnr for Table "input_data_files" in schema "db2dataprocessor_in"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_input_pnr',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_input_pnr ON db2dataprocessor_in.input_data_files USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_input_pnr RENAME TO del_db2dataprocessor_in_input_data_files_i_pnr;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_i_pnr;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_input_pnr ON db2dataprocessor_in.input_data_files USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_input_pnr ON db2dataprocessor_in.input_data_files USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_last_dt for Table "input_data_files" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_last_dt',1,63)  AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_last_dt ON db2dataprocessor_in.input_data_files USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_last_dt RENAME TO del_db2dataprocessor_in_input_data_files_l_dt;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_l_dt;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_last_dt ON db2dataprocessor_in.input_data_files USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_last_dt ON db2dataprocessor_in.input_data_files USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_last_pnr for Table "input_data_files" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_last_pnr',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_last_pnr ON db2dataprocessor_in.input_data_files USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_last_pnr RENAME TO del_db2dataprocessor_in_input_data_files_l_pnr;
            DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_l_pnr;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_last_pnr ON db2dataprocessor_in.input_data_files USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_last_pnr ON db2dataprocessor_in.input_data_files USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_hash for Table "input_data_files" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_hash',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_input_dt ON db2dataprocessor_in.input_data_files USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_hash RENAME TO del_db2dataprocessor_in_input_data_files_hash;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_hash;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_hash ON db2dataprocessor_in.input_data_files USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_hash ON db2dataprocessor_in.input_data_files USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for input_data_files ----------------------------------------------------

------------------------- Index for db2dataprocessor_in - input_data_files_processed_content ---------------------------------

-- Index idx_db2dataprocessor_in_input_data_files_processed_content_input_dt for Table "input_data_files_processed_content" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db2dataprocessor_in_input_data_files_processed_content_input_dt',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_input_dt ON db2dataprocessor_in.input_data_files_processed_content USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_processed_content_input_dt RENAME TO del_db2dataprocessor_in_input_data_files_processed_content_i_dt;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_processed_content_i_dt;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_input_dt ON db2dataprocessor_in.input_data_files_processed_content USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_input_dt ON db2dataprocessor_in.input_data_files_processed_content USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_processed_content_input_pnr for Table "input_data_files_processed_content" in schema "db2dataprocessor_in"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_input_pnr',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_input_pnr ON db2dataprocessor_in.input_data_files_processed_content USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_processed_content_input_pnr RENAME TO del_db2dataprocessor_in_input_data_files_processed_content_i_pnr;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_processed_content_i_pnr;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_input_pnr ON db2dataprocessor_in.input_data_files_processed_content USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_input_pnr ON db2dataprocessor_in.input_data_files_processed_content USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_processed_content_last_dt for Table "input_data_files_processed_content" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_last_dt',1,63)  AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_last_dt ON db2dataprocessor_in.input_data_files_processed_content USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_processed_content_last_dt RENAME TO del_db2dataprocessor_in_input_data_files_processed_content_l_dt;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_processed_content_l_dt;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_last_dt ON db2dataprocessor_in.input_data_files_processed_content USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_last_dt ON db2dataprocessor_in.input_data_files_processed_content USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_processed_content_last_pnr for Table "input_data_files_processed_content" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_last_pnr',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_last_pnr ON db2dataprocessor_in.input_data_files_processed_content USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_processed_content_last_pnr RENAME TO del_db2dataprocessor_in_input_data_files_processed_content_l_pnr;
            DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_processed_content_l_pnr;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_last_pnr ON db2dataprocessor_in.input_data_files_processed_content USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_last_pnr ON db2dataprocessor_in.input_data_files_processed_content USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db2dataprocessor_in_input_data_files_processed_content_hash for Table "input_data_files_processed_content" in schema "db2dataprocessor_in"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db2dataprocessor_in' AND table_name = 'input_data_files_processed_content' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_hash',1,63) AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db2dataprocessor_in' AND tablename = 'input_data_files_processed_content' AND substr(indexname,1,63)=substr('idx_db2dataprocessor_in_input_data_files_processed_content_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_input_dt ON db2dataprocessor_in.input_data_files_processed_content USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db2dataprocessor_in.idx_db2dataprocessor_in_input_data_files_processed_content_hash RENAME TO del_db2dataprocessor_in_input_data_files_processed_content_hash;
	    DROP INDEX IF EXISTS db2dataprocessor_in.del_db2dataprocessor_in_input_data_files_processed_content_hash;
	    CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_hash ON db2dataprocessor_in.input_data_files_processed_content USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db2dataprocessor_in_input_data_files_processed_content_hash ON db2dataprocessor_in.input_data_files_processed_content USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for input_data_files_processed_content ----------------------------------------------------


------------------------------------------------------------------------------------------------
    END IF; -- do migration
END
$$;

