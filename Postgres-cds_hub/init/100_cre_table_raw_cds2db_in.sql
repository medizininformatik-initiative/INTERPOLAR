-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2025-05-05 10:51:51
-- Rights definition file size        : 15631 Byte
--
-- Create SQL Tables in Schema "cds2db_in"
-- Create time: 2025-06-02 01:02:08
-- TABLE_DESCRIPTION:  ./R-cds2db/cds2db/inst/extdata/Table_Description.xlsx[table_description]
-- SCRIPTNAME:  100_cre_table_raw_cds2db_in.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  cds2db_user
-- OWNER_SCHEMA:  cds2db_in
-- TAGS:  RAW
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _raw
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  cds2db_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  
-- COPY_FUNC_TEMPLATE:  
-- COPY_FUNC_NAME:  
-- SCHEMA_2:  
-- TABLE_POSTFIX_2:  
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "cds2db_in" --
-----------------------------------------------------

-- Table "patient_raw" in schema "cds2db_in"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cds2db_in.patient_raw (
  patient_raw_id int PRIMARY KEY DEFAULT nextval('db.db_seq') -- Primary key of the entity
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw'
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (pat_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_id'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_id VARCHAR;   -- id (VARCHAR)
        END IF; -- column (pat_id)
        IF NOT EXISTS ( -- column not exists (pat_meta_versionid)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_meta_versionid'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_meta_versionid VARCHAR;   -- meta/versionId (VARCHAR)
        END IF; -- column (pat_meta_versionid)
        IF NOT EXISTS ( -- column not exists (pat_meta_lastupdated)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_meta_lastupdated'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_meta_lastupdated VARCHAR;   -- meta/lastUpdated (VARCHAR)
        END IF; -- column (pat_meta_lastupdated)
        IF NOT EXISTS ( -- column not exists (pat_meta_profile)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_meta_profile'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_meta_profile VARCHAR;   -- meta/profile (VARCHAR)
        END IF; -- column (pat_meta_profile)
        IF NOT EXISTS ( -- column not exists (pat_identifier_use)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_use'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_use VARCHAR;   -- identifier/use (VARCHAR)
        END IF; -- column (pat_identifier_use)
        IF NOT EXISTS ( -- column not exists (pat_identifier_type_system)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_type_system'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_type_system VARCHAR;   -- identifier/type/coding/system (VARCHAR)
        END IF; -- column (pat_identifier_type_system)
        IF NOT EXISTS ( -- column not exists (pat_identifier_type_version)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_type_version'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_type_version VARCHAR;   -- identifier/type/coding/version (VARCHAR)
        END IF; -- column (pat_identifier_type_version)
        IF NOT EXISTS ( -- column not exists (pat_identifier_type_code)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_type_code'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_type_code VARCHAR;   -- identifier/type/coding/code (VARCHAR)
        END IF; -- column (pat_identifier_type_code)
        IF NOT EXISTS ( -- column not exists (pat_identifier_type_display)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_type_display'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_type_display VARCHAR;   -- identifier/type/coding/display (VARCHAR)
        END IF; -- column (pat_identifier_type_display)
        IF NOT EXISTS ( -- column not exists (pat_identifier_type_text)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_type_text'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_type_text VARCHAR;   -- identifier/type/text (VARCHAR)
        END IF; -- column (pat_identifier_type_text)
        IF NOT EXISTS ( -- column not exists (pat_identifier_system)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_system'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_system VARCHAR;   -- identifier/system (VARCHAR)
        END IF; -- column (pat_identifier_system)
        IF NOT EXISTS ( -- column not exists (pat_identifier_value)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_value'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_value VARCHAR;   -- identifier/value (VARCHAR)
        END IF; -- column (pat_identifier_value)
        IF NOT EXISTS ( -- column not exists (pat_identifier_start)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_start'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_start VARCHAR;   -- identifier/start (VARCHAR)
        END IF; -- column (pat_identifier_start)
        IF NOT EXISTS ( -- column not exists (pat_identifier_end)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_identifier_end'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_identifier_end VARCHAR;   -- identifier/end (VARCHAR)
        END IF; -- column (pat_identifier_end)
        IF NOT EXISTS ( -- column not exists (pat_name_use)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_name_use'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_name_use VARCHAR;   -- name/use (VARCHAR)
        END IF; -- column (pat_name_use)
        IF NOT EXISTS ( -- column not exists (pat_name_text)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_name_text'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_name_text VARCHAR;   -- name/text (VARCHAR)
        END IF; -- column (pat_name_text)
        IF NOT EXISTS ( -- column not exists (pat_name_family)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_name_family'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_name_family VARCHAR;   -- name/family (VARCHAR)
        END IF; -- column (pat_name_family)
        IF NOT EXISTS ( -- column not exists (pat_name_given)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_name_given'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_name_given VARCHAR;   -- name/given (VARCHAR)
        END IF; -- column (pat_name_given)
        IF NOT EXISTS ( -- column not exists (pat_gender)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_gender'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_gender VARCHAR;   -- gender (VARCHAR)
        END IF; -- column (pat_gender)
        IF NOT EXISTS ( -- column not exists (pat_birthdate)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_birthdate'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_birthdate VARCHAR;   -- birthDate (VARCHAR)
        END IF; -- column (pat_birthdate)
        IF NOT EXISTS ( -- column not exists (pat_deceaseddatetime)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_deceaseddatetime'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_deceaseddatetime VARCHAR;   -- deceasedDateTime (VARCHAR)
        END IF; -- column (pat_deceaseddatetime)
        IF NOT EXISTS ( -- column not exists (pat_address_postalcode)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'pat_address_postalcode'
        ) THEN
            ALTER TABLE cds2db_in.patient_raw ADD pat_address_postalcode VARCHAR;   -- address/postalCode (VARCHAR)
        END IF; -- column (pat_address_postalcode)

-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'hash_index_col'
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(pat_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_use), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_type_system), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_type_version), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_type_code), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_type_display), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_type_text), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_system), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_value), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_start), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_identifier_end), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_name_use), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_name_text), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_name_family), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_name_given), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_gender), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_birthdate), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_deceaseddatetime), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_address_postalcode), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE cds2db_in.patient_raw DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE cds2db_in.patient_raw ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(pat_id), '#NULL#') || '|||' || -- hash from: id (pat_id)
          COALESCE(db.to_char_immutable(pat_identifier_use), '#NULL#') || '|||' || -- hash from: identifier/use (pat_identifier_use)
          COALESCE(db.to_char_immutable(pat_identifier_type_system), '#NULL#') || '|||' || -- hash from: identifier/type/coding/system (pat_identifier_type_system)
          COALESCE(db.to_char_immutable(pat_identifier_type_version), '#NULL#') || '|||' || -- hash from: identifier/type/coding/version (pat_identifier_type_version)
          COALESCE(db.to_char_immutable(pat_identifier_type_code), '#NULL#') || '|||' || -- hash from: identifier/type/coding/code (pat_identifier_type_code)
          COALESCE(db.to_char_immutable(pat_identifier_type_display), '#NULL#') || '|||' || -- hash from: identifier/type/coding/display (pat_identifier_type_display)
          COALESCE(db.to_char_immutable(pat_identifier_type_text), '#NULL#') || '|||' || -- hash from: identifier/type/text (pat_identifier_type_text)
          COALESCE(db.to_char_immutable(pat_identifier_system), '#NULL#') || '|||' || -- hash from: identifier/system (pat_identifier_system)
          COALESCE(db.to_char_immutable(pat_identifier_value), '#NULL#') || '|||' || -- hash from: identifier/value (pat_identifier_value)
          COALESCE(db.to_char_immutable(pat_identifier_start), '#NULL#') || '|||' || -- hash from: identifier/start (pat_identifier_start)
          COALESCE(db.to_char_immutable(pat_identifier_end), '#NULL#') || '|||' || -- hash from: identifier/end (pat_identifier_end)
          COALESCE(db.to_char_immutable(pat_name_use), '#NULL#') || '|||' || -- hash from: name/use (pat_name_use)
          COALESCE(db.to_char_immutable(pat_name_text), '#NULL#') || '|||' || -- hash from: name/text (pat_name_text)
          COALESCE(db.to_char_immutable(pat_name_family), '#NULL#') || '|||' || -- hash from: name/family (pat_name_family)
          COALESCE(db.to_char_immutable(pat_name_given), '#NULL#') || '|||' || -- hash from: name/given (pat_name_given)
          COALESCE(db.to_char_immutable(pat_gender), '#NULL#') || '|||' || -- hash from: gender (pat_gender)
          COALESCE(db.to_char_immutable(pat_birthdate), '#NULL#') || '|||' || -- hash from: birthDate (pat_birthdate)
          COALESCE(db.to_char_immutable(pat_deceaseddatetime), '#NULL#') || '|||' || -- hash from: deceasedDateTime (pat_deceaseddatetime)
          COALESCE(db.to_char_immutable(pat_address_postalcode), '#NULL#') || '|||' || -- hash from: address/postalCode (pat_address_postalcode)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'hash_index_col'
        ) THEN
            -- Creating the hash column
            ALTER TABLE cds2db_in.patient_raw ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(pat_id), '#NULL#') || '|||' || -- hash from: id (pat_id)
          COALESCE(db.to_char_immutable(pat_identifier_use), '#NULL#') || '|||' || -- hash from: identifier/use (pat_identifier_use)
          COALESCE(db.to_char_immutable(pat_identifier_type_system), '#NULL#') || '|||' || -- hash from: identifier/type/coding/system (pat_identifier_type_system)
          COALESCE(db.to_char_immutable(pat_identifier_type_version), '#NULL#') || '|||' || -- hash from: identifier/type/coding/version (pat_identifier_type_version)
          COALESCE(db.to_char_immutable(pat_identifier_type_code), '#NULL#') || '|||' || -- hash from: identifier/type/coding/code (pat_identifier_type_code)
          COALESCE(db.to_char_immutable(pat_identifier_type_display), '#NULL#') || '|||' || -- hash from: identifier/type/coding/display (pat_identifier_type_display)
          COALESCE(db.to_char_immutable(pat_identifier_type_text), '#NULL#') || '|||' || -- hash from: identifier/type/text (pat_identifier_type_text)
          COALESCE(db.to_char_immutable(pat_identifier_system), '#NULL#') || '|||' || -- hash from: identifier/system (pat_identifier_system)
          COALESCE(db.to_char_immutable(pat_identifier_value), '#NULL#') || '|||' || -- hash from: identifier/value (pat_identifier_value)
          COALESCE(db.to_char_immutable(pat_identifier_start), '#NULL#') || '|||' || -- hash from: identifier/start (pat_identifier_start)
          COALESCE(db.to_char_immutable(pat_identifier_end), '#NULL#') || '|||' || -- hash from: identifier/end (pat_identifier_end)
          COALESCE(db.to_char_immutable(pat_name_use), '#NULL#') || '|||' || -- hash from: name/use (pat_name_use)
          COALESCE(db.to_char_immutable(pat_name_text), '#NULL#') || '|||' || -- hash from: name/text (pat_name_text)
          COALESCE(db.to_char_immutable(pat_name_family), '#NULL#') || '|||' || -- hash from: name/family (pat_name_family)
          COALESCE(db.to_char_immutable(pat_name_given), '#NULL#') || '|||' || -- hash from: name/given (pat_name_given)
          COALESCE(db.to_char_immutable(pat_gender), '#NULL#') || '|||' || -- hash from: gender (pat_gender)
          COALESCE(db.to_char_immutable(pat_birthdate), '#NULL#') || '|||' || -- hash from: birthDate (pat_birthdate)
          COALESCE(db.to_char_immutable(pat_deceaseddatetime), '#NULL#') || '|||' || -- hash from: deceasedDateTime (pat_deceaseddatetime)
          COALESCE(db.to_char_immutable(pat_address_postalcode), '#NULL#') || '|||' || -- hash from: address/postalCode (pat_address_postalcode)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;

COMMENT ON COLUMN cds2db_in.patient_raw.patient_raw_id IS 'Primary key of the entity';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_id IS 'id (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_meta_versionid IS 'meta/versionId (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_meta_lastupdated IS 'meta/lastUpdated (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_meta_profile IS 'meta/profile (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_use IS 'identifier/use (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_system IS 'identifier/type/coding/system (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_version IS 'identifier/type/coding/version (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_code IS 'identifier/type/coding/code (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_display IS 'identifier/type/coding/display (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_type_text IS 'identifier/type/text (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_system IS 'identifier/system (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_value IS 'identifier/value (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_start IS 'identifier/start (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_identifier_end IS 'identifier/end (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_name_use IS 'name/use (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_name_text IS 'name/text (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_name_family IS 'name/family (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_name_given IS 'name/given (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_gender IS 'gender (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_birthdate IS 'birthDate (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_deceaseddatetime IS 'deceasedDateTime (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.pat_address_postalcode IS 'address/postalCode (varchar)';
COMMENT ON COLUMN cds2db_in.patient_raw.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN cds2db_in.patient_raw.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN cds2db_in.patient_raw.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN cds2db_in.patient_raw.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN cds2db_in.patient_raw.last_processing_nr IS 'Last processing number of the data record';

-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "cds2db_in" --
------------------------------------------------------
DO
$$
BEGIN
------------------------------------------------------------------------------------------------


------------------------- Index for cds2db_in - patient_raw ---------------------------------

-- Index idx_cds2db_in_patient_raw_input_dt for Table "patient_raw" in schema "cds2db_in"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'cds2db_in' AND table_name = 'patient_raw' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_cds2db_in_patient_raw_input_dt',1,63) AND schemaname = 'cds2db_in' AND tablename = 'patient_raw'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'cds2db_in' AND tablename = 'patient_raw' AND substr(indexname,1,63)=substr('idx_cds2db_in_patient_raw_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_cds2db_in_patient_raw_input_dt ON cds2db_in.patient_raw USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	    DROP INDEX IF EXISTS idx_cds2db_in_patient_raw_input_dt;
	    CREATE INDEX idx_cds2db_in_patient_raw_input_dt ON cds2db_in.patient_raw USING brin (input_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_cds2db_in_patient_raw_input_dt ON cds2db_in.patient_raw USING brin (input_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

------------------------------------------------------------------------------------------------
END
$$;

