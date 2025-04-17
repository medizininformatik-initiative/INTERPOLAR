-- Table "<%TABLE_NAME%>" in schema "<%OWNER_SCHEMA%>"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS <%OWNER_SCHEMA%>.<%TABLE_NAME%> (
  <%IF RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "<%TABLE_NAME%>_id int -- Primary key of the entity - already filled in this schema - History via timestamp"%>
  <%IF NOT RIGHTS_DEFINITION:TAGS "\bINT_ID\b" "<%TABLE_NAME%>_id int PRIMARY KEY DEFAULT nextval('db.db_seq') -- Primary key of the entity"%>
);

DO
$$
DECLARE
    IF EXISTS ( -- Table exists
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = 'input_datetime'
        ) THEN
            <%IF RIGHTS_DEFINITION:TAGS "\bTYPED\b" "ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD <%TABLE_NAME%>_raw_id int NOT NULL; -- Primary key of the corresponding raw table"%>
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
<%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES%>

-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'hash_index_col'
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         <%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES_HASH_WHERE%>''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         <%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES_HASH%>
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
            AND column_name = 'hash_index_col'
        ) THEN
            -- Creating the hash column
            ALTER TABLE <%OWNER_SCHEMA%>.<%TABLE_NAME%> ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         <%LOOP_COLS_SUB_LOOP_TABS_SUB_cre_table_TABLES_HASH%>
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
