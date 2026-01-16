-- ########################################################################################################
--
-- This file is generated. Changes should only be made by regenerating the file.
--
-- Rights definition file             : ./Postgres-cds_hub/init/template/User_Schema_Rights_Definition.xlsx
-- Rights definition file last update : 2026-01-13 11:37:49
-- Rights definition file size        : 16352 Byte
--
-- Create SQL Tables in Schema "db_log"
-- Create time: 2026-01-13 13:21:40
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  430_cre_table_frontend_log.sql
-- TEMPLATE:  template_cre_table.sql
-- OWNER_USER:  db_log_user
-- OWNER_SCHEMA:  db_log
-- TAGS:  INT_ID FE_RC_ID
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _fe
-- RIGHTS:  INSERT, DELETE, UPDATE, SELECT
-- GRANT_TARGET_USER:  db_log_user
-- GRANT_TARGET_USER (2):  db_user
-- COPY_FUNC_SCRIPTNAME:  620_fe_in_to_db_log.sql
-- COPY_FUNC_TEMPLATE:  template_copy_function.sql
-- COPY_FUNC_NAME:  copy_fe_fe_in_to_db_log
-- SCHEMA_2:  db2frontend_in
-- TABLE_POSTFIX_2:  _fe
-- SCHEMA_3:  
-- TABLE_POSTFIX_3:  
-- ########################################################################################################

-----------------------------------------------------
-- Create SQL Tables in Schema "db_log" --
-----------------------------------------------------

-- Table "patient_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.patient_fe (
  patient_fe_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'patient_fe') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (record_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'record_id'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD record_id varchar;   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
        END IF; -- column (record_id)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instrument)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'redcap_repeat_instrument'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD redcap_repeat_instrument varchar;   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
        END IF; -- column (redcap_repeat_instrument)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instance)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'redcap_repeat_instance'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD redcap_repeat_instance varchar;   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
        END IF; -- column (redcap_repeat_instance)

        IF NOT EXISTS ( -- column not exists (redcap_data_access_group)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'redcap_data_access_group'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD redcap_data_access_group varchar;   -- Function as dataset filter by stations (varchar)
        END IF; -- column (redcap_data_access_group)

        IF NOT EXISTS ( -- column not exists (projekt_versionsnummer)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'projekt_versionsnummer'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD projekt_versionsnummer varchar;   -- Versionsnummer zum Matching von REDCap-Projektversion mit weiteren Versionselementen der Toolchain (varchar)
        END IF; -- column (projekt_versionsnummer)

        IF NOT EXISTS ( -- column not exists (pat_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_id'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_id varchar;   -- Patient-identifier (FHIR) (varchar)
        END IF; -- column (pat_id)

        IF NOT EXISTS ( -- column not exists (pat_cis_pid)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_cis_pid'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_cis_pid varchar;   -- Patient-identifier (KIS) (varchar)
        END IF; -- column (pat_cis_pid)

        IF NOT EXISTS ( -- column not exists (pat_name)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_name'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_name varchar;   -- Patientenname (varchar)
        END IF; -- column (pat_name)

        IF NOT EXISTS ( -- column not exists (pat_vorname)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_vorname'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_vorname varchar;   -- Patientenvorname (varchar)
        END IF; -- column (pat_vorname)

        IF NOT EXISTS ( -- column not exists (pat_gebdat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_gebdat'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_gebdat date;   -- Geburtsdatum (date)
        END IF; -- column (pat_gebdat)

        IF NOT EXISTS ( -- column not exists (pat_aktuell_alter)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_aktuell_alter'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_aktuell_alter double precision;   -- aktuelles Patientenalter (Jahre) (double precision)
        END IF; -- column (pat_aktuell_alter)

        IF NOT EXISTS ( -- column not exists (pat_geschlecht)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_geschlecht'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_geschlecht varchar;   -- Geschlecht (varchar)
        END IF; -- column (pat_geschlecht)

        IF NOT EXISTS ( -- column not exists (pat_additional_values)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'pat_additional_values'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD pat_additional_values varchar;   -- Reserviertes Feld für zusätzliche Werte (varchar)
        END IF; -- column (pat_additional_values)

        IF NOT EXISTS ( -- column not exists (patient_complete)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'patient_complete'
        ) THEN
            ALTER TABLE db_log.patient_fe ADD patient_complete varchar;   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
        END IF; -- column (patient_complete)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(record_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instance), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_data_access_group), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(projekt_versionsnummer), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_cis_pid), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_name), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_vorname), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_gebdat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_aktuell_alter), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_geschlecht), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(pat_additional_values), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(patient_complete), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.patient_fe DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.patient_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(projekt_versionsnummer), '#NULL#') || '|||' || -- hash from: Versionsnummer zum Matching von REDCap-Projektversion mit weiteren Versionselementen der Toolchain (projekt_versionsnummer)
          COALESCE(db.to_char_immutable(pat_id), '#NULL#') || '|||' || -- hash from: Patient-identifier (FHIR) (pat_id)
          COALESCE(db.to_char_immutable(pat_cis_pid), '#NULL#') || '|||' || -- hash from: Patient-identifier (KIS) (pat_cis_pid)
          COALESCE(db.to_char_immutable(pat_name), '#NULL#') || '|||' || -- hash from: Patientenname (pat_name)
          COALESCE(db.to_char_immutable(pat_vorname), '#NULL#') || '|||' || -- hash from: Patientenvorname (pat_vorname)
          COALESCE(db.to_char_immutable(pat_gebdat), '#NULL#') || '|||' || -- hash from: Geburtsdatum (pat_gebdat)
          COALESCE(db.to_char_immutable(pat_aktuell_alter), '#NULL#') || '|||' || -- hash from: aktuelles Patientenalter (Jahre) (pat_aktuell_alter)
          COALESCE(db.to_char_immutable(pat_geschlecht), '#NULL#') || '|||' || -- hash from: Geschlecht (pat_geschlecht)
          COALESCE(db.to_char_immutable(pat_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (pat_additional_values)
          COALESCE(db.to_char_immutable(patient_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (patient_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.patient_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(projekt_versionsnummer), '#NULL#') || '|||' || -- hash from: Versionsnummer zum Matching von REDCap-Projektversion mit weiteren Versionselementen der Toolchain (projekt_versionsnummer)
          COALESCE(db.to_char_immutable(pat_id), '#NULL#') || '|||' || -- hash from: Patient-identifier (FHIR) (pat_id)
          COALESCE(db.to_char_immutable(pat_cis_pid), '#NULL#') || '|||' || -- hash from: Patient-identifier (KIS) (pat_cis_pid)
          COALESCE(db.to_char_immutable(pat_name), '#NULL#') || '|||' || -- hash from: Patientenname (pat_name)
          COALESCE(db.to_char_immutable(pat_vorname), '#NULL#') || '|||' || -- hash from: Patientenvorname (pat_vorname)
          COALESCE(db.to_char_immutable(pat_gebdat), '#NULL#') || '|||' || -- hash from: Geburtsdatum (pat_gebdat)
          COALESCE(db.to_char_immutable(pat_aktuell_alter), '#NULL#') || '|||' || -- hash from: aktuelles Patientenalter (Jahre) (pat_aktuell_alter)
          COALESCE(db.to_char_immutable(pat_geschlecht), '#NULL#') || '|||' || -- hash from: Geschlecht (pat_geschlecht)
          COALESCE(db.to_char_immutable(pat_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (pat_additional_values)
          COALESCE(db.to_char_immutable(patient_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (patient_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
-- Table "fall_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.fall_fe (
  fall_fe_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'fall_fe') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (record_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'record_id'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD record_id varchar;   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
        END IF; -- column (record_id)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instrument)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'redcap_repeat_instrument'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD redcap_repeat_instrument varchar;   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
        END IF; -- column (redcap_repeat_instrument)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instance)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'redcap_repeat_instance'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD redcap_repeat_instance varchar;   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
        END IF; -- column (redcap_repeat_instance)

        IF NOT EXISTS ( -- column not exists (redcap_data_access_group)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'redcap_data_access_group'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD redcap_data_access_group varchar;   -- Function as dataset filter by stations (varchar)
        END IF; -- column (redcap_data_access_group)

        IF NOT EXISTS ( -- column not exists (db_filter_8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'db_filter_8'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD db_filter_8 double precision;   -- Dashboard Filter 8 (double precision)
        END IF; -- column (db_filter_8)

        IF NOT EXISTS ( -- column not exists (fall_fhir_enc_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_fhir_enc_id'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_fhir_enc_id varchar;   -- verstecktes Feld für FHIR-ID des Encounters (varchar)
        END IF; -- column (fall_fhir_enc_id)

        IF NOT EXISTS ( -- column not exists (patient_id_fk)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'patient_id_fk'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD patient_id_fk int;   -- verstecktes Feld für patient_id_fk (int)
        END IF; -- column (patient_id_fk)

        IF NOT EXISTS ( -- column not exists (fall_pat_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_pat_id'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_pat_id varchar;   -- verstecktes Feld für fall_pat_id (varchar)
        END IF; -- column (fall_pat_id)

        IF NOT EXISTS ( -- column not exists (fall_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_id'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_id varchar;   -- Fall-ID Encounter-Identifier (KIS) (varchar)
        END IF; -- column (fall_id)

        IF NOT EXISTS ( -- column not exists (fall_studienphase)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_studienphase'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_studienphase varchar;   -- Studienphase (varchar)
        END IF; -- column (fall_studienphase)

        IF NOT EXISTS ( -- column not exists (fall_station)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_station'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_station varchar;   -- Station (varchar)
        END IF; -- column (fall_station)

        IF NOT EXISTS ( -- column not exists (fall_aufn_dat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_aufn_dat'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_aufn_dat timestamp;   -- Aufnahmedatum (timestamp)
        END IF; -- column (fall_aufn_dat)

        IF NOT EXISTS ( -- column not exists (fall_zimmernr)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_zimmernr'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_zimmernr varchar;   -- Zimmer-Nr. (varchar)
        END IF; -- column (fall_zimmernr)

        IF NOT EXISTS ( -- column not exists (fall_aufn_diag)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_aufn_diag'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_aufn_diag varchar;   -- Diagnose(n) bei Aufnahme (varchar)
        END IF; -- column (fall_aufn_diag)

        IF NOT EXISTS ( -- column not exists (fall_gewicht_aktuell)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_gewicht_aktuell'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_gewicht_aktuell double precision;   -- aktuelles Gewicht (double precision)
        END IF; -- column (fall_gewicht_aktuell)

        IF NOT EXISTS ( -- column not exists (fall_gewicht_aktl_einheit)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_gewicht_aktl_einheit'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_gewicht_aktl_einheit varchar;   -- aktuelles Gewicht: Einheit (varchar)
        END IF; -- column (fall_gewicht_aktl_einheit)

        IF NOT EXISTS ( -- column not exists (fall_groesse)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_groesse'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_groesse double precision;   -- Größe (double precision)
        END IF; -- column (fall_groesse)

        IF NOT EXISTS ( -- column not exists (fall_groesse_einheit)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_groesse_einheit'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_groesse_einheit varchar;   -- Größe: Einheit (varchar)
        END IF; -- column (fall_groesse_einheit)

        IF NOT EXISTS ( -- column not exists (fall_bmi)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_bmi'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_bmi double precision;   -- BMI (double precision)
        END IF; -- column (fall_bmi)

        IF NOT EXISTS ( -- column not exists (fall_status)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_status'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_status varchar;   -- Fallstatus (varchar)
        END IF; -- column (fall_status)

        IF NOT EXISTS ( -- column not exists (fall_ent_dat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_ent_dat'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_ent_dat timestamp;   -- Entlassdatum (timestamp)
        END IF; -- column (fall_ent_dat)

        IF NOT EXISTS ( -- column not exists (fall_additional_values)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_additional_values'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_additional_values varchar;   -- Reserviertes Feld für zusätzliche Werte (varchar)
        END IF; -- column (fall_additional_values)

        IF NOT EXISTS ( -- column not exists (fall_complete)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_complete'
        ) THEN
            ALTER TABLE db_log.fall_fe ADD fall_complete varchar;   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
        END IF; -- column (fall_complete)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(record_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instance), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_data_access_group), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(db_filter_8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_fhir_enc_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(patient_id_fk), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_pat_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_studienphase), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_station), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_aufn_dat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_zimmernr), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_aufn_diag), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_gewicht_aktuell), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_gewicht_aktl_einheit), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_groesse), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_groesse_einheit), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_bmi), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_status), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_ent_dat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_additional_values), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_complete), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.fall_fe DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.fall_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(db_filter_8), '#NULL#') || '|||' || -- hash from: Dashboard Filter 8 (db_filter_8)
          COALESCE(db.to_char_immutable(fall_fhir_enc_id), '#NULL#') || '|||' || -- hash from: verstecktes Feld für FHIR-ID des Encounters (fall_fhir_enc_id)
          COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: verstecktes Feld für patient_id_fk (patient_id_fk)
          COALESCE(db.to_char_immutable(fall_pat_id), '#NULL#') || '|||' || -- hash from: verstecktes Feld für fall_pat_id (fall_pat_id)
          COALESCE(db.to_char_immutable(fall_id), '#NULL#') || '|||' || -- hash from: Fall-ID Encounter-Identifier (KIS) (fall_id)
          COALESCE(db.to_char_immutable(fall_studienphase), '#NULL#') || '|||' || -- hash from: Studienphase (fall_studienphase)
          COALESCE(db.to_char_immutable(fall_station), '#NULL#') || '|||' || -- hash from: Station (fall_station)
          COALESCE(db.to_char_immutable(fall_aufn_dat), '#NULL#') || '|||' || -- hash from: Aufnahmedatum (fall_aufn_dat)
          COALESCE(db.to_char_immutable(fall_zimmernr), '#NULL#') || '|||' || -- hash from: Zimmer-Nr. (fall_zimmernr)
          COALESCE(db.to_char_immutable(fall_aufn_diag), '#NULL#') || '|||' || -- hash from: Diagnose(n) bei Aufnahme (fall_aufn_diag)
          COALESCE(db.to_char_immutable(fall_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (fall_gewicht_aktuell)
          COALESCE(db.to_char_immutable(fall_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht: Einheit (fall_gewicht_aktl_einheit)
          COALESCE(db.to_char_immutable(fall_groesse), '#NULL#') || '|||' || -- hash from: Größe (fall_groesse)
          COALESCE(db.to_char_immutable(fall_groesse_einheit), '#NULL#') || '|||' || -- hash from: Größe: Einheit (fall_groesse_einheit)
          COALESCE(db.to_char_immutable(fall_bmi), '#NULL#') || '|||' || -- hash from: BMI (fall_bmi)
          COALESCE(db.to_char_immutable(fall_status), '#NULL#') || '|||' || -- hash from: Fallstatus (fall_status)
          COALESCE(db.to_char_immutable(fall_ent_dat), '#NULL#') || '|||' || -- hash from: Entlassdatum (fall_ent_dat)
          COALESCE(db.to_char_immutable(fall_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (fall_additional_values)
          COALESCE(db.to_char_immutable(fall_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (fall_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.fall_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(db_filter_8), '#NULL#') || '|||' || -- hash from: Dashboard Filter 8 (db_filter_8)
          COALESCE(db.to_char_immutable(fall_fhir_enc_id), '#NULL#') || '|||' || -- hash from: verstecktes Feld für FHIR-ID des Encounters (fall_fhir_enc_id)
          COALESCE(db.to_char_immutable(patient_id_fk), '#NULL#') || '|||' || -- hash from: verstecktes Feld für patient_id_fk (patient_id_fk)
          COALESCE(db.to_char_immutable(fall_pat_id), '#NULL#') || '|||' || -- hash from: verstecktes Feld für fall_pat_id (fall_pat_id)
          COALESCE(db.to_char_immutable(fall_id), '#NULL#') || '|||' || -- hash from: Fall-ID Encounter-Identifier (KIS) (fall_id)
          COALESCE(db.to_char_immutable(fall_studienphase), '#NULL#') || '|||' || -- hash from: Studienphase (fall_studienphase)
          COALESCE(db.to_char_immutable(fall_station), '#NULL#') || '|||' || -- hash from: Station (fall_station)
          COALESCE(db.to_char_immutable(fall_aufn_dat), '#NULL#') || '|||' || -- hash from: Aufnahmedatum (fall_aufn_dat)
          COALESCE(db.to_char_immutable(fall_zimmernr), '#NULL#') || '|||' || -- hash from: Zimmer-Nr. (fall_zimmernr)
          COALESCE(db.to_char_immutable(fall_aufn_diag), '#NULL#') || '|||' || -- hash from: Diagnose(n) bei Aufnahme (fall_aufn_diag)
          COALESCE(db.to_char_immutable(fall_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (fall_gewicht_aktuell)
          COALESCE(db.to_char_immutable(fall_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht: Einheit (fall_gewicht_aktl_einheit)
          COALESCE(db.to_char_immutable(fall_groesse), '#NULL#') || '|||' || -- hash from: Größe (fall_groesse)
          COALESCE(db.to_char_immutable(fall_groesse_einheit), '#NULL#') || '|||' || -- hash from: Größe: Einheit (fall_groesse_einheit)
          COALESCE(db.to_char_immutable(fall_bmi), '#NULL#') || '|||' || -- hash from: BMI (fall_bmi)
          COALESCE(db.to_char_immutable(fall_status), '#NULL#') || '|||' || -- hash from: Fallstatus (fall_status)
          COALESCE(db.to_char_immutable(fall_ent_dat), '#NULL#') || '|||' || -- hash from: Entlassdatum (fall_ent_dat)
          COALESCE(db.to_char_immutable(fall_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (fall_additional_values)
          COALESCE(db.to_char_immutable(fall_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (fall_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
-- Table "medikationsanalyse_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.medikationsanalyse_fe (
  medikationsanalyse_fe_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (record_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'record_id'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD record_id varchar;   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
        END IF; -- column (record_id)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instrument)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'redcap_repeat_instrument'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD redcap_repeat_instrument varchar;   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
        END IF; -- column (redcap_repeat_instrument)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instance)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'redcap_repeat_instance'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD redcap_repeat_instance varchar;   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
        END IF; -- column (redcap_repeat_instance)

        IF NOT EXISTS ( -- column not exists (redcap_data_access_group)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'redcap_data_access_group'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD redcap_data_access_group varchar;   -- Function as dataset filter by stations (varchar)
        END IF; -- column (redcap_data_access_group)

        IF NOT EXISTS ( -- column not exists (db_filter_5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'db_filter_5'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD db_filter_5 double precision;   -- Dashboard Filter 5 (double precision)
        END IF; -- column (db_filter_5)

        IF NOT EXISTS ( -- column not exists (db_filter_7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'db_filter_7'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD db_filter_7 double precision;   -- Dashboard Filter 7 (double precision)
        END IF; -- column (db_filter_7)

        IF NOT EXISTS ( -- column not exists (meda_anlage)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_anlage'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_anlage varchar;   -- Formular angelegt von (varchar)
        END IF; -- column (meda_anlage)

        IF NOT EXISTS ( -- column not exists (meda_edit)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_edit'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_edit varchar;   -- Formular zuletzt bearbeitet von (varchar)
        END IF; -- column (meda_edit)

        IF NOT EXISTS ( -- column not exists (fall_meda_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'fall_meda_id'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD fall_meda_id varchar;   -- 1 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu Fall (Fall-ID Encounter-Identifier (KIS)) Auswahlfeld falls die aktuell dokumentierte Medikationsanalyse sich nicht auf die letzte Instanz des Falls bezieht.   (varchar)
        END IF; -- column (fall_meda_id)

        IF NOT EXISTS ( -- column not exists (meda_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_id'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_id varchar;   -- ID Medikationsanalyse (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse aggregiert (varchar)
        END IF; -- column (meda_id)

        IF NOT EXISTS ( -- column not exists (meda_typ)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_typ'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_typ varchar;   -- Typ der Medikationsanalyse (MA) (varchar)
        END IF; -- column (meda_typ)

        IF NOT EXISTS ( -- column not exists (meda_dat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_dat'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_dat timestamp;   -- Datum der Medikationsanalyse (timestamp)
        END IF; -- column (meda_dat)

        IF NOT EXISTS ( -- column not exists (meda_gewicht_aktuell)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_gewicht_aktuell'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_gewicht_aktuell double precision;   -- aktuelles Gewicht (double precision)
        END IF; -- column (meda_gewicht_aktuell)

        IF NOT EXISTS ( -- column not exists (meda_gewicht_aktl_einheit)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_gewicht_aktl_einheit'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_gewicht_aktl_einheit varchar;   -- aktuelles Gewicht: Einheit (varchar)
        END IF; -- column (meda_gewicht_aktl_einheit)

        IF NOT EXISTS ( -- column not exists (meda_groesse)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_groesse'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_groesse double precision;   -- Größe (double precision)
        END IF; -- column (meda_groesse)

        IF NOT EXISTS ( -- column not exists (meda_groesse_einheit)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_groesse_einheit'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_groesse_einheit varchar;   -- Größe: Einheit (varchar)
        END IF; -- column (meda_groesse_einheit)

        IF NOT EXISTS ( -- column not exists (meda_bmi)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_bmi'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_bmi double precision;   -- BMI (double precision)
        END IF; -- column (meda_bmi)

        IF NOT EXISTS ( -- column not exists (meda_nieren_insuf_chron)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_nieren_insuf_chron'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_nieren_insuf_chron varchar;   -- Chronische Niereninsuffizienz (varchar)
        END IF; -- column (meda_nieren_insuf_chron)

        IF NOT EXISTS ( -- column not exists (meda_nieren_insuf_ausmass)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_nieren_insuf_ausmass'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_nieren_insuf_ausmass varchar;   -- aktuelles Ausmaß (varchar)
        END IF; -- column (meda_nieren_insuf_ausmass)

        IF NOT EXISTS ( -- column not exists (meda_nieren_insuf_dialysev)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_nieren_insuf_dialysev'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_nieren_insuf_dialysev varchar;   -- Nierenersatzverfahren (varchar)
        END IF; -- column (meda_nieren_insuf_dialysev)

        IF NOT EXISTS ( -- column not exists (meda_leber_insuf)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_leber_insuf'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_leber_insuf varchar;   -- Leberinsuffizienz (varchar)
        END IF; -- column (meda_leber_insuf)

        IF NOT EXISTS ( -- column not exists (meda_leber_insuf_ausmass)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_leber_insuf_ausmass'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_leber_insuf_ausmass varchar;   -- aktuelles Ausmaß (varchar)
        END IF; -- column (meda_leber_insuf_ausmass)

        IF NOT EXISTS ( -- column not exists (meda_schwanger_mo)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_schwanger_mo'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_schwanger_mo varchar;   -- Schwangerschaftsmonat (varchar)
        END IF; -- column (meda_schwanger_mo)

        IF NOT EXISTS ( -- column not exists (meda_ma_thueberw)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_ma_thueberw'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_ma_thueberw varchar;   -- Wiedervorlage Medikationsanalyse in 24-48h (varchar)
        END IF; -- column (meda_ma_thueberw)

        IF NOT EXISTS ( -- column not exists (meda_mrp_detekt)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_mrp_detekt'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_mrp_detekt varchar;   -- MRP detektiert? (varchar)
        END IF; -- column (meda_mrp_detekt)

        IF NOT EXISTS ( -- column not exists (meda_aufwand_zeit)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_aufwand_zeit'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_aufwand_zeit varchar;   -- Zeitaufwand Medikationsanalyse (varchar)
        END IF; -- column (meda_aufwand_zeit)

        IF NOT EXISTS ( -- column not exists (meda_aufwand_zeit_and)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_aufwand_zeit_and'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_aufwand_zeit_and int;   -- genaue Dauer in Minuten (int)
        END IF; -- column (meda_aufwand_zeit_and)

        IF NOT EXISTS ( -- column not exists (meda_notiz)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_notiz'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_notiz varchar;   -- Notizfeld (varchar)
        END IF; -- column (meda_notiz)

        IF NOT EXISTS ( -- column not exists (meda_additional_values)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'meda_additional_values'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD meda_additional_values varchar;   -- Reserviertes Feld für zusätzliche Werte (varchar)
        END IF; -- column (meda_additional_values)

        IF NOT EXISTS ( -- column not exists (medikationsanalyse_complete)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'medikationsanalyse_complete'
        ) THEN
            ALTER TABLE db_log.medikationsanalyse_fe ADD medikationsanalyse_complete varchar;   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
        END IF; -- column (medikationsanalyse_complete)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(record_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instance), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_data_access_group), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(db_filter_5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(db_filter_7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_anlage), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_edit), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(fall_meda_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_typ), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_dat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_gewicht_aktuell), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_gewicht_aktl_einheit), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_groesse), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_groesse_einheit), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_bmi), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_nieren_insuf_chron), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_nieren_insuf_ausmass), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_nieren_insuf_dialysev), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_leber_insuf), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_leber_insuf_ausmass), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_schwanger_mo), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_ma_thueberw), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_mrp_detekt), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_aufwand_zeit), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_aufwand_zeit_and), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_notiz), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(meda_additional_values), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(medikationsanalyse_complete), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.medikationsanalyse_fe DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.medikationsanalyse_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(db_filter_5), '#NULL#') || '|||' || -- hash from: Dashboard Filter 5 (db_filter_5)
          COALESCE(db.to_char_immutable(db_filter_7), '#NULL#') || '|||' || -- hash from: Dashboard Filter 7 (db_filter_7)
          COALESCE(db.to_char_immutable(meda_anlage), '#NULL#') || '|||' || -- hash from: Formular angelegt von (meda_anlage)
          COALESCE(db.to_char_immutable(meda_edit), '#NULL#') || '|||' || -- hash from: Formular zuletzt bearbeitet von (meda_edit)
          COALESCE(db.to_char_immutable(fall_meda_id), '#NULL#') || '|||' || -- hash from: 1 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu Fall (Fall-ID Encounter-Identifier (KIS)) Auswahlfeld falls die aktuell dokumentierte Medikationsanalyse sich nicht auf die letzte Instanz des Falls bezieht.   (fall_meda_id)
          COALESCE(db.to_char_immutable(meda_id), '#NULL#') || '|||' || -- hash from: ID Medikationsanalyse (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse aggregiert (meda_id)
          COALESCE(db.to_char_immutable(meda_typ), '#NULL#') || '|||' || -- hash from: Typ der Medikationsanalyse (MA) (meda_typ)
          COALESCE(db.to_char_immutable(meda_dat), '#NULL#') || '|||' || -- hash from: Datum der Medikationsanalyse (meda_dat)
          COALESCE(db.to_char_immutable(meda_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (meda_gewicht_aktuell)
          COALESCE(db.to_char_immutable(meda_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht: Einheit (meda_gewicht_aktl_einheit)
          COALESCE(db.to_char_immutable(meda_groesse), '#NULL#') || '|||' || -- hash from: Größe (meda_groesse)
          COALESCE(db.to_char_immutable(meda_groesse_einheit), '#NULL#') || '|||' || -- hash from: Größe: Einheit (meda_groesse_einheit)
          COALESCE(db.to_char_immutable(meda_bmi), '#NULL#') || '|||' || -- hash from: BMI (meda_bmi)
          COALESCE(db.to_char_immutable(meda_nieren_insuf_chron), '#NULL#') || '|||' || -- hash from: Chronische Niereninsuffizienz (meda_nieren_insuf_chron)
          COALESCE(db.to_char_immutable(meda_nieren_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß (meda_nieren_insuf_ausmass)
          COALESCE(db.to_char_immutable(meda_nieren_insuf_dialysev), '#NULL#') || '|||' || -- hash from: Nierenersatzverfahren (meda_nieren_insuf_dialysev)
          COALESCE(db.to_char_immutable(meda_leber_insuf), '#NULL#') || '|||' || -- hash from: Leberinsuffizienz (meda_leber_insuf)
          COALESCE(db.to_char_immutable(meda_leber_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß (meda_leber_insuf_ausmass)
          COALESCE(db.to_char_immutable(meda_schwanger_mo), '#NULL#') || '|||' || -- hash from: Schwangerschaftsmonat (meda_schwanger_mo)
          COALESCE(db.to_char_immutable(meda_ma_thueberw), '#NULL#') || '|||' || -- hash from: Wiedervorlage Medikationsanalyse in 24-48h (meda_ma_thueberw)
          COALESCE(db.to_char_immutable(meda_mrp_detekt), '#NULL#') || '|||' || -- hash from: MRP detektiert? (meda_mrp_detekt)
          COALESCE(db.to_char_immutable(meda_aufwand_zeit), '#NULL#') || '|||' || -- hash from: Zeitaufwand Medikationsanalyse (meda_aufwand_zeit)
          COALESCE(db.to_char_immutable(meda_aufwand_zeit_and), '#NULL#') || '|||' || -- hash from: genaue Dauer in Minuten (meda_aufwand_zeit_and)
          COALESCE(db.to_char_immutable(meda_notiz), '#NULL#') || '|||' || -- hash from: Notizfeld (meda_notiz)
          COALESCE(db.to_char_immutable(meda_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (meda_additional_values)
          COALESCE(db.to_char_immutable(medikationsanalyse_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (medikationsanalyse_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.medikationsanalyse_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(db_filter_5), '#NULL#') || '|||' || -- hash from: Dashboard Filter 5 (db_filter_5)
          COALESCE(db.to_char_immutable(db_filter_7), '#NULL#') || '|||' || -- hash from: Dashboard Filter 7 (db_filter_7)
          COALESCE(db.to_char_immutable(meda_anlage), '#NULL#') || '|||' || -- hash from: Formular angelegt von (meda_anlage)
          COALESCE(db.to_char_immutable(meda_edit), '#NULL#') || '|||' || -- hash from: Formular zuletzt bearbeitet von (meda_edit)
          COALESCE(db.to_char_immutable(fall_meda_id), '#NULL#') || '|||' || -- hash from: 1 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu Fall (Fall-ID Encounter-Identifier (KIS)) Auswahlfeld falls die aktuell dokumentierte Medikationsanalyse sich nicht auf die letzte Instanz des Falls bezieht.   (fall_meda_id)
          COALESCE(db.to_char_immutable(meda_id), '#NULL#') || '|||' || -- hash from: ID Medikationsanalyse (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse aggregiert (meda_id)
          COALESCE(db.to_char_immutable(meda_typ), '#NULL#') || '|||' || -- hash from: Typ der Medikationsanalyse (MA) (meda_typ)
          COALESCE(db.to_char_immutable(meda_dat), '#NULL#') || '|||' || -- hash from: Datum der Medikationsanalyse (meda_dat)
          COALESCE(db.to_char_immutable(meda_gewicht_aktuell), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht (meda_gewicht_aktuell)
          COALESCE(db.to_char_immutable(meda_gewicht_aktl_einheit), '#NULL#') || '|||' || -- hash from: aktuelles Gewicht: Einheit (meda_gewicht_aktl_einheit)
          COALESCE(db.to_char_immutable(meda_groesse), '#NULL#') || '|||' || -- hash from: Größe (meda_groesse)
          COALESCE(db.to_char_immutable(meda_groesse_einheit), '#NULL#') || '|||' || -- hash from: Größe: Einheit (meda_groesse_einheit)
          COALESCE(db.to_char_immutable(meda_bmi), '#NULL#') || '|||' || -- hash from: BMI (meda_bmi)
          COALESCE(db.to_char_immutable(meda_nieren_insuf_chron), '#NULL#') || '|||' || -- hash from: Chronische Niereninsuffizienz (meda_nieren_insuf_chron)
          COALESCE(db.to_char_immutable(meda_nieren_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß (meda_nieren_insuf_ausmass)
          COALESCE(db.to_char_immutable(meda_nieren_insuf_dialysev), '#NULL#') || '|||' || -- hash from: Nierenersatzverfahren (meda_nieren_insuf_dialysev)
          COALESCE(db.to_char_immutable(meda_leber_insuf), '#NULL#') || '|||' || -- hash from: Leberinsuffizienz (meda_leber_insuf)
          COALESCE(db.to_char_immutable(meda_leber_insuf_ausmass), '#NULL#') || '|||' || -- hash from: aktuelles Ausmaß (meda_leber_insuf_ausmass)
          COALESCE(db.to_char_immutable(meda_schwanger_mo), '#NULL#') || '|||' || -- hash from: Schwangerschaftsmonat (meda_schwanger_mo)
          COALESCE(db.to_char_immutable(meda_ma_thueberw), '#NULL#') || '|||' || -- hash from: Wiedervorlage Medikationsanalyse in 24-48h (meda_ma_thueberw)
          COALESCE(db.to_char_immutable(meda_mrp_detekt), '#NULL#') || '|||' || -- hash from: MRP detektiert? (meda_mrp_detekt)
          COALESCE(db.to_char_immutable(meda_aufwand_zeit), '#NULL#') || '|||' || -- hash from: Zeitaufwand Medikationsanalyse (meda_aufwand_zeit)
          COALESCE(db.to_char_immutable(meda_aufwand_zeit_and), '#NULL#') || '|||' || -- hash from: genaue Dauer in Minuten (meda_aufwand_zeit_and)
          COALESCE(db.to_char_immutable(meda_notiz), '#NULL#') || '|||' || -- hash from: Notizfeld (meda_notiz)
          COALESCE(db.to_char_immutable(meda_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (meda_additional_values)
          COALESCE(db.to_char_immutable(medikationsanalyse_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (medikationsanalyse_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
-- Table "mrpdokumentation_validierung_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.mrpdokumentation_validierung_fe (
  mrpdokumentation_validierung_fe_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (record_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'record_id'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD record_id varchar;   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
        END IF; -- column (record_id)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instrument)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'redcap_repeat_instrument'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD redcap_repeat_instrument varchar;   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
        END IF; -- column (redcap_repeat_instrument)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instance)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'redcap_repeat_instance'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD redcap_repeat_instance varchar;   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
        END IF; -- column (redcap_repeat_instance)

        IF NOT EXISTS ( -- column not exists (redcap_data_access_group)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'redcap_data_access_group'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD redcap_data_access_group varchar;   -- Function as dataset filter by stations (varchar)
        END IF; -- column (redcap_data_access_group)

        IF NOT EXISTS ( -- column not exists (db_filter_6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'db_filter_6'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD db_filter_6 double precision;   -- Dashboard Filter 6 (double precision)
        END IF; -- column (db_filter_6)

        IF NOT EXISTS ( -- column not exists (mrp_anlage)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_anlage'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_anlage varchar;   -- Formular angelegt von (varchar)
        END IF; -- column (mrp_anlage)

        IF NOT EXISTS ( -- column not exists (mrp_edit)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_edit'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_edit varchar;   -- Formular zuletzt bearbeitet von (varchar)
        END IF; -- column (mrp_edit)

        IF NOT EXISTS ( -- column not exists (mrp_meda_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_meda_id'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_meda_id varchar;   -- 2 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu MRP   Auswahlfeld falls die aktuell dokumentiertes MRP  sich nicht auf die letzte Instanz der Medikationsanalyse bezieht.   (varchar)
        END IF; -- column (mrp_meda_id)

        IF NOT EXISTS ( -- column not exists (mrp_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_id'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_id varchar;   -- MRP-ID (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse und der Instanz des aktuellen MRP aggregiert (varchar)
        END IF; -- column (mrp_id)

        IF NOT EXISTS ( -- column not exists (mrp_entd_dat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_entd_dat'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_entd_dat timestamp;   -- Datum des MRP (timestamp)
        END IF; -- column (mrp_entd_dat)

        IF NOT EXISTS ( -- column not exists (mrp_entd_algorithmisch)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_entd_algorithmisch'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_entd_algorithmisch varchar;   -- MRP vom INTERPOLAR-Algorithmus entdeckt? (varchar)
        END IF; -- column (mrp_entd_algorithmisch)

        IF NOT EXISTS ( -- column not exists (mrp_kurzbeschr)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_kurzbeschr'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_kurzbeschr varchar;   -- Kurzbeschreibung des MRPs* (varchar)
        END IF; -- column (mrp_kurzbeschr)

        IF NOT EXISTS ( -- column not exists (mrp_hinweisgeber)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_hinweisgeber'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_hinweisgeber varchar;   -- Hinweisgeber auf das MRP (varchar)
        END IF; -- column (mrp_hinweisgeber)

        IF NOT EXISTS ( -- column not exists (mrp_hinweisgeber_oth)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_hinweisgeber_oth'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_hinweisgeber_oth varchar;   -- Anderer Hinweisgeber (varchar)
        END IF; -- column (mrp_hinweisgeber_oth)

        IF NOT EXISTS ( -- column not exists (mrp_wirkstoff)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_wirkstoff'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_wirkstoff varchar;   -- Wirkstoff betroffen? (varchar)
        END IF; -- column (mrp_wirkstoff)

        IF NOT EXISTS ( -- column not exists (mrp_atc1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_atc1'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_atc1 varchar;   -- 1. Medikament ATC / Name: (varchar)
        END IF; -- column (mrp_atc1)

        IF NOT EXISTS ( -- column not exists (mrp_atc2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_atc2'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_atc2 varchar;   -- 2. Medikament ATC / Name (varchar)
        END IF; -- column (mrp_atc2)

        IF NOT EXISTS ( -- column not exists (mrp_atc3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_atc3'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_atc3 varchar;   -- 3. Medikament ATC / Name (varchar)
        END IF; -- column (mrp_atc3)

        IF NOT EXISTS ( -- column not exists (mrp_atc4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_atc4'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_atc4 varchar;   -- 4. Medikament ATC / Name (varchar)
        END IF; -- column (mrp_atc4)

        IF NOT EXISTS ( -- column not exists (mrp_atc5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_atc5'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_atc5 varchar;   -- 5. Medikament ATC / Name (varchar)
        END IF; -- column (mrp_atc5)

        IF NOT EXISTS ( -- column not exists (mrp_med_prod)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_med_prod'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_med_prod varchar;   -- Medizinprodukt betroffen? (varchar)
        END IF; -- column (mrp_med_prod)

        IF NOT EXISTS ( -- column not exists (mrp_med_prod_sonst)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_med_prod_sonst'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_med_prod_sonst varchar;   -- Bezeichnung Präparat (varchar)
        END IF; -- column (mrp_med_prod_sonst)

        IF NOT EXISTS ( -- column not exists (mrp_dokup_fehler)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_dokup_fehler'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_dokup_fehler varchar;   -- Frage / Fehlerbeschreibung  (varchar)
        END IF; -- column (mrp_dokup_fehler)

        IF NOT EXISTS ( -- column not exists (mrp_dokup_intervention)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_dokup_intervention'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_dokup_intervention varchar;   -- Intervention / Vorschlag zur Fehlervermeldung (varchar)
        END IF; -- column (mrp_dokup_intervention)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___1'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___1 varchar;   -- 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)
        END IF; -- column (mrp_pigrund___1)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___2'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___2 varchar;   -- 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)
        END IF; -- column (mrp_pigrund___2)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___3'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___3 varchar;   -- 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)
        END IF; -- column (mrp_pigrund___3)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___4'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___4 varchar;   -- 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)
        END IF; -- column (mrp_pigrund___4)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___5'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___5 varchar;   -- 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)
        END IF; -- column (mrp_pigrund___5)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___6'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___6 varchar;   -- 6 - AM: Übertragungsfehler (MF) (varchar)
        END IF; -- column (mrp_pigrund___6)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___7'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___7 varchar;   -- 7 - AM: Substitution aut idem/aut simile (MF) (varchar)
        END IF; -- column (mrp_pigrund___7)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___8'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___8 varchar;   -- 8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (varchar)
        END IF; -- column (mrp_pigrund___8)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___9)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___9'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___9 varchar;   -- 9 - AM: Stellfehler (MF) (varchar)
        END IF; -- column (mrp_pigrund___9)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___10)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___10'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___10 varchar;   -- 10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (varchar)
        END IF; -- column (mrp_pigrund___10)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___11)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___11'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___11 varchar;   -- 11 - AM: Doppelverordnung (MF) (varchar)
        END IF; -- column (mrp_pigrund___11)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___12)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___12'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___12 varchar;   -- 12 - ANW: Applikation (Dauer) (MF) (varchar)
        END IF; -- column (mrp_pigrund___12)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___13)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___13'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___13 varchar;   -- 13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (varchar)
        END IF; -- column (mrp_pigrund___13)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___14)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___14'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___14 varchar;   -- 14 - ANW: Applikation (Art) (MF) (varchar)
        END IF; -- column (mrp_pigrund___14)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___15)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___15'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___15 varchar;   -- 15 - ANW: Anfrage zur Administration/Kompatibilität (varchar)
        END IF; -- column (mrp_pigrund___15)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___16)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___16'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___16 varchar;   -- 16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (varchar)
        END IF; -- column (mrp_pigrund___16)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___17)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___17'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___17 varchar;   -- 17 - D: (Fehlerhafte) Dosis (MF) (varchar)
        END IF; -- column (mrp_pigrund___17)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___18)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___18'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___18 varchar;   -- 18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (varchar)
        END IF; -- column (mrp_pigrund___18)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___19)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___19'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___19 varchar;   -- 19 - D: (Fehlerhaftes) Dosisinterval (MF) (varchar)
        END IF; -- column (mrp_pigrund___19)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___20)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___20'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___20 varchar;   -- 20 - Interaktion (MF) (varchar)
        END IF; -- column (mrp_pigrund___20)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___21)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___21'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___21 varchar;   -- 21 - Kontraindikation (MF) (varchar)
        END IF; -- column (mrp_pigrund___21)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___22)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___22'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___22 varchar;   -- 22 - Nebenwirkungen (varchar)
        END IF; -- column (mrp_pigrund___22)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___23)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___23'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___23 varchar;   -- 23 - S: Beratung/Auswahl eines Arzneistoffs (varchar)
        END IF; -- column (mrp_pigrund___23)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___24)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___24'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___24 varchar;   -- 24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (varchar)
        END IF; -- column (mrp_pigrund___24)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___25)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___25'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___25 varchar;   -- 25 - S: Beschaffung/Kosten (varchar)
        END IF; -- column (mrp_pigrund___25)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___26)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___26'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___26 varchar;   -- 26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (varchar)
        END IF; -- column (mrp_pigrund___26)

        IF NOT EXISTS ( -- column not exists (mrp_pigrund___27)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_pigrund___27'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_pigrund___27 varchar;   -- 27 - S: Schulung/Beratung eines Patienten (varchar)
        END IF; -- column (mrp_pigrund___27)

        IF NOT EXISTS ( -- column not exists (mrp_ip_klasse)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_ip_klasse'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_ip_klasse varchar;   -- MRP-Klasse (INTERPOLAR) (varchar)
        END IF; -- column (mrp_ip_klasse)

        IF NOT EXISTS ( -- column not exists (mrp_ip_klasse_01)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_ip_klasse_01'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_ip_klasse_01 varchar;   -- MRP-Klasse (INTERPOLAR) (varchar)
        END IF; -- column (mrp_ip_klasse_01)

        IF NOT EXISTS ( -- column not exists (mrp_ip_klasse_disease)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_ip_klasse_disease'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_ip_klasse_disease varchar;   -- Disease (varchar)
        END IF; -- column (mrp_ip_klasse_disease)

        IF NOT EXISTS ( -- column not exists (mrp_ip_klasse_labor)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_ip_klasse_labor'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_ip_klasse_labor varchar;   -- Labor (varchar)
        END IF; -- column (mrp_ip_klasse_labor)

        IF NOT EXISTS ( -- column not exists (mrp_ip_klasse_nieren_insuf)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_ip_klasse_nieren_insuf'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_ip_klasse_nieren_insuf varchar;   -- Grad der Nierenfunktionseinschränkung (varchar)
        END IF; -- column (mrp_ip_klasse_nieren_insuf)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___1'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___1 varchar;   -- 1 - Anweisung für die Applikation geben (varchar)
        END IF; -- column (mrp_massn_am___1)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___2'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___2 varchar;   -- 2 - Arzneimittel ändern (varchar)
        END IF; -- column (mrp_massn_am___2)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___3'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___3 varchar;   -- 3 - Arzneimittel stoppen/pausieren (varchar)
        END IF; -- column (mrp_massn_am___3)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___4'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___4 varchar;   -- 4 - Arzneimittel neu ansetzen (varchar)
        END IF; -- column (mrp_massn_am___4)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___5'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___5 varchar;   -- 5 - Dosierung ändern (varchar)
        END IF; -- column (mrp_massn_am___5)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___6'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___6 varchar;   -- 6 - Formulierung ändern (varchar)
        END IF; -- column (mrp_massn_am___6)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___7'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___7 varchar;   -- 7 - Hilfe bei Beschaffung (varchar)
        END IF; -- column (mrp_massn_am___7)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___8'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___8 varchar;   -- 8 - Information an Arzt/Pflege (varchar)
        END IF; -- column (mrp_massn_am___8)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___9)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___9'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___9 varchar;   -- 9 - Information an Patient (varchar)
        END IF; -- column (mrp_massn_am___9)

        IF NOT EXISTS ( -- column not exists (mrp_massn_am___10)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_am___10'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_am___10 varchar;   -- 10 - TDM oder Laborkontrolle emfohlen (varchar)
        END IF; -- column (mrp_massn_am___10)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___1'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___1 varchar;   -- 1 - Aushändigung einer Information/eines Medikationsplans (varchar)
        END IF; -- column (mrp_massn_orga___1)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___2'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___2 varchar;   -- 2 - CIRS-/AMK-Meldung (varchar)
        END IF; -- column (mrp_massn_orga___2)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___3'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___3 varchar;   -- 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)
        END IF; -- column (mrp_massn_orga___3)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___4'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___4 varchar;   -- 4 - Etablierung einer Doppelkontrolle (varchar)
        END IF; -- column (mrp_massn_orga___4)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___5'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___5 varchar;   -- 5 - Lieferantenwechsel (varchar)
        END IF; -- column (mrp_massn_orga___5)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___6'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___6 varchar;   -- 6 - Optimierung der internen und externene Kommunikation (varchar)
        END IF; -- column (mrp_massn_orga___6)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___7'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___7 varchar;   -- 7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)
        END IF; -- column (mrp_massn_orga___7)

        IF NOT EXISTS ( -- column not exists (mrp_massn_orga___8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_massn_orga___8'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_massn_orga___8 varchar;   -- 8 - Sensibilisierung/Schulung (varchar)
        END IF; -- column (mrp_massn_orga___8)

        IF NOT EXISTS ( -- column not exists (mrp_notiz)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_notiz'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_notiz varchar;   -- Notiz (varchar)
        END IF; -- column (mrp_notiz)

        IF NOT EXISTS ( -- column not exists (mrp_dokup_hand_emp_akz)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_dokup_hand_emp_akz'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_dokup_hand_emp_akz varchar;   -- Handlungsempfehlung akzeptiert? (varchar)
        END IF; -- column (mrp_dokup_hand_emp_akz)

        IF NOT EXISTS ( -- column not exists (mrp_merp)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_merp'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_merp varchar;   -- NCC MERP Score (varchar)
        END IF; -- column (mrp_merp)

        IF NOT EXISTS ( -- column not exists (mrp_merp_info___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_merp_info___1'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_merp_info___1 varchar;   -- 1 - NCC MERP Index anzeigen (varchar)
        END IF; -- column (mrp_merp_info___1)

        IF NOT EXISTS ( -- column not exists (mrp_additional_values)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrp_additional_values'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrp_additional_values varchar;   -- Reserviertes Feld für zusätzliche Werte (varchar)
        END IF; -- column (mrp_additional_values)

        IF NOT EXISTS ( -- column not exists (mrpdokumentation_validierung_complete)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrpdokumentation_validierung_complete'
        ) THEN
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD mrpdokumentation_validierung_complete varchar;   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
        END IF; -- column (mrpdokumentation_validierung_complete)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(record_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instance), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_data_access_group), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(db_filter_6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_anlage), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_edit), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_meda_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_entd_dat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_entd_algorithmisch), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_kurzbeschr), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_hinweisgeber), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_hinweisgeber_oth), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_wirkstoff), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_atc1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_atc2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_atc3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_atc4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_atc5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_med_prod), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_med_prod_sonst), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_dokup_fehler), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_dokup_intervention), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___9), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___10), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___11), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___12), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___13), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___14), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___15), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___16), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___17), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___18), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___19), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___20), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___21), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___22), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___23), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___24), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___25), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___26), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_pigrund___27), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_ip_klasse), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_ip_klasse_01), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_ip_klasse_disease), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_ip_klasse_labor), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_ip_klasse_nieren_insuf), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___9), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_am___10), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_massn_orga___8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_notiz), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_dokup_hand_emp_akz), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_merp), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_merp_info___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrp_additional_values), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(mrpdokumentation_validierung_complete), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.mrpdokumentation_validierung_fe DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(db_filter_6), '#NULL#') || '|||' || -- hash from: Dashboard Filter 6 (db_filter_6)
          COALESCE(db.to_char_immutable(mrp_anlage), '#NULL#') || '|||' || -- hash from: Formular angelegt von (mrp_anlage)
          COALESCE(db.to_char_immutable(mrp_edit), '#NULL#') || '|||' || -- hash from: Formular zuletzt bearbeitet von (mrp_edit)
          COALESCE(db.to_char_immutable(mrp_meda_id), '#NULL#') || '|||' || -- hash from: 2 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu MRP   Auswahlfeld falls die aktuell dokumentiertes MRP  sich nicht auf die letzte Instanz der Medikationsanalyse bezieht.   (mrp_meda_id)
          COALESCE(db.to_char_immutable(mrp_id), '#NULL#') || '|||' || -- hash from: MRP-ID (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse und der Instanz des aktuellen MRP aggregiert (mrp_id)
          COALESCE(db.to_char_immutable(mrp_entd_dat), '#NULL#') || '|||' || -- hash from: Datum des MRP (mrp_entd_dat)
          COALESCE(db.to_char_immutable(mrp_entd_algorithmisch), '#NULL#') || '|||' || -- hash from: MRP vom INTERPOLAR-Algorithmus entdeckt? (mrp_entd_algorithmisch)
          COALESCE(db.to_char_immutable(mrp_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs* (mrp_kurzbeschr)
          COALESCE(db.to_char_immutable(mrp_hinweisgeber), '#NULL#') || '|||' || -- hash from: Hinweisgeber auf das MRP (mrp_hinweisgeber)
          COALESCE(db.to_char_immutable(mrp_hinweisgeber_oth), '#NULL#') || '|||' || -- hash from: Anderer Hinweisgeber (mrp_hinweisgeber_oth)
          COALESCE(db.to_char_immutable(mrp_wirkstoff), '#NULL#') || '|||' || -- hash from: Wirkstoff betroffen? (mrp_wirkstoff)
          COALESCE(db.to_char_immutable(mrp_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name: (mrp_atc1)
          COALESCE(db.to_char_immutable(mrp_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (mrp_atc2)
          COALESCE(db.to_char_immutable(mrp_atc3), '#NULL#') || '|||' || -- hash from: 3. Medikament ATC / Name (mrp_atc3)
          COALESCE(db.to_char_immutable(mrp_atc4), '#NULL#') || '|||' || -- hash from: 4. Medikament ATC / Name (mrp_atc4)
          COALESCE(db.to_char_immutable(mrp_atc5), '#NULL#') || '|||' || -- hash from: 5. Medikament ATC / Name (mrp_atc5)
          COALESCE(db.to_char_immutable(mrp_med_prod), '#NULL#') || '|||' || -- hash from: Medizinprodukt betroffen? (mrp_med_prod)
          COALESCE(db.to_char_immutable(mrp_med_prod_sonst), '#NULL#') || '|||' || -- hash from: Bezeichnung Präparat (mrp_med_prod_sonst)
          COALESCE(db.to_char_immutable(mrp_dokup_fehler), '#NULL#') || '|||' || -- hash from: Frage / Fehlerbeschreibung  (mrp_dokup_fehler)
          COALESCE(db.to_char_immutable(mrp_dokup_intervention), '#NULL#') || '|||' || -- hash from: Intervention / Vorschlag zur Fehlervermeldung (mrp_dokup_intervention)
          COALESCE(db.to_char_immutable(mrp_pigrund___1), '#NULL#') || '|||' || -- hash from: 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (mrp_pigrund___1)
          COALESCE(db.to_char_immutable(mrp_pigrund___2), '#NULL#') || '|||' || -- hash from: 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (mrp_pigrund___2)
          COALESCE(db.to_char_immutable(mrp_pigrund___3), '#NULL#') || '|||' || -- hash from: 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (mrp_pigrund___3)
          COALESCE(db.to_char_immutable(mrp_pigrund___4), '#NULL#') || '|||' || -- hash from: 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (mrp_pigrund___4)
          COALESCE(db.to_char_immutable(mrp_pigrund___5), '#NULL#') || '|||' || -- hash from: 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (mrp_pigrund___5)
          COALESCE(db.to_char_immutable(mrp_pigrund___6), '#NULL#') || '|||' || -- hash from: 6 - AM: Übertragungsfehler (MF) (mrp_pigrund___6)
          COALESCE(db.to_char_immutable(mrp_pigrund___7), '#NULL#') || '|||' || -- hash from: 7 - AM: Substitution aut idem/aut simile (MF) (mrp_pigrund___7)
          COALESCE(db.to_char_immutable(mrp_pigrund___8), '#NULL#') || '|||' || -- hash from: 8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (mrp_pigrund___8)
          COALESCE(db.to_char_immutable(mrp_pigrund___9), '#NULL#') || '|||' || -- hash from: 9 - AM: Stellfehler (MF) (mrp_pigrund___9)
          COALESCE(db.to_char_immutable(mrp_pigrund___10), '#NULL#') || '|||' || -- hash from: 10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (mrp_pigrund___10)
          COALESCE(db.to_char_immutable(mrp_pigrund___11), '#NULL#') || '|||' || -- hash from: 11 - AM: Doppelverordnung (MF) (mrp_pigrund___11)
          COALESCE(db.to_char_immutable(mrp_pigrund___12), '#NULL#') || '|||' || -- hash from: 12 - ANW: Applikation (Dauer) (MF) (mrp_pigrund___12)
          COALESCE(db.to_char_immutable(mrp_pigrund___13), '#NULL#') || '|||' || -- hash from: 13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (mrp_pigrund___13)
          COALESCE(db.to_char_immutable(mrp_pigrund___14), '#NULL#') || '|||' || -- hash from: 14 - ANW: Applikation (Art) (MF) (mrp_pigrund___14)
          COALESCE(db.to_char_immutable(mrp_pigrund___15), '#NULL#') || '|||' || -- hash from: 15 - ANW: Anfrage zur Administration/Kompatibilität (mrp_pigrund___15)
          COALESCE(db.to_char_immutable(mrp_pigrund___16), '#NULL#') || '|||' || -- hash from: 16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (mrp_pigrund___16)
          COALESCE(db.to_char_immutable(mrp_pigrund___17), '#NULL#') || '|||' || -- hash from: 17 - D: (Fehlerhafte) Dosis (MF) (mrp_pigrund___17)
          COALESCE(db.to_char_immutable(mrp_pigrund___18), '#NULL#') || '|||' || -- hash from: 18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (mrp_pigrund___18)
          COALESCE(db.to_char_immutable(mrp_pigrund___19), '#NULL#') || '|||' || -- hash from: 19 - D: (Fehlerhaftes) Dosisinterval (MF) (mrp_pigrund___19)
          COALESCE(db.to_char_immutable(mrp_pigrund___20), '#NULL#') || '|||' || -- hash from: 20 - Interaktion (MF) (mrp_pigrund___20)
          COALESCE(db.to_char_immutable(mrp_pigrund___21), '#NULL#') || '|||' || -- hash from: 21 - Kontraindikation (MF) (mrp_pigrund___21)
          COALESCE(db.to_char_immutable(mrp_pigrund___22), '#NULL#') || '|||' || -- hash from: 22 - Nebenwirkungen (mrp_pigrund___22)
          COALESCE(db.to_char_immutable(mrp_pigrund___23), '#NULL#') || '|||' || -- hash from: 23 - S: Beratung/Auswahl eines Arzneistoffs (mrp_pigrund___23)
          COALESCE(db.to_char_immutable(mrp_pigrund___24), '#NULL#') || '|||' || -- hash from: 24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (mrp_pigrund___24)
          COALESCE(db.to_char_immutable(mrp_pigrund___25), '#NULL#') || '|||' || -- hash from: 25 - S: Beschaffung/Kosten (mrp_pigrund___25)
          COALESCE(db.to_char_immutable(mrp_pigrund___26), '#NULL#') || '|||' || -- hash from: 26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (mrp_pigrund___26)
          COALESCE(db.to_char_immutable(mrp_pigrund___27), '#NULL#') || '|||' || -- hash from: 27 - S: Schulung/Beratung eines Patienten (mrp_pigrund___27)
          COALESCE(db.to_char_immutable(mrp_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (mrp_ip_klasse)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_01), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (mrp_ip_klasse_01)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (mrp_ip_klasse_disease)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (mrp_ip_klasse_labor)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_nieren_insuf), '#NULL#') || '|||' || -- hash from: Grad der Nierenfunktionseinschränkung (mrp_ip_klasse_nieren_insuf)
          COALESCE(db.to_char_immutable(mrp_massn_am___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (mrp_massn_am___1)
          COALESCE(db.to_char_immutable(mrp_massn_am___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (mrp_massn_am___2)
          COALESCE(db.to_char_immutable(mrp_massn_am___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (mrp_massn_am___3)
          COALESCE(db.to_char_immutable(mrp_massn_am___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (mrp_massn_am___4)
          COALESCE(db.to_char_immutable(mrp_massn_am___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (mrp_massn_am___5)
          COALESCE(db.to_char_immutable(mrp_massn_am___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (mrp_massn_am___6)
          COALESCE(db.to_char_immutable(mrp_massn_am___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (mrp_massn_am___7)
          COALESCE(db.to_char_immutable(mrp_massn_am___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (mrp_massn_am___8)
          COALESCE(db.to_char_immutable(mrp_massn_am___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (mrp_massn_am___9)
          COALESCE(db.to_char_immutable(mrp_massn_am___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (mrp_massn_am___10)
          COALESCE(db.to_char_immutable(mrp_massn_orga___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (mrp_massn_orga___1)
          COALESCE(db.to_char_immutable(mrp_massn_orga___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (mrp_massn_orga___2)
          COALESCE(db.to_char_immutable(mrp_massn_orga___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (mrp_massn_orga___3)
          COALESCE(db.to_char_immutable(mrp_massn_orga___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (mrp_massn_orga___4)
          COALESCE(db.to_char_immutable(mrp_massn_orga___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (mrp_massn_orga___5)
          COALESCE(db.to_char_immutable(mrp_massn_orga___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (mrp_massn_orga___6)
          COALESCE(db.to_char_immutable(mrp_massn_orga___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (mrp_massn_orga___7)
          COALESCE(db.to_char_immutable(mrp_massn_orga___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (mrp_massn_orga___8)
          COALESCE(db.to_char_immutable(mrp_notiz), '#NULL#') || '|||' || -- hash from: Notiz (mrp_notiz)
          COALESCE(db.to_char_immutable(mrp_dokup_hand_emp_akz), '#NULL#') || '|||' || -- hash from: Handlungsempfehlung akzeptiert? (mrp_dokup_hand_emp_akz)
          COALESCE(db.to_char_immutable(mrp_merp), '#NULL#') || '|||' || -- hash from: NCC MERP Score (mrp_merp)
          COALESCE(db.to_char_immutable(mrp_merp_info___1), '#NULL#') || '|||' || -- hash from: 1 - NCC MERP Index anzeigen (mrp_merp_info___1)
          COALESCE(db.to_char_immutable(mrp_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (mrp_additional_values)
          COALESCE(db.to_char_immutable(mrpdokumentation_validierung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (mrpdokumentation_validierung_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.mrpdokumentation_validierung_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(db_filter_6), '#NULL#') || '|||' || -- hash from: Dashboard Filter 6 (db_filter_6)
          COALESCE(db.to_char_immutable(mrp_anlage), '#NULL#') || '|||' || -- hash from: Formular angelegt von (mrp_anlage)
          COALESCE(db.to_char_immutable(mrp_edit), '#NULL#') || '|||' || -- hash from: Formular zuletzt bearbeitet von (mrp_edit)
          COALESCE(db.to_char_immutable(mrp_meda_id), '#NULL#') || '|||' || -- hash from: 2 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu MRP   Auswahlfeld falls die aktuell dokumentiertes MRP  sich nicht auf die letzte Instanz der Medikationsanalyse bezieht.   (mrp_meda_id)
          COALESCE(db.to_char_immutable(mrp_id), '#NULL#') || '|||' || -- hash from: MRP-ID (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse und der Instanz des aktuellen MRP aggregiert (mrp_id)
          COALESCE(db.to_char_immutable(mrp_entd_dat), '#NULL#') || '|||' || -- hash from: Datum des MRP (mrp_entd_dat)
          COALESCE(db.to_char_immutable(mrp_entd_algorithmisch), '#NULL#') || '|||' || -- hash from: MRP vom INTERPOLAR-Algorithmus entdeckt? (mrp_entd_algorithmisch)
          COALESCE(db.to_char_immutable(mrp_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs* (mrp_kurzbeschr)
          COALESCE(db.to_char_immutable(mrp_hinweisgeber), '#NULL#') || '|||' || -- hash from: Hinweisgeber auf das MRP (mrp_hinweisgeber)
          COALESCE(db.to_char_immutable(mrp_hinweisgeber_oth), '#NULL#') || '|||' || -- hash from: Anderer Hinweisgeber (mrp_hinweisgeber_oth)
          COALESCE(db.to_char_immutable(mrp_wirkstoff), '#NULL#') || '|||' || -- hash from: Wirkstoff betroffen? (mrp_wirkstoff)
          COALESCE(db.to_char_immutable(mrp_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name: (mrp_atc1)
          COALESCE(db.to_char_immutable(mrp_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (mrp_atc2)
          COALESCE(db.to_char_immutable(mrp_atc3), '#NULL#') || '|||' || -- hash from: 3. Medikament ATC / Name (mrp_atc3)
          COALESCE(db.to_char_immutable(mrp_atc4), '#NULL#') || '|||' || -- hash from: 4. Medikament ATC / Name (mrp_atc4)
          COALESCE(db.to_char_immutable(mrp_atc5), '#NULL#') || '|||' || -- hash from: 5. Medikament ATC / Name (mrp_atc5)
          COALESCE(db.to_char_immutable(mrp_med_prod), '#NULL#') || '|||' || -- hash from: Medizinprodukt betroffen? (mrp_med_prod)
          COALESCE(db.to_char_immutable(mrp_med_prod_sonst), '#NULL#') || '|||' || -- hash from: Bezeichnung Präparat (mrp_med_prod_sonst)
          COALESCE(db.to_char_immutable(mrp_dokup_fehler), '#NULL#') || '|||' || -- hash from: Frage / Fehlerbeschreibung  (mrp_dokup_fehler)
          COALESCE(db.to_char_immutable(mrp_dokup_intervention), '#NULL#') || '|||' || -- hash from: Intervention / Vorschlag zur Fehlervermeldung (mrp_dokup_intervention)
          COALESCE(db.to_char_immutable(mrp_pigrund___1), '#NULL#') || '|||' || -- hash from: 1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (mrp_pigrund___1)
          COALESCE(db.to_char_immutable(mrp_pigrund___2), '#NULL#') || '|||' || -- hash from: 2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (mrp_pigrund___2)
          COALESCE(db.to_char_immutable(mrp_pigrund___3), '#NULL#') || '|||' || -- hash from: 3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (mrp_pigrund___3)
          COALESCE(db.to_char_immutable(mrp_pigrund___4), '#NULL#') || '|||' || -- hash from: 4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (mrp_pigrund___4)
          COALESCE(db.to_char_immutable(mrp_pigrund___5), '#NULL#') || '|||' || -- hash from: 5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (mrp_pigrund___5)
          COALESCE(db.to_char_immutable(mrp_pigrund___6), '#NULL#') || '|||' || -- hash from: 6 - AM: Übertragungsfehler (MF) (mrp_pigrund___6)
          COALESCE(db.to_char_immutable(mrp_pigrund___7), '#NULL#') || '|||' || -- hash from: 7 - AM: Substitution aut idem/aut simile (MF) (mrp_pigrund___7)
          COALESCE(db.to_char_immutable(mrp_pigrund___8), '#NULL#') || '|||' || -- hash from: 8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (mrp_pigrund___8)
          COALESCE(db.to_char_immutable(mrp_pigrund___9), '#NULL#') || '|||' || -- hash from: 9 - AM: Stellfehler (MF) (mrp_pigrund___9)
          COALESCE(db.to_char_immutable(mrp_pigrund___10), '#NULL#') || '|||' || -- hash from: 10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (mrp_pigrund___10)
          COALESCE(db.to_char_immutable(mrp_pigrund___11), '#NULL#') || '|||' || -- hash from: 11 - AM: Doppelverordnung (MF) (mrp_pigrund___11)
          COALESCE(db.to_char_immutable(mrp_pigrund___12), '#NULL#') || '|||' || -- hash from: 12 - ANW: Applikation (Dauer) (MF) (mrp_pigrund___12)
          COALESCE(db.to_char_immutable(mrp_pigrund___13), '#NULL#') || '|||' || -- hash from: 13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (mrp_pigrund___13)
          COALESCE(db.to_char_immutable(mrp_pigrund___14), '#NULL#') || '|||' || -- hash from: 14 - ANW: Applikation (Art) (MF) (mrp_pigrund___14)
          COALESCE(db.to_char_immutable(mrp_pigrund___15), '#NULL#') || '|||' || -- hash from: 15 - ANW: Anfrage zur Administration/Kompatibilität (mrp_pigrund___15)
          COALESCE(db.to_char_immutable(mrp_pigrund___16), '#NULL#') || '|||' || -- hash from: 16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (mrp_pigrund___16)
          COALESCE(db.to_char_immutable(mrp_pigrund___17), '#NULL#') || '|||' || -- hash from: 17 - D: (Fehlerhafte) Dosis (MF) (mrp_pigrund___17)
          COALESCE(db.to_char_immutable(mrp_pigrund___18), '#NULL#') || '|||' || -- hash from: 18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (mrp_pigrund___18)
          COALESCE(db.to_char_immutable(mrp_pigrund___19), '#NULL#') || '|||' || -- hash from: 19 - D: (Fehlerhaftes) Dosisinterval (MF) (mrp_pigrund___19)
          COALESCE(db.to_char_immutable(mrp_pigrund___20), '#NULL#') || '|||' || -- hash from: 20 - Interaktion (MF) (mrp_pigrund___20)
          COALESCE(db.to_char_immutable(mrp_pigrund___21), '#NULL#') || '|||' || -- hash from: 21 - Kontraindikation (MF) (mrp_pigrund___21)
          COALESCE(db.to_char_immutable(mrp_pigrund___22), '#NULL#') || '|||' || -- hash from: 22 - Nebenwirkungen (mrp_pigrund___22)
          COALESCE(db.to_char_immutable(mrp_pigrund___23), '#NULL#') || '|||' || -- hash from: 23 - S: Beratung/Auswahl eines Arzneistoffs (mrp_pigrund___23)
          COALESCE(db.to_char_immutable(mrp_pigrund___24), '#NULL#') || '|||' || -- hash from: 24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (mrp_pigrund___24)
          COALESCE(db.to_char_immutable(mrp_pigrund___25), '#NULL#') || '|||' || -- hash from: 25 - S: Beschaffung/Kosten (mrp_pigrund___25)
          COALESCE(db.to_char_immutable(mrp_pigrund___26), '#NULL#') || '|||' || -- hash from: 26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (mrp_pigrund___26)
          COALESCE(db.to_char_immutable(mrp_pigrund___27), '#NULL#') || '|||' || -- hash from: 27 - S: Schulung/Beratung eines Patienten (mrp_pigrund___27)
          COALESCE(db.to_char_immutable(mrp_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (mrp_ip_klasse)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_01), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (mrp_ip_klasse_01)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (mrp_ip_klasse_disease)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (mrp_ip_klasse_labor)
          COALESCE(db.to_char_immutable(mrp_ip_klasse_nieren_insuf), '#NULL#') || '|||' || -- hash from: Grad der Nierenfunktionseinschränkung (mrp_ip_klasse_nieren_insuf)
          COALESCE(db.to_char_immutable(mrp_massn_am___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (mrp_massn_am___1)
          COALESCE(db.to_char_immutable(mrp_massn_am___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (mrp_massn_am___2)
          COALESCE(db.to_char_immutable(mrp_massn_am___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (mrp_massn_am___3)
          COALESCE(db.to_char_immutable(mrp_massn_am___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (mrp_massn_am___4)
          COALESCE(db.to_char_immutable(mrp_massn_am___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (mrp_massn_am___5)
          COALESCE(db.to_char_immutable(mrp_massn_am___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (mrp_massn_am___6)
          COALESCE(db.to_char_immutable(mrp_massn_am___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (mrp_massn_am___7)
          COALESCE(db.to_char_immutable(mrp_massn_am___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (mrp_massn_am___8)
          COALESCE(db.to_char_immutable(mrp_massn_am___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (mrp_massn_am___9)
          COALESCE(db.to_char_immutable(mrp_massn_am___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (mrp_massn_am___10)
          COALESCE(db.to_char_immutable(mrp_massn_orga___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (mrp_massn_orga___1)
          COALESCE(db.to_char_immutable(mrp_massn_orga___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (mrp_massn_orga___2)
          COALESCE(db.to_char_immutable(mrp_massn_orga___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (mrp_massn_orga___3)
          COALESCE(db.to_char_immutable(mrp_massn_orga___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (mrp_massn_orga___4)
          COALESCE(db.to_char_immutable(mrp_massn_orga___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (mrp_massn_orga___5)
          COALESCE(db.to_char_immutable(mrp_massn_orga___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (mrp_massn_orga___6)
          COALESCE(db.to_char_immutable(mrp_massn_orga___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (mrp_massn_orga___7)
          COALESCE(db.to_char_immutable(mrp_massn_orga___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (mrp_massn_orga___8)
          COALESCE(db.to_char_immutable(mrp_notiz), '#NULL#') || '|||' || -- hash from: Notiz (mrp_notiz)
          COALESCE(db.to_char_immutable(mrp_dokup_hand_emp_akz), '#NULL#') || '|||' || -- hash from: Handlungsempfehlung akzeptiert? (mrp_dokup_hand_emp_akz)
          COALESCE(db.to_char_immutable(mrp_merp), '#NULL#') || '|||' || -- hash from: NCC MERP Score (mrp_merp)
          COALESCE(db.to_char_immutable(mrp_merp_info___1), '#NULL#') || '|||' || -- hash from: 1 - NCC MERP Index anzeigen (mrp_merp_info___1)
          COALESCE(db.to_char_immutable(mrp_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (mrp_additional_values)
          COALESCE(db.to_char_immutable(mrpdokumentation_validierung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (mrpdokumentation_validierung_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
-- Table "retrolektive_mrpbewertung_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.retrolektive_mrpbewertung_fe (
  retrolektive_mrpbewertung_fe_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (record_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'record_id'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD record_id varchar;   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
        END IF; -- column (record_id)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instrument)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'redcap_repeat_instrument'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD redcap_repeat_instrument varchar;   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
        END IF; -- column (redcap_repeat_instrument)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instance)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'redcap_repeat_instance'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD redcap_repeat_instance varchar;   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
        END IF; -- column (redcap_repeat_instance)

        IF NOT EXISTS ( -- column not exists (redcap_data_access_group)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'redcap_data_access_group'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD redcap_data_access_group varchar;   -- Function as dataset filter by stations (varchar)
        END IF; -- column (redcap_data_access_group)

        IF NOT EXISTS ( -- column not exists (ret_bewerter1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_bewerter1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_bewerter1 varchar;   -- 1. Bewertung von (varchar)
        END IF; -- column (ret_bewerter1)

        IF NOT EXISTS ( -- column not exists (ret_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_id'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_id varchar;   -- Retrolektive MRP-ID (REDCap) Hier wird die vom Datenprozessor MEDA-ID-r-Instanz aggregiert. (varchar)
        END IF; -- column (ret_id)

        IF NOT EXISTS ( -- column not exists (ret_meda_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_meda_id'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_meda_id varchar;   -- Zuordnung Meda -> rMRP (varchar)
        END IF; -- column (ret_meda_id)

        IF NOT EXISTS ( -- column not exists (ret_meda_dat1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_meda_dat1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_meda_dat1 timestamp;   -- Datum der retrolektiven Betrachtung* (timestamp)
        END IF; -- column (ret_meda_dat1)

        IF NOT EXISTS ( -- column not exists (ret_kurzbeschr)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_kurzbeschr'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_kurzbeschr varchar;   -- Kurzbeschreibung des MRPs (varchar)
        END IF; -- column (ret_kurzbeschr)

        IF NOT EXISTS ( -- column not exists (ret_ip_klasse)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_ip_klasse'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_ip_klasse varchar;   -- MRP-Klasse (INTERPOLAR) (varchar)
        END IF; -- column (ret_ip_klasse)

        IF NOT EXISTS ( -- column not exists (ret_ip_klasse_01)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_ip_klasse_01'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_ip_klasse_01 varchar;   -- MRP-Klasse (INTERPOLAR) (varchar)
        END IF; -- column (ret_ip_klasse_01)

        IF NOT EXISTS ( -- column not exists (ret_atc1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_atc1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_atc1 varchar;   -- 1. Medikament ATC / Name: (varchar)
        END IF; -- column (ret_atc1)

        IF NOT EXISTS ( -- column not exists (ret_atc2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_atc2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_atc2 varchar;   -- 2. Medikament ATC / Name (varchar)
        END IF; -- column (ret_atc2)

        IF NOT EXISTS ( -- column not exists (ret_ip_klasse_disease)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_ip_klasse_disease'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_ip_klasse_disease varchar;   -- Disease (varchar)
        END IF; -- column (ret_ip_klasse_disease)

        IF NOT EXISTS ( -- column not exists (ret_ip_klasse_labor)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_ip_klasse_labor'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_ip_klasse_labor varchar;   -- Labor (varchar)
        END IF; -- column (ret_ip_klasse_labor)

        IF NOT EXISTS ( -- column not exists (ret_ip_klasse_nieren_insuf)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_ip_klasse_nieren_insuf'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_ip_klasse_nieren_insuf varchar;   -- Grad der Nierenfunktionseinschränkung (varchar)
        END IF; -- column (ret_ip_klasse_nieren_insuf)

        IF NOT EXISTS ( -- column not exists (ret_gewissheit1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewissheit1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewissheit1 varchar;   -- Sicherheit des detektierten MRP (varchar)
        END IF; -- column (ret_gewissheit1)

        IF NOT EXISTS ( -- column not exists (ret_mrp_zuordnung1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_mrp_zuordnung1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_mrp_zuordnung1 varchar;   -- Zuordnung zu manuellem MRP (varchar)
        END IF; -- column (ret_mrp_zuordnung1)

        IF NOT EXISTS ( -- column not exists (ret_gewissheit1_oth)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewissheit1_oth'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewissheit1_oth varchar;   -- Weitere Informationen (varchar)
        END IF; -- column (ret_gewissheit1_oth)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund1_abl)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund1_abl'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund1_abl varchar;   -- Grund für nicht Bestätigung (varchar)
        END IF; -- column (ret_gewiss_grund1_abl)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund_abl_sonst1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund_abl_sonst1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund_abl_sonst1 varchar;   -- Bitte näher beschreiben (varchar)
        END IF; -- column (ret_gewiss_grund_abl_sonst1)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund_abl_klin1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund_abl_klin1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund_abl_klin1 varchar;   -- WARUM ist das MRP nicht klinisch relevant (varchar)
        END IF; -- column (ret_gewiss_grund_abl_klin1)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund_abl_klin1_neg___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund_abl_klin1_neg___1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund_abl_klin1_neg___1 varchar;   -- 1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (varchar)
        END IF; -- column (ret_gewiss_grund_abl_klin1_neg___1)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___1 varchar;   -- 1 - Anweisung für die Applikation geben (varchar)
        END IF; -- column (ret_massn_am1___1)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___2 varchar;   -- 2 - Arzneimittel ändern (varchar)
        END IF; -- column (ret_massn_am1___2)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___3'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___3 varchar;   -- 3 - Arzneimittel stoppen/pausieren (varchar)
        END IF; -- column (ret_massn_am1___3)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___4'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___4 varchar;   -- 4 - Arzneimittel neu ansetzen (varchar)
        END IF; -- column (ret_massn_am1___4)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___5'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___5 varchar;   -- 5 - Dosierung ändern (varchar)
        END IF; -- column (ret_massn_am1___5)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___6'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___6 varchar;   -- 6 - Formulierung ändern (varchar)
        END IF; -- column (ret_massn_am1___6)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___7'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___7 varchar;   -- 7 - Hilfe bei Beschaffung (varchar)
        END IF; -- column (ret_massn_am1___7)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___8'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___8 varchar;   -- 8 - Information an Arzt/Pflege (varchar)
        END IF; -- column (ret_massn_am1___8)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___9)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___9'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___9 varchar;   -- 9 - Information an Patient (varchar)
        END IF; -- column (ret_massn_am1___9)

        IF NOT EXISTS ( -- column not exists (ret_massn_am1___10)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am1___10'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am1___10 varchar;   -- 10 - TDM oder Laborkontrolle emfohlen (varchar)
        END IF; -- column (ret_massn_am1___10)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___1 varchar;   -- 1 - Aushändigung einer Information/eines Medikationsplans (varchar)
        END IF; -- column (ret_massn_orga1___1)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___2 varchar;   -- 2 - CIRS-/AMK-Meldung (varchar)
        END IF; -- column (ret_massn_orga1___2)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___3'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___3 varchar;   -- 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)
        END IF; -- column (ret_massn_orga1___3)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___4'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___4 varchar;   -- 4 - Etablierung einer Doppelkontrolle (varchar)
        END IF; -- column (ret_massn_orga1___4)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___5'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___5 varchar;   -- 5 - Lieferantenwechsel (varchar)
        END IF; -- column (ret_massn_orga1___5)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___6'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___6 varchar;   -- 6 - Optimierung der internen und externene Kommunikation (varchar)
        END IF; -- column (ret_massn_orga1___6)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___7'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___7 varchar;   -- 7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)
        END IF; -- column (ret_massn_orga1___7)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga1___8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga1___8'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga1___8 varchar;   -- 8 - Sensibilisierung/Schulung (varchar)
        END IF; -- column (ret_massn_orga1___8)

        IF NOT EXISTS ( -- column not exists (ret_notiz1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_notiz1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_notiz1 varchar;   -- Notiz (varchar)
        END IF; -- column (ret_notiz1)

        IF NOT EXISTS ( -- column not exists (ret_meda_dat2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_meda_dat2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_meda_dat2 timestamp;   -- Datum der retrolektiven Betrachtung* (timestamp)
        END IF; -- column (ret_meda_dat2)

        IF NOT EXISTS ( -- column not exists (ret_2ndbewertung___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_2ndbewertung___1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_2ndbewertung___1 varchar;   -- 1 - 2nd Look / Zweite MRP-Bewertung durchführen (varchar)
        END IF; -- column (ret_2ndbewertung___1)

        IF NOT EXISTS ( -- column not exists (ret_bewerter2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_bewerter2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_bewerter2 varchar;   -- 2. Bewertung von (varchar)
        END IF; -- column (ret_bewerter2)

        IF NOT EXISTS ( -- column not exists (ret_bewerter3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_bewerter3'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_bewerter3 varchar;   --  (varchar)
        END IF; -- column (ret_bewerter3)

        IF NOT EXISTS ( -- column not exists (ret_bewerter2_pipeline)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_bewerter2_pipeline'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_bewerter2_pipeline varchar;   --  (varchar)
        END IF; -- column (ret_bewerter2_pipeline)

        IF NOT EXISTS ( -- column not exists (ret_gewissheit2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewissheit2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewissheit2 varchar;   -- Sicherheit des detektierten MRP (varchar)
        END IF; -- column (ret_gewissheit2)

        IF NOT EXISTS ( -- column not exists (ret_mrp_zuordnung2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_mrp_zuordnung2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_mrp_zuordnung2 varchar;   -- Zuordnung zu manuellem MRP (varchar)
        END IF; -- column (ret_mrp_zuordnung2)

        IF NOT EXISTS ( -- column not exists (ret_gewissheit2_oth)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewissheit2_oth'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewissheit2_oth varchar;   -- Weitere Informationen (varchar)
        END IF; -- column (ret_gewissheit2_oth)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund2_abl)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund2_abl'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund2_abl varchar;   -- Grund für nicht Bestätigung (varchar)
        END IF; -- column (ret_gewiss_grund2_abl)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund_abl_sonst2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund_abl_sonst2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund_abl_sonst2 varchar;   -- Bitte näher beschreiben (varchar)
        END IF; -- column (ret_gewiss_grund_abl_sonst2)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund_abl_klin2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund_abl_klin2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund_abl_klin2 varchar;   -- WARUM ist das MRP nicht klinisch relevant (varchar)
        END IF; -- column (ret_gewiss_grund_abl_klin2)

        IF NOT EXISTS ( -- column not exists (ret_gewiss_grund_abl_klin2_neg___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_gewiss_grund_abl_klin2_neg___1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_gewiss_grund_abl_klin2_neg___1 varchar;   -- 1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (varchar)
        END IF; -- column (ret_gewiss_grund_abl_klin2_neg___1)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___1 varchar;   -- 1 - Anweisung für die Applikation geben (varchar)
        END IF; -- column (ret_massn_am2___1)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___2 varchar;   -- 2 - Arzneimittel ändern (varchar)
        END IF; -- column (ret_massn_am2___2)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___3'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___3 varchar;   -- 3 - Arzneimittel stoppen/pausieren (varchar)
        END IF; -- column (ret_massn_am2___3)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___4'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___4 varchar;   -- 4 - Arzneimittel neu ansetzen (varchar)
        END IF; -- column (ret_massn_am2___4)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___5'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___5 varchar;   -- 5 - Dosierung ändern (varchar)
        END IF; -- column (ret_massn_am2___5)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___6'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___6 varchar;   -- 6 - Formulierung ändern (varchar)
        END IF; -- column (ret_massn_am2___6)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___7'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___7 varchar;   -- 7 - Hilfe bei Beschaffung (varchar)
        END IF; -- column (ret_massn_am2___7)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___8'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___8 varchar;   -- 8 - Information an Arzt/Pflege (varchar)
        END IF; -- column (ret_massn_am2___8)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___9)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___9'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___9 varchar;   -- 9 - Information an Patient (varchar)
        END IF; -- column (ret_massn_am2___9)

        IF NOT EXISTS ( -- column not exists (ret_massn_am2___10)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_am2___10'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_am2___10 varchar;   -- 10 - TDM oder Laborkontrolle emfohlen (varchar)
        END IF; -- column (ret_massn_am2___10)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___1)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___1'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___1 varchar;   -- 1 - Aushändigung einer Information/eines Medikationsplans (varchar)
        END IF; -- column (ret_massn_orga2___1)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___2 varchar;   -- 2 - CIRS-/AMK-Meldung (varchar)
        END IF; -- column (ret_massn_orga2___2)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___3)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___3'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___3 varchar;   -- 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)
        END IF; -- column (ret_massn_orga2___3)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___4)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___4'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___4 varchar;   -- 4 - Etablierung einer Doppelkontrolle (varchar)
        END IF; -- column (ret_massn_orga2___4)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___5)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___5'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___5 varchar;   -- 5 - Lieferantenwechsel (varchar)
        END IF; -- column (ret_massn_orga2___5)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___6)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___6'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___6 varchar;   -- 6 - Optimierung der internen und externene Kommunikation (varchar)
        END IF; -- column (ret_massn_orga2___6)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___7)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___7'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___7 varchar;   -- 7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)
        END IF; -- column (ret_massn_orga2___7)

        IF NOT EXISTS ( -- column not exists (ret_massn_orga2___8)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_massn_orga2___8'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_massn_orga2___8 varchar;   -- 8 - Sensibilisierung/Schulung (varchar)
        END IF; -- column (ret_massn_orga2___8)

        IF NOT EXISTS ( -- column not exists (ret_notiz2)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_notiz2'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_notiz2 varchar;   -- Notiz (varchar)
        END IF; -- column (ret_notiz2)

        IF NOT EXISTS ( -- column not exists (ret_additional_values)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'ret_additional_values'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD ret_additional_values varchar;   -- Reserviertes Feld für zusätzliche Werte (varchar)
        END IF; -- column (ret_additional_values)

        IF NOT EXISTS ( -- column not exists (retrolektive_mrpbewertung_complete)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'retrolektive_mrpbewertung_complete'
        ) THEN
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD retrolektive_mrpbewertung_complete varchar;   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
        END IF; -- column (retrolektive_mrpbewertung_complete)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(record_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instance), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_data_access_group), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_bewerter1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_meda_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_meda_dat1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_kurzbeschr), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_ip_klasse), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_ip_klasse_01), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_atc1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_atc2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_ip_klasse_disease), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_ip_klasse_labor), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_ip_klasse_nieren_insuf), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewissheit1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_mrp_zuordnung1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewissheit1_oth), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund1_abl), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin1_neg___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___9), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am1___10), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga1___8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_notiz1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_meda_dat2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_2ndbewertung___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_bewerter2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_bewerter3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_bewerter2_pipeline), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewissheit2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_mrp_zuordnung2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewissheit2_oth), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund2_abl), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin2_neg___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___9), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_am2___10), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___1), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___3), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___4), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___5), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___6), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___7), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_massn_orga2___8), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_notiz2), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(ret_additional_values), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(retrolektive_mrpbewertung_complete), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(ret_bewerter1), '#NULL#') || '|||' || -- hash from: 1. Bewertung von (ret_bewerter1)
          COALESCE(db.to_char_immutable(ret_id), '#NULL#') || '|||' || -- hash from: Retrolektive MRP-ID (REDCap) Hier wird die vom Datenprozessor MEDA-ID-r-Instanz aggregiert. (ret_id)
          COALESCE(db.to_char_immutable(ret_meda_id), '#NULL#') || '|||' || -- hash from: Zuordnung Meda -> rMRP (ret_meda_id)
          COALESCE(db.to_char_immutable(ret_meda_dat1), '#NULL#') || '|||' || -- hash from: Datum der retrolektiven Betrachtung* (ret_meda_dat1)
          COALESCE(db.to_char_immutable(ret_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs (ret_kurzbeschr)
          COALESCE(db.to_char_immutable(ret_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (ret_ip_klasse)
          COALESCE(db.to_char_immutable(ret_ip_klasse_01), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (ret_ip_klasse_01)
          COALESCE(db.to_char_immutable(ret_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name: (ret_atc1)
          COALESCE(db.to_char_immutable(ret_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (ret_atc2)
          COALESCE(db.to_char_immutable(ret_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (ret_ip_klasse_disease)
          COALESCE(db.to_char_immutable(ret_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (ret_ip_klasse_labor)
          COALESCE(db.to_char_immutable(ret_ip_klasse_nieren_insuf), '#NULL#') || '|||' || -- hash from: Grad der Nierenfunktionseinschränkung (ret_ip_klasse_nieren_insuf)
          COALESCE(db.to_char_immutable(ret_gewissheit1), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP (ret_gewissheit1)
          COALESCE(db.to_char_immutable(ret_mrp_zuordnung1), '#NULL#') || '|||' || -- hash from: Zuordnung zu manuellem MRP (ret_mrp_zuordnung1)
          COALESCE(db.to_char_immutable(ret_gewissheit1_oth), '#NULL#') || '|||' || -- hash from: Weitere Informationen (ret_gewissheit1_oth)
          COALESCE(db.to_char_immutable(ret_gewiss_grund1_abl), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung (ret_gewiss_grund1_abl)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst1), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (ret_gewiss_grund_abl_sonst1)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin1), '#NULL#') || '|||' || -- hash from: WARUM ist das MRP nicht klinisch relevant (ret_gewiss_grund_abl_klin1)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin1_neg___1), '#NULL#') || '|||' || -- hash from: 1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (ret_gewiss_grund_abl_klin1_neg___1)
          COALESCE(db.to_char_immutable(ret_massn_am1___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (ret_massn_am1___1)
          COALESCE(db.to_char_immutable(ret_massn_am1___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (ret_massn_am1___2)
          COALESCE(db.to_char_immutable(ret_massn_am1___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (ret_massn_am1___3)
          COALESCE(db.to_char_immutable(ret_massn_am1___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (ret_massn_am1___4)
          COALESCE(db.to_char_immutable(ret_massn_am1___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (ret_massn_am1___5)
          COALESCE(db.to_char_immutable(ret_massn_am1___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (ret_massn_am1___6)
          COALESCE(db.to_char_immutable(ret_massn_am1___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (ret_massn_am1___7)
          COALESCE(db.to_char_immutable(ret_massn_am1___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (ret_massn_am1___8)
          COALESCE(db.to_char_immutable(ret_massn_am1___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (ret_massn_am1___9)
          COALESCE(db.to_char_immutable(ret_massn_am1___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (ret_massn_am1___10)
          COALESCE(db.to_char_immutable(ret_massn_orga1___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (ret_massn_orga1___1)
          COALESCE(db.to_char_immutable(ret_massn_orga1___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (ret_massn_orga1___2)
          COALESCE(db.to_char_immutable(ret_massn_orga1___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (ret_massn_orga1___3)
          COALESCE(db.to_char_immutable(ret_massn_orga1___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (ret_massn_orga1___4)
          COALESCE(db.to_char_immutable(ret_massn_orga1___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (ret_massn_orga1___5)
          COALESCE(db.to_char_immutable(ret_massn_orga1___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (ret_massn_orga1___6)
          COALESCE(db.to_char_immutable(ret_massn_orga1___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (ret_massn_orga1___7)
          COALESCE(db.to_char_immutable(ret_massn_orga1___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (ret_massn_orga1___8)
          COALESCE(db.to_char_immutable(ret_notiz1), '#NULL#') || '|||' || -- hash from: Notiz (ret_notiz1)
          COALESCE(db.to_char_immutable(ret_meda_dat2), '#NULL#') || '|||' || -- hash from: Datum der retrolektiven Betrachtung* (ret_meda_dat2)
          COALESCE(db.to_char_immutable(ret_2ndbewertung___1), '#NULL#') || '|||' || -- hash from: 1 - 2nd Look / Zweite MRP-Bewertung durchführen (ret_2ndbewertung___1)
          COALESCE(db.to_char_immutable(ret_bewerter2), '#NULL#') || '|||' || -- hash from: 2. Bewertung von (ret_bewerter2)
          COALESCE(db.to_char_immutable(ret_bewerter3), '#NULL#') || '|||' || -- hash from:  (ret_bewerter3)
          COALESCE(db.to_char_immutable(ret_bewerter2_pipeline), '#NULL#') || '|||' || -- hash from:  (ret_bewerter2_pipeline)
          COALESCE(db.to_char_immutable(ret_gewissheit2), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP (ret_gewissheit2)
          COALESCE(db.to_char_immutable(ret_mrp_zuordnung2), '#NULL#') || '|||' || -- hash from: Zuordnung zu manuellem MRP (ret_mrp_zuordnung2)
          COALESCE(db.to_char_immutable(ret_gewissheit2_oth), '#NULL#') || '|||' || -- hash from: Weitere Informationen (ret_gewissheit2_oth)
          COALESCE(db.to_char_immutable(ret_gewiss_grund2_abl), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung (ret_gewiss_grund2_abl)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst2), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (ret_gewiss_grund_abl_sonst2)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin2), '#NULL#') || '|||' || -- hash from: WARUM ist das MRP nicht klinisch relevant (ret_gewiss_grund_abl_klin2)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin2_neg___1), '#NULL#') || '|||' || -- hash from: 1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (ret_gewiss_grund_abl_klin2_neg___1)
          COALESCE(db.to_char_immutable(ret_massn_am2___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (ret_massn_am2___1)
          COALESCE(db.to_char_immutable(ret_massn_am2___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (ret_massn_am2___2)
          COALESCE(db.to_char_immutable(ret_massn_am2___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (ret_massn_am2___3)
          COALESCE(db.to_char_immutable(ret_massn_am2___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (ret_massn_am2___4)
          COALESCE(db.to_char_immutable(ret_massn_am2___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (ret_massn_am2___5)
          COALESCE(db.to_char_immutable(ret_massn_am2___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (ret_massn_am2___6)
          COALESCE(db.to_char_immutable(ret_massn_am2___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (ret_massn_am2___7)
          COALESCE(db.to_char_immutable(ret_massn_am2___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (ret_massn_am2___8)
          COALESCE(db.to_char_immutable(ret_massn_am2___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (ret_massn_am2___9)
          COALESCE(db.to_char_immutable(ret_massn_am2___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (ret_massn_am2___10)
          COALESCE(db.to_char_immutable(ret_massn_orga2___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (ret_massn_orga2___1)
          COALESCE(db.to_char_immutable(ret_massn_orga2___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (ret_massn_orga2___2)
          COALESCE(db.to_char_immutable(ret_massn_orga2___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (ret_massn_orga2___3)
          COALESCE(db.to_char_immutable(ret_massn_orga2___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (ret_massn_orga2___4)
          COALESCE(db.to_char_immutable(ret_massn_orga2___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (ret_massn_orga2___5)
          COALESCE(db.to_char_immutable(ret_massn_orga2___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (ret_massn_orga2___6)
          COALESCE(db.to_char_immutable(ret_massn_orga2___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (ret_massn_orga2___7)
          COALESCE(db.to_char_immutable(ret_massn_orga2___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (ret_massn_orga2___8)
          COALESCE(db.to_char_immutable(ret_notiz2), '#NULL#') || '|||' || -- hash from: Notiz (ret_notiz2)
          COALESCE(db.to_char_immutable(ret_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (ret_additional_values)
          COALESCE(db.to_char_immutable(retrolektive_mrpbewertung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (retrolektive_mrpbewertung_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.retrolektive_mrpbewertung_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(ret_bewerter1), '#NULL#') || '|||' || -- hash from: 1. Bewertung von (ret_bewerter1)
          COALESCE(db.to_char_immutable(ret_id), '#NULL#') || '|||' || -- hash from: Retrolektive MRP-ID (REDCap) Hier wird die vom Datenprozessor MEDA-ID-r-Instanz aggregiert. (ret_id)
          COALESCE(db.to_char_immutable(ret_meda_id), '#NULL#') || '|||' || -- hash from: Zuordnung Meda -> rMRP (ret_meda_id)
          COALESCE(db.to_char_immutable(ret_meda_dat1), '#NULL#') || '|||' || -- hash from: Datum der retrolektiven Betrachtung* (ret_meda_dat1)
          COALESCE(db.to_char_immutable(ret_kurzbeschr), '#NULL#') || '|||' || -- hash from: Kurzbeschreibung des MRPs (ret_kurzbeschr)
          COALESCE(db.to_char_immutable(ret_ip_klasse), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (ret_ip_klasse)
          COALESCE(db.to_char_immutable(ret_ip_klasse_01), '#NULL#') || '|||' || -- hash from: MRP-Klasse (INTERPOLAR) (ret_ip_klasse_01)
          COALESCE(db.to_char_immutable(ret_atc1), '#NULL#') || '|||' || -- hash from: 1. Medikament ATC / Name: (ret_atc1)
          COALESCE(db.to_char_immutable(ret_atc2), '#NULL#') || '|||' || -- hash from: 2. Medikament ATC / Name (ret_atc2)
          COALESCE(db.to_char_immutable(ret_ip_klasse_disease), '#NULL#') || '|||' || -- hash from: Disease (ret_ip_klasse_disease)
          COALESCE(db.to_char_immutable(ret_ip_klasse_labor), '#NULL#') || '|||' || -- hash from: Labor (ret_ip_klasse_labor)
          COALESCE(db.to_char_immutable(ret_ip_klasse_nieren_insuf), '#NULL#') || '|||' || -- hash from: Grad der Nierenfunktionseinschränkung (ret_ip_klasse_nieren_insuf)
          COALESCE(db.to_char_immutable(ret_gewissheit1), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP (ret_gewissheit1)
          COALESCE(db.to_char_immutable(ret_mrp_zuordnung1), '#NULL#') || '|||' || -- hash from: Zuordnung zu manuellem MRP (ret_mrp_zuordnung1)
          COALESCE(db.to_char_immutable(ret_gewissheit1_oth), '#NULL#') || '|||' || -- hash from: Weitere Informationen (ret_gewissheit1_oth)
          COALESCE(db.to_char_immutable(ret_gewiss_grund1_abl), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung (ret_gewiss_grund1_abl)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst1), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (ret_gewiss_grund_abl_sonst1)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin1), '#NULL#') || '|||' || -- hash from: WARUM ist das MRP nicht klinisch relevant (ret_gewiss_grund_abl_klin1)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin1_neg___1), '#NULL#') || '|||' || -- hash from: 1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (ret_gewiss_grund_abl_klin1_neg___1)
          COALESCE(db.to_char_immutable(ret_massn_am1___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (ret_massn_am1___1)
          COALESCE(db.to_char_immutable(ret_massn_am1___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (ret_massn_am1___2)
          COALESCE(db.to_char_immutable(ret_massn_am1___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (ret_massn_am1___3)
          COALESCE(db.to_char_immutable(ret_massn_am1___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (ret_massn_am1___4)
          COALESCE(db.to_char_immutable(ret_massn_am1___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (ret_massn_am1___5)
          COALESCE(db.to_char_immutable(ret_massn_am1___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (ret_massn_am1___6)
          COALESCE(db.to_char_immutable(ret_massn_am1___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (ret_massn_am1___7)
          COALESCE(db.to_char_immutable(ret_massn_am1___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (ret_massn_am1___8)
          COALESCE(db.to_char_immutable(ret_massn_am1___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (ret_massn_am1___9)
          COALESCE(db.to_char_immutable(ret_massn_am1___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (ret_massn_am1___10)
          COALESCE(db.to_char_immutable(ret_massn_orga1___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (ret_massn_orga1___1)
          COALESCE(db.to_char_immutable(ret_massn_orga1___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (ret_massn_orga1___2)
          COALESCE(db.to_char_immutable(ret_massn_orga1___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (ret_massn_orga1___3)
          COALESCE(db.to_char_immutable(ret_massn_orga1___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (ret_massn_orga1___4)
          COALESCE(db.to_char_immutable(ret_massn_orga1___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (ret_massn_orga1___5)
          COALESCE(db.to_char_immutable(ret_massn_orga1___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (ret_massn_orga1___6)
          COALESCE(db.to_char_immutable(ret_massn_orga1___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (ret_massn_orga1___7)
          COALESCE(db.to_char_immutable(ret_massn_orga1___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (ret_massn_orga1___8)
          COALESCE(db.to_char_immutable(ret_notiz1), '#NULL#') || '|||' || -- hash from: Notiz (ret_notiz1)
          COALESCE(db.to_char_immutable(ret_meda_dat2), '#NULL#') || '|||' || -- hash from: Datum der retrolektiven Betrachtung* (ret_meda_dat2)
          COALESCE(db.to_char_immutable(ret_2ndbewertung___1), '#NULL#') || '|||' || -- hash from: 1 - 2nd Look / Zweite MRP-Bewertung durchführen (ret_2ndbewertung___1)
          COALESCE(db.to_char_immutable(ret_bewerter2), '#NULL#') || '|||' || -- hash from: 2. Bewertung von (ret_bewerter2)
          COALESCE(db.to_char_immutable(ret_bewerter3), '#NULL#') || '|||' || -- hash from:  (ret_bewerter3)
          COALESCE(db.to_char_immutable(ret_bewerter2_pipeline), '#NULL#') || '|||' || -- hash from:  (ret_bewerter2_pipeline)
          COALESCE(db.to_char_immutable(ret_gewissheit2), '#NULL#') || '|||' || -- hash from: Sicherheit des detektierten MRP (ret_gewissheit2)
          COALESCE(db.to_char_immutable(ret_mrp_zuordnung2), '#NULL#') || '|||' || -- hash from: Zuordnung zu manuellem MRP (ret_mrp_zuordnung2)
          COALESCE(db.to_char_immutable(ret_gewissheit2_oth), '#NULL#') || '|||' || -- hash from: Weitere Informationen (ret_gewissheit2_oth)
          COALESCE(db.to_char_immutable(ret_gewiss_grund2_abl), '#NULL#') || '|||' || -- hash from: Grund für nicht Bestätigung (ret_gewiss_grund2_abl)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_sonst2), '#NULL#') || '|||' || -- hash from: Bitte näher beschreiben (ret_gewiss_grund_abl_sonst2)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin2), '#NULL#') || '|||' || -- hash from: WARUM ist das MRP nicht klinisch relevant (ret_gewiss_grund_abl_klin2)
          COALESCE(db.to_char_immutable(ret_gewiss_grund_abl_klin2_neg___1), '#NULL#') || '|||' || -- hash from: 1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (ret_gewiss_grund_abl_klin2_neg___1)
          COALESCE(db.to_char_immutable(ret_massn_am2___1), '#NULL#') || '|||' || -- hash from: 1 - Anweisung für die Applikation geben (ret_massn_am2___1)
          COALESCE(db.to_char_immutable(ret_massn_am2___2), '#NULL#') || '|||' || -- hash from: 2 - Arzneimittel ändern (ret_massn_am2___2)
          COALESCE(db.to_char_immutable(ret_massn_am2___3), '#NULL#') || '|||' || -- hash from: 3 - Arzneimittel stoppen/pausieren (ret_massn_am2___3)
          COALESCE(db.to_char_immutable(ret_massn_am2___4), '#NULL#') || '|||' || -- hash from: 4 - Arzneimittel neu ansetzen (ret_massn_am2___4)
          COALESCE(db.to_char_immutable(ret_massn_am2___5), '#NULL#') || '|||' || -- hash from: 5 - Dosierung ändern (ret_massn_am2___5)
          COALESCE(db.to_char_immutable(ret_massn_am2___6), '#NULL#') || '|||' || -- hash from: 6 - Formulierung ändern (ret_massn_am2___6)
          COALESCE(db.to_char_immutable(ret_massn_am2___7), '#NULL#') || '|||' || -- hash from: 7 - Hilfe bei Beschaffung (ret_massn_am2___7)
          COALESCE(db.to_char_immutable(ret_massn_am2___8), '#NULL#') || '|||' || -- hash from: 8 - Information an Arzt/Pflege (ret_massn_am2___8)
          COALESCE(db.to_char_immutable(ret_massn_am2___9), '#NULL#') || '|||' || -- hash from: 9 - Information an Patient (ret_massn_am2___9)
          COALESCE(db.to_char_immutable(ret_massn_am2___10), '#NULL#') || '|||' || -- hash from: 10 - TDM oder Laborkontrolle emfohlen (ret_massn_am2___10)
          COALESCE(db.to_char_immutable(ret_massn_orga2___1), '#NULL#') || '|||' || -- hash from: 1 - Aushändigung einer Information/eines Medikationsplans (ret_massn_orga2___1)
          COALESCE(db.to_char_immutable(ret_massn_orga2___2), '#NULL#') || '|||' || -- hash from: 2 - CIRS-/AMK-Meldung (ret_massn_orga2___2)
          COALESCE(db.to_char_immutable(ret_massn_orga2___3), '#NULL#') || '|||' || -- hash from: 3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (ret_massn_orga2___3)
          COALESCE(db.to_char_immutable(ret_massn_orga2___4), '#NULL#') || '|||' || -- hash from: 4 - Etablierung einer Doppelkontrolle (ret_massn_orga2___4)
          COALESCE(db.to_char_immutable(ret_massn_orga2___5), '#NULL#') || '|||' || -- hash from: 5 - Lieferantenwechsel (ret_massn_orga2___5)
          COALESCE(db.to_char_immutable(ret_massn_orga2___6), '#NULL#') || '|||' || -- hash from: 6 - Optimierung der internen und externene Kommunikation (ret_massn_orga2___6)
          COALESCE(db.to_char_immutable(ret_massn_orga2___7), '#NULL#') || '|||' || -- hash from: 7 - Prozessoptimierung/Etablierung einer SOP/VA (ret_massn_orga2___7)
          COALESCE(db.to_char_immutable(ret_massn_orga2___8), '#NULL#') || '|||' || -- hash from: 8 - Sensibilisierung/Schulung (ret_massn_orga2___8)
          COALESCE(db.to_char_immutable(ret_notiz2), '#NULL#') || '|||' || -- hash from: Notiz (ret_notiz2)
          COALESCE(db.to_char_immutable(ret_additional_values), '#NULL#') || '|||' || -- hash from: Reserviertes Feld für zusätzliche Werte (ret_additional_values)
          COALESCE(db.to_char_immutable(retrolektive_mrpbewertung_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (retrolektive_mrpbewertung_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
-- Table "risikofaktor_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.risikofaktor_fe (
  risikofaktor_fe_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (record_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'record_id'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD record_id varchar;   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
        END IF; -- column (record_id)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instrument)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'redcap_repeat_instrument'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD redcap_repeat_instrument varchar;   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
        END IF; -- column (redcap_repeat_instrument)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instance)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'redcap_repeat_instance'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD redcap_repeat_instance varchar;   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
        END IF; -- column (redcap_repeat_instance)

        IF NOT EXISTS ( -- column not exists (redcap_data_access_group)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'redcap_data_access_group'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD redcap_data_access_group varchar;   -- Function as dataset filter by stations (varchar)
        END IF; -- column (redcap_data_access_group)

        IF NOT EXISTS ( -- column not exists (rskfk_gerhemmer)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_gerhemmer'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_gerhemmer int;   -- Ger.hemmer (int)
        END IF; -- column (rskfk_gerhemmer)

        IF NOT EXISTS ( -- column not exists (rskfk_tah)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_tah'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_tah int;   -- TAH (int)
        END IF; -- column (rskfk_tah)

        IF NOT EXISTS ( -- column not exists (rskfk_immunsupp)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_immunsupp'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_immunsupp int;   -- Immunsupp. (int)
        END IF; -- column (rskfk_immunsupp)

        IF NOT EXISTS ( -- column not exists (rskfk_tumorth)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_tumorth'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_tumorth int;   -- Tumorth. (int)
        END IF; -- column (rskfk_tumorth)

        IF NOT EXISTS ( -- column not exists (rskfk_opiat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_opiat'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_opiat int;   -- Opiat (int)
        END IF; -- column (rskfk_opiat)

        IF NOT EXISTS ( -- column not exists (rskfk_atcn)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_atcn'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_atcn int;   -- ATC N (int)
        END IF; -- column (rskfk_atcn)

        IF NOT EXISTS ( -- column not exists (rskfk_ait)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_ait'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_ait int;   -- AIT (int)
        END IF; -- column (rskfk_ait)

        IF NOT EXISTS ( -- column not exists (rskfk_anzam)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_anzam'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_anzam int;   -- Anz AM (int)
        END IF; -- column (rskfk_anzam)

        IF NOT EXISTS ( -- column not exists (rskfk_priscus)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_priscus'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_priscus int;   -- PRISCUS (int)
        END IF; -- column (rskfk_priscus)

        IF NOT EXISTS ( -- column not exists (rskfk_qtc)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_qtc'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_qtc int;   -- QTc (int)
        END IF; -- column (rskfk_qtc)

        IF NOT EXISTS ( -- column not exists (rskfk_meld)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_meld'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_meld int;   -- MELD (int)
        END IF; -- column (rskfk_meld)

        IF NOT EXISTS ( -- column not exists (rskfk_dialyse)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_dialyse'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_dialyse int;   -- Dialyse (int)
        END IF; -- column (rskfk_dialyse)

        IF NOT EXISTS ( -- column not exists (rskfk_entern)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfk_entern'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfk_entern int;   -- ent. Ern. (int)
        END IF; -- column (rskfk_entern)

        IF NOT EXISTS ( -- column not exists (rskfkt_anz_rskamklassen)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'rskfkt_anz_rskamklassen'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD rskfkt_anz_rskamklassen double precision;   -- Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (double precision)
        END IF; -- column (rskfkt_anz_rskamklassen)

        IF NOT EXISTS ( -- column not exists (risikofaktor_complete)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'risikofaktor_complete'
        ) THEN
            ALTER TABLE db_log.risikofaktor_fe ADD risikofaktor_complete varchar;   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
        END IF; -- column (risikofaktor_complete)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(record_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instance), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_data_access_group), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_gerhemmer), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_tah), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_immunsupp), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_tumorth), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_opiat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_atcn), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_ait), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_anzam), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_priscus), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_qtc), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_meld), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_dialyse), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfk_entern), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(rskfkt_anz_rskamklassen), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(risikofaktor_complete), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.risikofaktor_fe DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.risikofaktor_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(rskfk_gerhemmer), '#NULL#') || '|||' || -- hash from: Ger.hemmer (rskfk_gerhemmer)
          COALESCE(db.to_char_immutable(rskfk_tah), '#NULL#') || '|||' || -- hash from: TAH (rskfk_tah)
          COALESCE(db.to_char_immutable(rskfk_immunsupp), '#NULL#') || '|||' || -- hash from: Immunsupp. (rskfk_immunsupp)
          COALESCE(db.to_char_immutable(rskfk_tumorth), '#NULL#') || '|||' || -- hash from: Tumorth. (rskfk_tumorth)
          COALESCE(db.to_char_immutable(rskfk_opiat), '#NULL#') || '|||' || -- hash from: Opiat (rskfk_opiat)
          COALESCE(db.to_char_immutable(rskfk_atcn), '#NULL#') || '|||' || -- hash from: ATC N (rskfk_atcn)
          COALESCE(db.to_char_immutable(rskfk_ait), '#NULL#') || '|||' || -- hash from: AIT (rskfk_ait)
          COALESCE(db.to_char_immutable(rskfk_anzam), '#NULL#') || '|||' || -- hash from: Anz AM (rskfk_anzam)
          COALESCE(db.to_char_immutable(rskfk_priscus), '#NULL#') || '|||' || -- hash from: PRISCUS (rskfk_priscus)
          COALESCE(db.to_char_immutable(rskfk_qtc), '#NULL#') || '|||' || -- hash from: QTc (rskfk_qtc)
          COALESCE(db.to_char_immutable(rskfk_meld), '#NULL#') || '|||' || -- hash from: MELD (rskfk_meld)
          COALESCE(db.to_char_immutable(rskfk_dialyse), '#NULL#') || '|||' || -- hash from: Dialyse (rskfk_dialyse)
          COALESCE(db.to_char_immutable(rskfk_entern), '#NULL#') || '|||' || -- hash from: ent. Ern. (rskfk_entern)
          COALESCE(db.to_char_immutable(rskfkt_anz_rskamklassen), '#NULL#') || '|||' || -- hash from: Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (rskfkt_anz_rskamklassen)
          COALESCE(db.to_char_immutable(risikofaktor_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (risikofaktor_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.risikofaktor_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(rskfk_gerhemmer), '#NULL#') || '|||' || -- hash from: Ger.hemmer (rskfk_gerhemmer)
          COALESCE(db.to_char_immutable(rskfk_tah), '#NULL#') || '|||' || -- hash from: TAH (rskfk_tah)
          COALESCE(db.to_char_immutable(rskfk_immunsupp), '#NULL#') || '|||' || -- hash from: Immunsupp. (rskfk_immunsupp)
          COALESCE(db.to_char_immutable(rskfk_tumorth), '#NULL#') || '|||' || -- hash from: Tumorth. (rskfk_tumorth)
          COALESCE(db.to_char_immutable(rskfk_opiat), '#NULL#') || '|||' || -- hash from: Opiat (rskfk_opiat)
          COALESCE(db.to_char_immutable(rskfk_atcn), '#NULL#') || '|||' || -- hash from: ATC N (rskfk_atcn)
          COALESCE(db.to_char_immutable(rskfk_ait), '#NULL#') || '|||' || -- hash from: AIT (rskfk_ait)
          COALESCE(db.to_char_immutable(rskfk_anzam), '#NULL#') || '|||' || -- hash from: Anz AM (rskfk_anzam)
          COALESCE(db.to_char_immutable(rskfk_priscus), '#NULL#') || '|||' || -- hash from: PRISCUS (rskfk_priscus)
          COALESCE(db.to_char_immutable(rskfk_qtc), '#NULL#') || '|||' || -- hash from: QTc (rskfk_qtc)
          COALESCE(db.to_char_immutable(rskfk_meld), '#NULL#') || '|||' || -- hash from: MELD (rskfk_meld)
          COALESCE(db.to_char_immutable(rskfk_dialyse), '#NULL#') || '|||' || -- hash from: Dialyse (rskfk_dialyse)
          COALESCE(db.to_char_immutable(rskfk_entern), '#NULL#') || '|||' || -- hash from: ent. Ern. (rskfk_entern)
          COALESCE(db.to_char_immutable(rskfkt_anz_rskamklassen), '#NULL#') || '|||' || -- hash from: Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (rskfkt_anz_rskamklassen)
          COALESCE(db.to_char_immutable(risikofaktor_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (risikofaktor_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
        END IF; -- column
    END IF; -- Table
END
$$;
-- Table "trigger_fe" in schema "db_log"
-------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS db_log.trigger_fe (
  trigger_fe_id int -- Primary key of the entity - already filled in this schema - History via timestamp
);

DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 FROM
        (SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'db_log' AND table_name = 'trigger_fe') a
        , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
    ) THEN
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'input_datetime'
        ) THEN
            NULL;
        END IF; -- column

-- Organizational items - fixed for each database table -----------------------------------------
        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'input_datetime'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- Time at which data record was created
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'last_check_datetime'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD last_check_datetime TIMESTAMP DEFAULT NULL; -- Time at which data record was last checked
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'current_dataset_status'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD current_dataset_status VARCHAR DEFAULT 'input'; -- Processing status of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'input_processing_nr'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD input_processing_nr INT; -- (First) Processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'last_processing_nr'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD last_processing_nr INT; -- Last processing number of the data record
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'raw_already_processed'
        ) THEN
            NULL;
        END IF; -- column

-- Data-leading columns -------------------------------------------------------------------------
        IF NOT EXISTS ( -- column not exists (record_id)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'record_id'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD record_id varchar;   -- Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)
        END IF; -- column (record_id)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instrument)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'redcap_repeat_instrument'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD redcap_repeat_instrument varchar;   -- Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)
        END IF; -- column (redcap_repeat_instrument)

        IF NOT EXISTS ( -- column not exists (redcap_repeat_instance)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'redcap_repeat_instance'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD redcap_repeat_instance varchar;   -- Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)
        END IF; -- column (redcap_repeat_instance)

        IF NOT EXISTS ( -- column not exists (redcap_data_access_group)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'redcap_data_access_group'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD redcap_data_access_group varchar;   -- Function as dataset filter by stations (varchar)
        END IF; -- column (redcap_data_access_group)

        IF NOT EXISTS ( -- column not exists (trg_ast)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_ast'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_ast int;   -- AST↑ (int)
        END IF; -- column (trg_ast)

        IF NOT EXISTS ( -- column not exists (trg_alt)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_alt'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_alt int;   -- ALT↑ (int)
        END IF; -- column (trg_alt)

        IF NOT EXISTS ( -- column not exists (trg_crp)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_crp'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_crp int;   -- CRP↑ (int)
        END IF; -- column (trg_crp)

        IF NOT EXISTS ( -- column not exists (trg_leuk_penie)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_leuk_penie'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_leuk_penie int;   -- Leuko↓ (int)
        END IF; -- column (trg_leuk_penie)

        IF NOT EXISTS ( -- column not exists (trg_leuk_ose)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_leuk_ose'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_leuk_ose int;   -- Leuko↑ (int)
        END IF; -- column (trg_leuk_ose)

        IF NOT EXISTS ( -- column not exists (trg_thrmb_penie)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_thrmb_penie'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_thrmb_penie int;   -- Thrombo↓ (int)
        END IF; -- column (trg_thrmb_penie)

        IF NOT EXISTS ( -- column not exists (trg_aptt)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_aptt'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_aptt int;   -- aPTT (int)
        END IF; -- column (trg_aptt)

        IF NOT EXISTS ( -- column not exists (trg_hyp_haem)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hyp_haem'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hyp_haem int;   -- Hb↓ (int)
        END IF; -- column (trg_hyp_haem)

        IF NOT EXISTS ( -- column not exists (trg_hypo_glyk)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hypo_glyk'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hypo_glyk int;   -- Glc↓ (int)
        END IF; -- column (trg_hypo_glyk)

        IF NOT EXISTS ( -- column not exists (trg_hyper_glyk)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hyper_glyk'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hyper_glyk int;   -- Glc↑ (int)
        END IF; -- column (trg_hyper_glyk)

        IF NOT EXISTS ( -- column not exists (trg_hyper_bilirbnm)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hyper_bilirbnm'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hyper_bilirbnm int;   -- Bili↑ (int)
        END IF; -- column (trg_hyper_bilirbnm)

        IF NOT EXISTS ( -- column not exists (trg_ck)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_ck'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_ck int;   -- CK↑ (int)
        END IF; -- column (trg_ck)

        IF NOT EXISTS ( -- column not exists (trg_hypo_serablmn)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hypo_serablmn'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hypo_serablmn int;   -- Alb↓ (int)
        END IF; -- column (trg_hypo_serablmn)

        IF NOT EXISTS ( -- column not exists (trg_hypo_nat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hypo_nat'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hypo_nat int;   -- Na+↓ (int)
        END IF; -- column (trg_hypo_nat)

        IF NOT EXISTS ( -- column not exists (trg_hyper_nat)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hyper_nat'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hyper_nat int;   -- Na+↑ (int)
        END IF; -- column (trg_hyper_nat)

        IF NOT EXISTS ( -- column not exists (trg_hyper_kal)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hyper_kal'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hyper_kal int;   -- K+↑ (int)
        END IF; -- column (trg_hyper_kal)

        IF NOT EXISTS ( -- column not exists (trg_hypo_kal)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_hypo_kal'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_hypo_kal int;   -- K+↓ (int)
        END IF; -- column (trg_hypo_kal)

        IF NOT EXISTS ( -- column not exists (trg_inr_ern)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_inr_ern'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_inr_ern int;   -- INR Antikoag↓ (int)
        END IF; -- column (trg_inr_ern)

        IF NOT EXISTS ( -- column not exists (trg_inr_erh)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_inr_erh'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_inr_erh int;   -- INR ↑ (int)
        END IF; -- column (trg_inr_erh)

        IF NOT EXISTS ( -- column not exists (trg_inr_erh_antikoa)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_inr_erh_antikoa'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_inr_erh_antikoa int;   -- INR Antikoag↑ (int)
        END IF; -- column (trg_inr_erh_antikoa)

        IF NOT EXISTS ( -- column not exists (trg_krea)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_krea'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_krea int;   -- Krea↑ (int)
        END IF; -- column (trg_krea)

        IF NOT EXISTS ( -- column not exists (trg_egfr)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trg_egfr'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trg_egfr int;   -- eGFR<30 (int)
        END IF; -- column (trg_egfr)

        IF NOT EXISTS ( -- column not exists (trigger_complete)
            SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trigger_complete'
        ) THEN
            ALTER TABLE db_log.trigger_fe ADD trigger_complete varchar;   -- Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)
        END IF; -- column (trigger_complete)


-- Hash column for comparison on data-bearing columns -------------------------------------------
        IF EXISTS ( -- column exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            IF NOT EXISTS ( -- column exists
                SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'hash_index_col'
                AND trim(replace(replace(generation_expression::TEXT,'(',''),')','')) != trim(replace(replace('
	         COALESCE(db.to_char_immutable(record_id), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_repeat_instance), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(redcap_data_access_group), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_ast), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_alt), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_crp), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_leuk_penie), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_leuk_ose), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_thrmb_penie), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_aptt), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hyp_haem), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hypo_glyk), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hyper_glyk), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hyper_bilirbnm), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_ck), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hypo_serablmn), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hypo_nat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hyper_nat), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hyper_kal), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_hypo_kal), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_inr_ern), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_inr_erh), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_inr_erh_antikoa), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_krea), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trg_egfr), ''#NULL#'') || ''|||'' ||
          COALESCE(db.to_char_immutable(trigger_complete), ''#NULL#'') || ''|||'' ||''#''
                ','(',''),')',''))
            ) THEN
            -- Delete the old hash column so that a new one can be created
            ALTER TABLE db_log.trigger_fe DROP COLUMN hash_index_col;

            -- Creating the hash column
            ALTER TABLE db_log.trigger_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(trg_ast), '#NULL#') || '|||' || -- hash from: AST↑ (trg_ast)
          COALESCE(db.to_char_immutable(trg_alt), '#NULL#') || '|||' || -- hash from: ALT↑ (trg_alt)
          COALESCE(db.to_char_immutable(trg_crp), '#NULL#') || '|||' || -- hash from: CRP↑ (trg_crp)
          COALESCE(db.to_char_immutable(trg_leuk_penie), '#NULL#') || '|||' || -- hash from: Leuko↓ (trg_leuk_penie)
          COALESCE(db.to_char_immutable(trg_leuk_ose), '#NULL#') || '|||' || -- hash from: Leuko↑ (trg_leuk_ose)
          COALESCE(db.to_char_immutable(trg_thrmb_penie), '#NULL#') || '|||' || -- hash from: Thrombo↓ (trg_thrmb_penie)
          COALESCE(db.to_char_immutable(trg_aptt), '#NULL#') || '|||' || -- hash from: aPTT (trg_aptt)
          COALESCE(db.to_char_immutable(trg_hyp_haem), '#NULL#') || '|||' || -- hash from: Hb↓ (trg_hyp_haem)
          COALESCE(db.to_char_immutable(trg_hypo_glyk), '#NULL#') || '|||' || -- hash from: Glc↓ (trg_hypo_glyk)
          COALESCE(db.to_char_immutable(trg_hyper_glyk), '#NULL#') || '|||' || -- hash from: Glc↑ (trg_hyper_glyk)
          COALESCE(db.to_char_immutable(trg_hyper_bilirbnm), '#NULL#') || '|||' || -- hash from: Bili↑ (trg_hyper_bilirbnm)
          COALESCE(db.to_char_immutable(trg_ck), '#NULL#') || '|||' || -- hash from: CK↑ (trg_ck)
          COALESCE(db.to_char_immutable(trg_hypo_serablmn), '#NULL#') || '|||' || -- hash from: Alb↓ (trg_hypo_serablmn)
          COALESCE(db.to_char_immutable(trg_hypo_nat), '#NULL#') || '|||' || -- hash from: Na+↓ (trg_hypo_nat)
          COALESCE(db.to_char_immutable(trg_hyper_nat), '#NULL#') || '|||' || -- hash from: Na+↑ (trg_hyper_nat)
          COALESCE(db.to_char_immutable(trg_hyper_kal), '#NULL#') || '|||' || -- hash from: K+↑ (trg_hyper_kal)
          COALESCE(db.to_char_immutable(trg_hypo_kal), '#NULL#') || '|||' || -- hash from: K+↓ (trg_hypo_kal)
          COALESCE(db.to_char_immutable(trg_inr_ern), '#NULL#') || '|||' || -- hash from: INR Antikoag↓ (trg_inr_ern)
          COALESCE(db.to_char_immutable(trg_inr_erh), '#NULL#') || '|||' || -- hash from: INR ↑ (trg_inr_erh)
          COALESCE(db.to_char_immutable(trg_inr_erh_antikoa), '#NULL#') || '|||' || -- hash from: INR Antikoag↑ (trg_inr_erh_antikoa)
          COALESCE(db.to_char_immutable(trg_krea), '#NULL#') || '|||' || -- hash from: Krea↑ (trg_krea)
          COALESCE(db.to_char_immutable(trg_egfr), '#NULL#') || '|||' || -- hash from: eGFR<30 (trg_egfr)
          COALESCE(db.to_char_immutable(trigger_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (trigger_complete)
                 '#'
               )
            ) STORED; -- Column for hash value for comparing FHIR data - collion check in second step hash_index_col
            END IF; -- currend hash definition
        END IF; -- column

        IF NOT EXISTS ( -- column not exists
            SELECT 1 FROM
            (SELECT 1 s FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'hash_index_col') a
            , (SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1') b WHERE a.s=b.s
        ) THEN
            -- Creating the hash column
            ALTER TABLE db_log.trigger_fe ADD
            hash_index_col TEXT GENERATED ALWAYS AS (
            md5(
	         COALESCE(db.to_char_immutable(record_id), '#NULL#') || '|||' || -- hash from: Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (record_id)
          COALESCE(db.to_char_immutable(redcap_repeat_instrument), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (redcap_repeat_instrument)
          COALESCE(db.to_char_immutable(redcap_repeat_instance), '#NULL#') || '|||' || -- hash from: Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (redcap_repeat_instance)
          COALESCE(db.to_char_immutable(redcap_data_access_group), '#NULL#') || '|||' || -- hash from: Function as dataset filter by stations (redcap_data_access_group)
          COALESCE(db.to_char_immutable(trg_ast), '#NULL#') || '|||' || -- hash from: AST↑ (trg_ast)
          COALESCE(db.to_char_immutable(trg_alt), '#NULL#') || '|||' || -- hash from: ALT↑ (trg_alt)
          COALESCE(db.to_char_immutable(trg_crp), '#NULL#') || '|||' || -- hash from: CRP↑ (trg_crp)
          COALESCE(db.to_char_immutable(trg_leuk_penie), '#NULL#') || '|||' || -- hash from: Leuko↓ (trg_leuk_penie)
          COALESCE(db.to_char_immutable(trg_leuk_ose), '#NULL#') || '|||' || -- hash from: Leuko↑ (trg_leuk_ose)
          COALESCE(db.to_char_immutable(trg_thrmb_penie), '#NULL#') || '|||' || -- hash from: Thrombo↓ (trg_thrmb_penie)
          COALESCE(db.to_char_immutable(trg_aptt), '#NULL#') || '|||' || -- hash from: aPTT (trg_aptt)
          COALESCE(db.to_char_immutable(trg_hyp_haem), '#NULL#') || '|||' || -- hash from: Hb↓ (trg_hyp_haem)
          COALESCE(db.to_char_immutable(trg_hypo_glyk), '#NULL#') || '|||' || -- hash from: Glc↓ (trg_hypo_glyk)
          COALESCE(db.to_char_immutable(trg_hyper_glyk), '#NULL#') || '|||' || -- hash from: Glc↑ (trg_hyper_glyk)
          COALESCE(db.to_char_immutable(trg_hyper_bilirbnm), '#NULL#') || '|||' || -- hash from: Bili↑ (trg_hyper_bilirbnm)
          COALESCE(db.to_char_immutable(trg_ck), '#NULL#') || '|||' || -- hash from: CK↑ (trg_ck)
          COALESCE(db.to_char_immutable(trg_hypo_serablmn), '#NULL#') || '|||' || -- hash from: Alb↓ (trg_hypo_serablmn)
          COALESCE(db.to_char_immutable(trg_hypo_nat), '#NULL#') || '|||' || -- hash from: Na+↓ (trg_hypo_nat)
          COALESCE(db.to_char_immutable(trg_hyper_nat), '#NULL#') || '|||' || -- hash from: Na+↑ (trg_hyper_nat)
          COALESCE(db.to_char_immutable(trg_hyper_kal), '#NULL#') || '|||' || -- hash from: K+↑ (trg_hyper_kal)
          COALESCE(db.to_char_immutable(trg_hypo_kal), '#NULL#') || '|||' || -- hash from: K+↓ (trg_hypo_kal)
          COALESCE(db.to_char_immutable(trg_inr_ern), '#NULL#') || '|||' || -- hash from: INR Antikoag↓ (trg_inr_ern)
          COALESCE(db.to_char_immutable(trg_inr_erh), '#NULL#') || '|||' || -- hash from: INR ↑ (trg_inr_erh)
          COALESCE(db.to_char_immutable(trg_inr_erh_antikoa), '#NULL#') || '|||' || -- hash from: INR Antikoag↑ (trg_inr_erh_antikoa)
          COALESCE(db.to_char_immutable(trg_krea), '#NULL#') || '|||' || -- hash from: Krea↑ (trg_krea)
          COALESCE(db.to_char_immutable(trg_egfr), '#NULL#') || '|||' || -- hash from: eGFR<30 (trg_egfr)
          COALESCE(db.to_char_immutable(trigger_complete), '#NULL#') || '|||' || -- hash from: Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (trigger_complete)
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


-- Table "patient_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.patient_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.patient_fe TO db_user; -- Additional authorizations for testing

-- Table "fall_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.fall_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.fall_fe TO db_user; -- Additional authorizations for testing

-- Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.medikationsanalyse_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.medikationsanalyse_fe TO db_user; -- Additional authorizations for testing

-- Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.mrpdokumentation_validierung_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.mrpdokumentation_validierung_fe TO db_user; -- Additional authorizations for testing

-- Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.retrolektive_mrpbewertung_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.retrolektive_mrpbewertung_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.retrolektive_mrpbewertung_fe TO db_user; -- Additional authorizations for testing

-- Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.risikofaktor_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.risikofaktor_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.risikofaktor_fe TO db_user; -- Additional authorizations for testing

-- Table "trigger_fe" in schema "db_log"
----------------------------------------------------
GRANT TRIGGER ON db_log.trigger_fe TO db_log_user;
GRANT USAGE ON SCHEMA db_log TO db_log_user;
GRANT USAGE ON db.db_seq TO db_log_user;

GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.trigger_fe TO db_log_user; -- Additional authorizations for testing
GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE db_log.trigger_fe TO db_user; -- Additional authorizations for testing

------------------------------------------------------
-- Comments on Tables in Schema "db_log" --
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

COMMENT ON COLUMN db_log.patient_fe.patient_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.patient_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.patient_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.patient_fe.projekt_versionsnummer IS 'Versionsnummer zum Matching von REDCap-Projektversion mit weiteren Versionselementen der Toolchain (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_id IS 'Patient-identifier (FHIR) (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_cis_pid IS 'Patient-identifier (KIS) (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_name IS 'Patientenname (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_vorname IS 'Patientenvorname (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_gebdat IS 'Geburtsdatum (date)';
COMMENT ON COLUMN db_log.patient_fe.pat_aktuell_alter IS 'aktuelles Patientenalter (Jahre) (double precision)';
COMMENT ON COLUMN db_log.patient_fe.pat_geschlecht IS 'Geschlecht (varchar)';
COMMENT ON COLUMN db_log.patient_fe.pat_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
COMMENT ON COLUMN db_log.patient_fe.patient_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.patient_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.patient_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.patient_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.patient_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.patient_fe.last_processing_nr IS 'Last processing number of the data record';
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

COMMENT ON COLUMN db_log.fall_fe.fall_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.fall_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.fall_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.fall_fe.db_filter_8 IS 'Dashboard Filter 8 (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_fhir_enc_id IS 'verstecktes Feld für FHIR-ID des Encounters (varchar)';
COMMENT ON COLUMN db_log.fall_fe.patient_id_fk IS 'verstecktes Feld für patient_id_fk (int)';
COMMENT ON COLUMN db_log.fall_fe.fall_pat_id IS 'verstecktes Feld für fall_pat_id (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_id IS 'Fall-ID Encounter-Identifier (KIS) (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_studienphase IS 'Studienphase (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_station IS 'Station (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_aufn_dat IS 'Aufnahmedatum (timestamp)';
COMMENT ON COLUMN db_log.fall_fe.fall_zimmernr IS 'Zimmer-Nr. (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_aufn_diag IS 'Diagnose(n) bei Aufnahme (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_gewicht_aktuell IS 'aktuelles Gewicht (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_gewicht_aktl_einheit IS 'aktuelles Gewicht: Einheit (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_groesse IS 'Größe (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_groesse_einheit IS 'Größe: Einheit (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_bmi IS 'BMI (double precision)';
COMMENT ON COLUMN db_log.fall_fe.fall_status IS 'Fallstatus (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_ent_dat IS 'Entlassdatum (timestamp)';
COMMENT ON COLUMN db_log.fall_fe.fall_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
COMMENT ON COLUMN db_log.fall_fe.fall_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.fall_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.fall_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.fall_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.fall_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.fall_fe.last_processing_nr IS 'Last processing number of the data record';
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

COMMENT ON COLUMN db_log.medikationsanalyse_fe.medikationsanalyse_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.db_filter_5 IS 'Dashboard Filter 5 (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.db_filter_7 IS 'Dashboard Filter 7 (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_anlage IS 'Formular angelegt von (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_edit IS 'Formular zuletzt bearbeitet von (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.fall_meda_id IS '1 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu Fall (Fall-ID Encounter-Identifier (KIS)) Auswahlfeld falls die aktuell dokumentierte Medikationsanalyse sich nicht auf die letzte Instanz des Falls bezieht.   (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_id IS 'ID Medikationsanalyse (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse aggregiert (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_typ IS 'Typ der Medikationsanalyse (MA) (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_dat IS 'Datum der Medikationsanalyse (timestamp)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_gewicht_aktuell IS 'aktuelles Gewicht (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_gewicht_aktl_einheit IS 'aktuelles Gewicht: Einheit (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_groesse IS 'Größe (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_groesse_einheit IS 'Größe: Einheit (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_bmi IS 'BMI (double precision)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_nieren_insuf_chron IS 'Chronische Niereninsuffizienz (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_nieren_insuf_ausmass IS 'aktuelles Ausmaß (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_nieren_insuf_dialysev IS 'Nierenersatzverfahren (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_leber_insuf IS 'Leberinsuffizienz (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_leber_insuf_ausmass IS 'aktuelles Ausmaß (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_schwanger_mo IS 'Schwangerschaftsmonat (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_ma_thueberw IS 'Wiedervorlage Medikationsanalyse in 24-48h (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_mrp_detekt IS 'MRP detektiert? (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_aufwand_zeit IS 'Zeitaufwand Medikationsanalyse (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_aufwand_zeit_and IS 'genaue Dauer in Minuten (int)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_notiz IS 'Notizfeld (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.meda_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.medikationsanalyse_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.medikationsanalyse_fe.last_processing_nr IS 'Last processing number of the data record';
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

COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.db_filter_6 IS 'Dashboard Filter 6 (double precision)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_anlage IS 'Formular angelegt von (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_edit IS 'Formular zuletzt bearbeitet von (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_meda_id IS '2 Dynamische SQL-Abfrage zur Zuordnung Medikationsanalyse zu MRP   Auswahlfeld falls die aktuell dokumentiertes MRP  sich nicht auf die letzte Instanz der Medikationsanalyse bezieht.   (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_id IS 'MRP-ID (REDCap) Fall-ID Encounter-Identifier (KIS) mit Instanz der aktuellen Medikationsanalyse und der Instanz des aktuellen MRP aggregiert (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_entd_dat IS 'Datum des MRP (timestamp)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_entd_algorithmisch IS 'MRP vom INTERPOLAR-Algorithmus entdeckt? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_kurzbeschr IS 'Kurzbeschreibung des MRPs* (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber IS 'Hinweisgeber auf das MRP (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_hinweisgeber_oth IS 'Anderer Hinweisgeber (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_wirkstoff IS 'Wirkstoff betroffen? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc1 IS '1. Medikament ATC / Name: (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc2 IS '2. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc3 IS '3. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc4 IS '4. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_atc5 IS '5. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_med_prod IS 'Medizinprodukt betroffen? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_med_prod_sonst IS 'Bezeichnung Präparat (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_fehler IS 'Frage / Fehlerbeschreibung  (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_intervention IS 'Intervention / Vorschlag zur Fehlervermeldung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___1 IS '1 - AM: (Klare) Indikation nicht (mehr) gegeben (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___2 IS '2 - AM: Verordnung/Dokumentation unvollständig/fehlerhaft (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___3 IS '3 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___4 IS '4 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittel bezüglich Kosten (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___5 IS '5 - AM: Ungeeignetes/nicht am besten geeignetes Arzneimittelform für die Indikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___6 IS '6 - AM: Übertragungsfehler (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___7 IS '7 - AM: Substitution aut idem/aut simile (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___8 IS '8 - AM: (Klare) Indikation - aber kein Medikament angeordnet (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___9 IS '9 - AM: Stellfehler (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___10 IS '10 - AM: Arzneimittelallergie oder anamnestische Faktoren nicht berücksichtigt (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___11 IS '11 - AM: Doppelverordnung (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___12 IS '12 - ANW: Applikation (Dauer) (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___13 IS '13 - ANW: Inkompatibilität oder falsche Zubereitung (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___14 IS '14 - ANW: Applikation (Art) (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___15 IS '15 - ANW: Anfrage zur Administration/Kompatibilität (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___16 IS '16 - D: Kein TDM oder Laborkontrolle durchgeführt oder nicht beachtet (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___17 IS '17 - D: (Fehlerhafte) Dosis (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___18 IS '18 - D: (Fehlende) Dosisanpassung (Organfunktion) (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___19 IS '19 - D: (Fehlerhaftes) Dosisinterval (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___20 IS '20 - Interaktion (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___21 IS '21 - Kontraindikation (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___22 IS '22 - Nebenwirkungen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___23 IS '23 - S: Beratung/Auswahl eines Arzneistoffs (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___24 IS '24 - S: Beratung/Auswahl zur Dosierung eines Arzneistoffs (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___25 IS '25 - S: Beschaffung/Kosten (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___26 IS '26 - S: Keine Pause von AM - die prä-OP pausiert werden müssen (MF) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_pigrund___27 IS '27 - S: Schulung/Beratung eines Patienten (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_01 IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_disease IS 'Disease (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_labor IS 'Labor (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_ip_klasse_nieren_insuf IS 'Grad der Nierenfunktionseinschränkung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___1 IS '1 - Anweisung für die Applikation geben (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___2 IS '2 - Arzneimittel ändern (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___5 IS '5 - Dosierung ändern (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___6 IS '6 - Formulierung ändern (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___7 IS '7 - Hilfe bei Beschaffung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___8 IS '8 - Information an Arzt/Pflege (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___9 IS '9 - Information an Patient (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_am___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_massn_orga___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_notiz IS 'Notiz (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_dokup_hand_emp_akz IS 'Handlungsempfehlung akzeptiert? (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp IS 'NCC MERP Score (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_merp_info___1 IS '1 - NCC MERP Index anzeigen (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrp_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.mrpdokumentation_validierung_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.mrpdokumentation_validierung_fe.last_processing_nr IS 'Last processing number of the data record';
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

COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.retrolektive_mrpbewertung_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_bewerter1 IS '1. Bewertung von (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_id IS 'Retrolektive MRP-ID (REDCap) Hier wird die vom Datenprozessor MEDA-ID-r-Instanz aggregiert. (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_meda_id IS 'Zuordnung Meda -> rMRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_meda_dat1 IS 'Datum der retrolektiven Betrachtung* (timestamp)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_kurzbeschr IS 'Kurzbeschreibung des MRPs (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse_01 IS 'MRP-Klasse (INTERPOLAR) (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_atc1 IS '1. Medikament ATC / Name: (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_atc2 IS '2. Medikament ATC / Name (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse_disease IS 'Disease (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse_labor IS 'Labor (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_ip_klasse_nieren_insuf IS 'Grad der Nierenfunktionseinschränkung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit1 IS 'Sicherheit des detektierten MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_mrp_zuordnung1 IS 'Zuordnung zu manuellem MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit1_oth IS 'Weitere Informationen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund1_abl IS 'Grund für nicht Bestätigung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_sonst1 IS 'Bitte näher beschreiben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_klin1 IS 'WARUM ist das MRP nicht klinisch relevant (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_klin1_neg___1 IS '1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___1 IS '1 - Anweisung für die Applikation geben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___2 IS '2 - Arzneimittel ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___5 IS '5 - Dosierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___6 IS '6 - Formulierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___7 IS '7 - Hilfe bei Beschaffung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___8 IS '8 - Information an Arzt/Pflege (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___9 IS '9 - Information an Patient (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am1___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga1___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_notiz1 IS 'Notiz (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_meda_dat2 IS 'Datum der retrolektiven Betrachtung* (timestamp)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_2ndbewertung___1 IS '1 - 2nd Look / Zweite MRP-Bewertung durchführen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_bewerter2 IS '2. Bewertung von (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_bewerter3 IS ' (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_bewerter2_pipeline IS ' (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit2 IS 'Sicherheit des detektierten MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_mrp_zuordnung2 IS 'Zuordnung zu manuellem MRP (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewissheit2_oth IS 'Weitere Informationen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund2_abl IS 'Grund für nicht Bestätigung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_sonst2 IS 'Bitte näher beschreiben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_klin2 IS 'WARUM ist das MRP nicht klinisch relevant (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_gewiss_grund_abl_klin2_neg___1 IS '1 - Dieses MRP halte ich FÜR KEINEN Patienten auf dieser Station für KLINISCH RELEVANT (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___1 IS '1 - Anweisung für die Applikation geben (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___2 IS '2 - Arzneimittel ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___3 IS '3 - Arzneimittel stoppen/pausieren (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___4 IS '4 - Arzneimittel neu ansetzen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___5 IS '5 - Dosierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___6 IS '6 - Formulierung ändern (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___7 IS '7 - Hilfe bei Beschaffung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___8 IS '8 - Information an Arzt/Pflege (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___9 IS '9 - Information an Patient (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_am2___10 IS '10 - TDM oder Laborkontrolle emfohlen (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___1 IS '1 - Aushändigung einer Information/eines Medikationsplans (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___2 IS '2 - CIRS-/AMK-Meldung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___3 IS '3 - Einbindung anderer Berufsgruppen z.B. des Stationsapothekers (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___4 IS '4 - Etablierung einer Doppelkontrolle (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___5 IS '5 - Lieferantenwechsel (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___6 IS '6 - Optimierung der internen und externene Kommunikation (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___7 IS '7 - Prozessoptimierung/Etablierung einer SOP/VA (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_massn_orga2___8 IS '8 - Sensibilisierung/Schulung (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_notiz2 IS 'Notiz (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.ret_additional_values IS 'Reserviertes Feld für zusätzliche Werte (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.retrolektive_mrpbewertung_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.retrolektive_mrpbewertung_fe.last_processing_nr IS 'Last processing number of the data record';
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

COMMENT ON COLUMN db_log.risikofaktor_fe.risikofaktor_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.risikofaktor_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_gerhemmer IS 'Ger.hemmer (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_tah IS 'TAH (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_immunsupp IS 'Immunsupp. (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_tumorth IS 'Tumorth. (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_opiat IS 'Opiat (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_atcn IS 'ATC N (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_ait IS 'AIT (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_anzam IS 'Anz AM (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_priscus IS 'PRISCUS (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_qtc IS 'QTc (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_meld IS 'MELD (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_dialyse IS 'Dialyse (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfk_entern IS 'ent. Ern. (int)';
COMMENT ON COLUMN db_log.risikofaktor_fe.rskfkt_anz_rskamklassen IS 'Aggregation der Felder 27-33: Anzahl der Felder mit Ausprägung >0 (double precision)';
COMMENT ON COLUMN db_log.risikofaktor_fe.risikofaktor_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.risikofaktor_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.risikofaktor_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.risikofaktor_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.risikofaktor_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.risikofaktor_fe.last_processing_nr IS 'Last processing number of the data record';
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

COMMENT ON COLUMN db_log.trigger_fe.trigger_fe_id IS 'Primary key of the entity';
COMMENT ON COLUMN db_log.trigger_fe.record_id IS 'Record ID RedCap - predefined with the database internal ID of the patient - used in all instances of the patient in RedCap (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.redcap_repeat_instrument IS 'Frontend internal dataset management - Instrument: MRP-Dokumentation / -Validation (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.redcap_repeat_instance IS 'Frontend internal dataset management - Instance of the instrument - Numeric: 1…n (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.redcap_data_access_group IS 'Function as dataset filter by stations (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.trg_ast IS 'AST↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_alt IS 'ALT↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_crp IS 'CRP↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_leuk_penie IS 'Leuko↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_leuk_ose IS 'Leuko↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_thrmb_penie IS 'Thrombo↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_aptt IS 'aPTT (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyp_haem IS 'Hb↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_glyk IS 'Glc↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_glyk IS 'Glc↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_bilirbnm IS 'Bili↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_ck IS 'CK↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_serablmn IS 'Alb↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_nat IS 'Na+↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_nat IS 'Na+↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hyper_kal IS 'K+↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_hypo_kal IS 'K+↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_ern IS 'INR Antikoag↓ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_erh IS 'INR ↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_inr_erh_antikoa IS 'INR Antikoag↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_krea IS 'Krea↑ (int)';
COMMENT ON COLUMN db_log.trigger_fe.trg_egfr IS 'eGFR<30 (int)';
COMMENT ON COLUMN db_log.trigger_fe.trigger_complete IS 'Frontend Complete-Status - 0, Incomplete | 1, Unverified | 2, Complete (varchar)';
COMMENT ON COLUMN db_log.trigger_fe.input_datetime IS 'Time at which the data record is inserted';
COMMENT ON COLUMN db_log.trigger_fe.last_check_datetime IS 'Time at which data record was last checked';
COMMENT ON COLUMN db_log.trigger_fe.current_dataset_status IS 'Processing status of the data record';
COMMENT ON COLUMN db_log.trigger_fe.input_processing_nr IS '(First) Processing number of the data record';
COMMENT ON COLUMN db_log.trigger_fe.last_processing_nr IS 'Last processing number of the data record';
--------------------------------------------------------------------
    END IF; -- do migration
END
$$;

-- Output on
\o

------------------------------------------------------
-- INDEX for IDs on Tables in Schema "db_log" --
------------------------------------------------------
DO
$$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
------------------------------------------------------------------------------------------------

------------------------- Index for db_log - patient_fe ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'patient_fe_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_patient_fe_id',1,63) AND schemaname = 'db_log' AND tablename = 'patient_fe'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_patient_fe_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_patient_fe_id ON db_log.patient_fe USING btree (patient_fe_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_patient_fe_id RENAME TO del_idx_patient_fe_id;
		DROP INDEX IF EXISTS db_log.del_idx_patient_fe_id;
   	        CREATE INDEX idx_patient_fe_id ON db_log.patient_fe USING btree (patient_fe_id DESC);
            END IF; -- check current status
	  ELSE -- (easy) Create new
	    CREATE INDEX idx_patient_fe_id ON db_log.patient_fe USING btree (patient_fe_id DESC);
        END IF; -- INDEX available
    END IF; -- target column
      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_patient_fe_record_id',1,63) AND schemaname = 'db_log' AND tablename = 'patient_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_patient_fe_record_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_patient_fe_record_id ON db_log.patient_fe USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_patient_fe_record_id RENAME TO del_idx_patient_fe_record_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_patient_fe_record_id;
       	        CREATE INDEX idx_patient_fe_record_id ON db_log.patient_fe USING btree (record_id DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_patient_fe_record_id ON db_log.patient_fe USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_patient_fe_rc_re_id',1,63) AND schemaname = 'db_log' AND tablename = 'patient_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_patient_fe_rc_re_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_patient_fe_rc_re_id ON db_log.patient_fe USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_patient_fe_rc_re_id RENAME TO del_idx_patient_fe_rc_re_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_patient_fe_rc_re_id;
       	        CREATE INDEX idx_patient_fe_rc_re_id ON db_log.patient_fe USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_patient_fe_rc_re_id ON db_log.patient_fe USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column

-- Index idx_db_log_patient_fe_input_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_patient_fe_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'patient_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_db_log_patient_fe_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_patient_fe_input_dt ON db_log.patient_fe USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_patient_fe_input_dt RENAME TO del_db_log_patient_fe_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_patient_fe_i_dt;
	    CREATE INDEX idx_db_log_patient_fe_input_dt ON db_log.patient_fe USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_patient_fe_input_dt ON db_log.patient_fe USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_patient_fe_input_pnr for Table "patient_fe" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_patient_fe_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'patient_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_db_log_patient_fe_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_patient_fe_input_pnr ON db_log.patient_fe USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_patient_fe_input_pnr RENAME TO del_db_log_patient_fe_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_patient_fe_i_pnr;
	    CREATE INDEX idx_db_log_patient_fe_input_pnr ON db_log.patient_fe USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_patient_fe_input_pnr ON db_log.patient_fe USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_patient_fe_last_dt for Table "patient_fe" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_patient_fe_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'patient_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_db_log_patient_fe_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_patient_fe_last_dt ON db_log.patient_fe USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_patient_fe_last_dt RENAME TO del_db_log_patient_fe_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_patient_fe_l_dt;
	    CREATE INDEX idx_db_log_patient_fe_last_dt ON db_log.patient_fe USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_patient_fe_last_dt ON db_log.patient_fe USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_patient_fe_last_pnr for Table "patient_fe" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_patient_fe_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'patient_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_db_log_patient_fe_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_patient_fe_last_pnr ON db_log.patient_fe USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_patient_fe_last_pnr RENAME TO del_db_log_patient_fe_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_patient_fe_l_pnr;
	    CREATE INDEX idx_db_log_patient_fe_last_pnr ON db_log.patient_fe USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_patient_fe_last_pnr ON db_log.patient_fe USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_patient_fe_hash for Table "patient_fe" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'patient_fe' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_patient_fe_hash',1,63) AND schemaname = 'db_log' AND tablename = 'patient_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'patient_fe' AND substr(indexname,1,63)=substr('idx_db_log_patient_fe_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_patient_fe_input_dt ON db_log.patient_fe USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_patient_fe_hash RENAME TO del_db_log_patient_fe_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_patient_fe_hash;
	    CREATE INDEX idx_db_log_patient_fe_hash ON db_log.patient_fe USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_patient_fe_hash ON db_log.patient_fe USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for patient_fe ----------------------------------------------------

------------------------- Index for db_log - fall_fe ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'fall_fe_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_fall_fe_id',1,63) AND schemaname = 'db_log' AND tablename = 'fall_fe'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_fall_fe_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_fall_fe_id ON db_log.fall_fe USING btree (fall_fe_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_fall_fe_id RENAME TO del_idx_fall_fe_id;
		DROP INDEX IF EXISTS db_log.del_idx_fall_fe_id;
   	        CREATE INDEX idx_fall_fe_id ON db_log.fall_fe USING btree (fall_fe_id DESC);
            END IF; -- check current status
	  ELSE -- (easy) Create new
	    CREATE INDEX idx_fall_fe_id ON db_log.fall_fe USING btree (fall_fe_id DESC);
        END IF; -- INDEX available
    END IF; -- target column
      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_fall_fe_record_id',1,63) AND schemaname = 'db_log' AND tablename = 'fall_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_fall_fe_record_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_fall_fe_record_id ON db_log.fall_fe USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_fall_fe_record_id RENAME TO del_idx_fall_fe_record_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_fall_fe_record_id;
       	        CREATE INDEX idx_fall_fe_record_id ON db_log.fall_fe USING btree (record_id DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_fall_fe_record_id ON db_log.fall_fe USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_fall_fe_rc_re_id',1,63) AND schemaname = 'db_log' AND tablename = 'fall_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_fall_fe_rc_re_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_fall_fe_rc_re_id ON db_log.fall_fe USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_fall_fe_rc_re_id RENAME TO del_idx_fall_fe_rc_re_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_fall_fe_rc_re_id;
       	        CREATE INDEX idx_fall_fe_rc_re_id ON db_log.fall_fe USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_fall_fe_rc_re_id ON db_log.fall_fe USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column

-- Index idx_db_log_fall_fe_input_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_fall_fe_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'fall_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_db_log_fall_fe_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_fall_fe_input_dt ON db_log.fall_fe USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_fall_fe_input_dt RENAME TO del_db_log_fall_fe_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_fall_fe_i_dt;
	    CREATE INDEX idx_db_log_fall_fe_input_dt ON db_log.fall_fe USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_fall_fe_input_dt ON db_log.fall_fe USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_fall_fe_input_pnr for Table "fall_fe" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_fall_fe_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'fall_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_db_log_fall_fe_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_fall_fe_input_pnr ON db_log.fall_fe USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_fall_fe_input_pnr RENAME TO del_db_log_fall_fe_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_fall_fe_i_pnr;
	    CREATE INDEX idx_db_log_fall_fe_input_pnr ON db_log.fall_fe USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_fall_fe_input_pnr ON db_log.fall_fe USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_fall_fe_last_dt for Table "fall_fe" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_fall_fe_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'fall_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_db_log_fall_fe_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_fall_fe_last_dt ON db_log.fall_fe USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_fall_fe_last_dt RENAME TO del_db_log_fall_fe_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_fall_fe_l_dt;
	    CREATE INDEX idx_db_log_fall_fe_last_dt ON db_log.fall_fe USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_fall_fe_last_dt ON db_log.fall_fe USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_fall_fe_last_pnr for Table "fall_fe" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_fall_fe_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'fall_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_db_log_fall_fe_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_fall_fe_last_pnr ON db_log.fall_fe USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_fall_fe_last_pnr RENAME TO del_db_log_fall_fe_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_fall_fe_l_pnr;
	    CREATE INDEX idx_db_log_fall_fe_last_pnr ON db_log.fall_fe USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_fall_fe_last_pnr ON db_log.fall_fe USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_fall_fe_hash for Table "fall_fe" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'fall_fe' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_fall_fe_hash',1,63) AND schemaname = 'db_log' AND tablename = 'fall_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'fall_fe' AND substr(indexname,1,63)=substr('idx_db_log_fall_fe_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_fall_fe_input_dt ON db_log.fall_fe USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_fall_fe_hash RENAME TO del_db_log_fall_fe_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_fall_fe_hash;
	    CREATE INDEX idx_db_log_fall_fe_hash ON db_log.fall_fe USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_fall_fe_hash ON db_log.fall_fe USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for fall_fe ----------------------------------------------------

------------------------- Index for db_log - medikationsanalyse_fe ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'medikationsanalyse_fe_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_medikationsanalyse_fe_id',1,63) AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_medikationsanalyse_fe_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_medikationsanalyse_fe_id ON db_log.medikationsanalyse_fe USING btree (medikationsanalyse_fe_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_medikationsanalyse_fe_id RENAME TO del_idx_medikationsanalyse_fe_id;
		DROP INDEX IF EXISTS db_log.del_idx_medikationsanalyse_fe_id;
   	        CREATE INDEX idx_medikationsanalyse_fe_id ON db_log.medikationsanalyse_fe USING btree (medikationsanalyse_fe_id DESC);
            END IF; -- check current status
	  ELSE -- (easy) Create new
	    CREATE INDEX idx_medikationsanalyse_fe_id ON db_log.medikationsanalyse_fe USING btree (medikationsanalyse_fe_id DESC);
        END IF; -- INDEX available
    END IF; -- target column
      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_medikationsanalyse_fe_record_id',1,63) AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_medikationsanalyse_fe_record_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_medikationsanalyse_fe_record_id ON db_log.medikationsanalyse_fe USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_medikationsanalyse_fe_record_id RENAME TO del_idx_medikationsanalyse_fe_record_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_medikationsanalyse_fe_record_id;
       	        CREATE INDEX idx_medikationsanalyse_fe_record_id ON db_log.medikationsanalyse_fe USING btree (record_id DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_medikationsanalyse_fe_record_id ON db_log.medikationsanalyse_fe USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_medikationsanalyse_fe_rc_re_id',1,63) AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_medikationsanalyse_fe_rc_re_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_medikationsanalyse_fe_rc_re_id ON db_log.medikationsanalyse_fe USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_medikationsanalyse_fe_rc_re_id RENAME TO del_idx_medikationsanalyse_fe_rc_re_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_medikationsanalyse_fe_rc_re_id;
       	        CREATE INDEX idx_medikationsanalyse_fe_rc_re_id ON db_log.medikationsanalyse_fe USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_medikationsanalyse_fe_rc_re_id ON db_log.medikationsanalyse_fe USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column

-- Index idx_db_log_medikationsanalyse_fe_input_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_medikationsanalyse_fe_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_medikationsanalyse_fe_input_dt ON db_log.medikationsanalyse_fe USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_medikationsanalyse_fe_input_dt RENAME TO del_db_log_medikationsanalyse_fe_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_medikationsanalyse_fe_i_dt;
	    CREATE INDEX idx_db_log_medikationsanalyse_fe_input_dt ON db_log.medikationsanalyse_fe USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_medikationsanalyse_fe_input_dt ON db_log.medikationsanalyse_fe USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_medikationsanalyse_fe_input_pnr for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_medikationsanalyse_fe_input_pnr ON db_log.medikationsanalyse_fe USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_medikationsanalyse_fe_input_pnr RENAME TO del_db_log_medikationsanalyse_fe_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_medikationsanalyse_fe_i_pnr;
	    CREATE INDEX idx_db_log_medikationsanalyse_fe_input_pnr ON db_log.medikationsanalyse_fe USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_medikationsanalyse_fe_input_pnr ON db_log.medikationsanalyse_fe USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_medikationsanalyse_fe_last_dt for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_medikationsanalyse_fe_last_dt ON db_log.medikationsanalyse_fe USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_medikationsanalyse_fe_last_dt RENAME TO del_db_log_medikationsanalyse_fe_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_medikationsanalyse_fe_l_dt;
	    CREATE INDEX idx_db_log_medikationsanalyse_fe_last_dt ON db_log.medikationsanalyse_fe USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_medikationsanalyse_fe_last_dt ON db_log.medikationsanalyse_fe USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_medikationsanalyse_fe_last_pnr for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_medikationsanalyse_fe_last_pnr ON db_log.medikationsanalyse_fe USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_medikationsanalyse_fe_last_pnr RENAME TO del_db_log_medikationsanalyse_fe_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_medikationsanalyse_fe_l_pnr;
	    CREATE INDEX idx_db_log_medikationsanalyse_fe_last_pnr ON db_log.medikationsanalyse_fe USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_medikationsanalyse_fe_last_pnr ON db_log.medikationsanalyse_fe USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_medikationsanalyse_fe_hash for Table "medikationsanalyse_fe" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'medikationsanalyse_fe' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_hash',1,63) AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'medikationsanalyse_fe' AND substr(indexname,1,63)=substr('idx_db_log_medikationsanalyse_fe_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_medikationsanalyse_fe_input_dt ON db_log.medikationsanalyse_fe USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_medikationsanalyse_fe_hash RENAME TO del_db_log_medikationsanalyse_fe_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_medikationsanalyse_fe_hash;
	    CREATE INDEX idx_db_log_medikationsanalyse_fe_hash ON db_log.medikationsanalyse_fe USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_medikationsanalyse_fe_hash ON db_log.medikationsanalyse_fe USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for medikationsanalyse_fe ----------------------------------------------------

------------------------- Index for db_log - mrpdokumentation_validierung_fe ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'mrpdokumentation_validierung_fe_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_mrpdokumentation_validierung_fe_id',1,63) AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_mrpdokumentation_validierung_fe_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_mrpdokumentation_validierung_fe_id ON db_log.mrpdokumentation_validierung_fe USING btree (mrpdokumentation_validierung_fe_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_mrpdokumentation_validierung_fe_id RENAME TO del_idx_mrpdokumentation_validierung_fe_id;
		DROP INDEX IF EXISTS db_log.del_idx_mrpdokumentation_validierung_fe_id;
   	        CREATE INDEX idx_mrpdokumentation_validierung_fe_id ON db_log.mrpdokumentation_validierung_fe USING btree (mrpdokumentation_validierung_fe_id DESC);
            END IF; -- check current status
	  ELSE -- (easy) Create new
	    CREATE INDEX idx_mrpdokumentation_validierung_fe_id ON db_log.mrpdokumentation_validierung_fe USING btree (mrpdokumentation_validierung_fe_id DESC);
        END IF; -- INDEX available
    END IF; -- target column
      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_mrpdokumentation_validierung_fe_record_id',1,63) AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_mrpdokumentation_validierung_fe_record_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_mrpdokumentation_validierung_fe_record_id ON db_log.mrpdokumentation_validierung_fe USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_mrpdokumentation_validierung_fe_record_id RENAME TO del_idx_mrpdokumentation_validierung_fe_record_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_mrpdokumentation_validierung_fe_record_id;
       	        CREATE INDEX idx_mrpdokumentation_validierung_fe_record_id ON db_log.mrpdokumentation_validierung_fe USING btree (record_id DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_mrpdokumentation_validierung_fe_record_id ON db_log.mrpdokumentation_validierung_fe USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_mrpdokumentation_validierung_fe_rc_re_id',1,63) AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_mrpdokumentation_validierung_fe_rc_re_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_mrpdokumentation_validierung_fe_rc_re_id ON db_log.mrpdokumentation_validierung_fe USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_mrpdokumentation_validierung_fe_rc_re_id RENAME TO del_idx_mrpdokumentation_validierung_fe_rc_re_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_mrpdokumentation_validierung_fe_rc_re_id;
       	        CREATE INDEX idx_mrpdokumentation_validierung_fe_rc_re_id ON db_log.mrpdokumentation_validierung_fe USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_mrpdokumentation_validierung_fe_rc_re_id ON db_log.mrpdokumentation_validierung_fe USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column

-- Index idx_db_log_mrpdokumentation_validierung_fe_input_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_mrpdokumentation_validierung_fe_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_input_dt ON db_log.mrpdokumentation_validierung_fe USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_mrpdokumentation_validierung_fe_input_dt RENAME TO del_db_log_mrpdokumentation_validierung_fe_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_mrpdokumentation_validierung_fe_i_dt;
	    CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_input_dt ON db_log.mrpdokumentation_validierung_fe USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_input_dt ON db_log.mrpdokumentation_validierung_fe USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_mrpdokumentation_validierung_fe_input_pnr for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_input_pnr ON db_log.mrpdokumentation_validierung_fe USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_mrpdokumentation_validierung_fe_input_pnr RENAME TO del_db_log_mrpdokumentation_validierung_fe_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_mrpdokumentation_validierung_fe_i_pnr;
	    CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_input_pnr ON db_log.mrpdokumentation_validierung_fe USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_input_pnr ON db_log.mrpdokumentation_validierung_fe USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_mrpdokumentation_validierung_fe_last_dt for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_last_dt ON db_log.mrpdokumentation_validierung_fe USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_mrpdokumentation_validierung_fe_last_dt RENAME TO del_db_log_mrpdokumentation_validierung_fe_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_mrpdokumentation_validierung_fe_l_dt;
	    CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_last_dt ON db_log.mrpdokumentation_validierung_fe USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_last_dt ON db_log.mrpdokumentation_validierung_fe USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_mrpdokumentation_validierung_fe_last_pnr for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_last_pnr ON db_log.mrpdokumentation_validierung_fe USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_mrpdokumentation_validierung_fe_last_pnr RENAME TO del_db_log_mrpdokumentation_validierung_fe_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_mrpdokumentation_validierung_fe_l_pnr;
	    CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_last_pnr ON db_log.mrpdokumentation_validierung_fe USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_last_pnr ON db_log.mrpdokumentation_validierung_fe USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_mrpdokumentation_validierung_fe_hash for Table "mrpdokumentation_validierung_fe" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'mrpdokumentation_validierung_fe' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_hash',1,63) AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'mrpdokumentation_validierung_fe' AND substr(indexname,1,63)=substr('idx_db_log_mrpdokumentation_validierung_fe_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_input_dt ON db_log.mrpdokumentation_validierung_fe USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_mrpdokumentation_validierung_fe_hash RENAME TO del_db_log_mrpdokumentation_validierung_fe_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_mrpdokumentation_validierung_fe_hash;
	    CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_hash ON db_log.mrpdokumentation_validierung_fe USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_mrpdokumentation_validierung_fe_hash ON db_log.mrpdokumentation_validierung_fe USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for mrpdokumentation_validierung_fe ----------------------------------------------------

------------------------- Index for db_log - retrolektive_mrpbewertung_fe ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'retrolektive_mrpbewertung_fe_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_retrolektive_mrpbewertung_fe_id',1,63) AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_retrolektive_mrpbewertung_fe_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_retrolektive_mrpbewertung_fe_id ON db_log.retrolektive_mrpbewertung_fe USING btree (retrolektive_mrpbewertung_fe_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_retrolektive_mrpbewertung_fe_id RENAME TO del_idx_retrolektive_mrpbewertung_fe_id;
		DROP INDEX IF EXISTS db_log.del_idx_retrolektive_mrpbewertung_fe_id;
   	        CREATE INDEX idx_retrolektive_mrpbewertung_fe_id ON db_log.retrolektive_mrpbewertung_fe USING btree (retrolektive_mrpbewertung_fe_id DESC);
            END IF; -- check current status
	  ELSE -- (easy) Create new
	    CREATE INDEX idx_retrolektive_mrpbewertung_fe_id ON db_log.retrolektive_mrpbewertung_fe USING btree (retrolektive_mrpbewertung_fe_id DESC);
        END IF; -- INDEX available
    END IF; -- target column
      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_retrolektive_mrpbewertung_fe_record_id',1,63) AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_retrolektive_mrpbewertung_fe_record_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_retrolektive_mrpbewertung_fe_record_id ON db_log.retrolektive_mrpbewertung_fe USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_retrolektive_mrpbewertung_fe_record_id RENAME TO del_idx_retrolektive_mrpbewertung_fe_record_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_retrolektive_mrpbewertung_fe_record_id;
       	        CREATE INDEX idx_retrolektive_mrpbewertung_fe_record_id ON db_log.retrolektive_mrpbewertung_fe USING btree (record_id DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_retrolektive_mrpbewertung_fe_record_id ON db_log.retrolektive_mrpbewertung_fe USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_retrolektive_mrpbewertung_fe_rc_re_id',1,63) AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_retrolektive_mrpbewertung_fe_rc_re_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_retrolektive_mrpbewertung_fe_rc_re_id ON db_log.retrolektive_mrpbewertung_fe USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_retrolektive_mrpbewertung_fe_rc_re_id RENAME TO del_idx_retrolektive_mrpbewertung_fe_rc_re_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_retrolektive_mrpbewertung_fe_rc_re_id;
       	        CREATE INDEX idx_retrolektive_mrpbewertung_fe_rc_re_id ON db_log.retrolektive_mrpbewertung_fe USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_retrolektive_mrpbewertung_fe_rc_re_id ON db_log.retrolektive_mrpbewertung_fe USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column

-- Index idx_db_log_retrolektive_mrpbewertung_fe_input_dt for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_retrolektive_mrpbewertung_fe_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_input_dt ON db_log.retrolektive_mrpbewertung_fe USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_retrolektive_mrpbewertung_fe_input_dt RENAME TO del_db_log_retrolektive_mrpbewertung_fe_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_retrolektive_mrpbewertung_fe_i_dt;
	    CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_input_dt ON db_log.retrolektive_mrpbewertung_fe USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_input_dt ON db_log.retrolektive_mrpbewertung_fe USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_retrolektive_mrpbewertung_fe_input_pnr for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_input_pnr ON db_log.retrolektive_mrpbewertung_fe USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_retrolektive_mrpbewertung_fe_input_pnr RENAME TO del_db_log_retrolektive_mrpbewertung_fe_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_retrolektive_mrpbewertung_fe_i_pnr;
	    CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_input_pnr ON db_log.retrolektive_mrpbewertung_fe USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_input_pnr ON db_log.retrolektive_mrpbewertung_fe USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_retrolektive_mrpbewertung_fe_last_dt for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_last_dt ON db_log.retrolektive_mrpbewertung_fe USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_retrolektive_mrpbewertung_fe_last_dt RENAME TO del_db_log_retrolektive_mrpbewertung_fe_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_retrolektive_mrpbewertung_fe_l_dt;
	    CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_last_dt ON db_log.retrolektive_mrpbewertung_fe USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_last_dt ON db_log.retrolektive_mrpbewertung_fe USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_retrolektive_mrpbewertung_fe_last_pnr for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_last_pnr ON db_log.retrolektive_mrpbewertung_fe USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_retrolektive_mrpbewertung_fe_last_pnr RENAME TO del_db_log_retrolektive_mrpbewertung_fe_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_retrolektive_mrpbewertung_fe_l_pnr;
	    CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_last_pnr ON db_log.retrolektive_mrpbewertung_fe USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_last_pnr ON db_log.retrolektive_mrpbewertung_fe USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_retrolektive_mrpbewertung_fe_hash for Table "retrolektive_mrpbewertung_fe" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'retrolektive_mrpbewertung_fe' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_hash',1,63) AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'retrolektive_mrpbewertung_fe' AND substr(indexname,1,63)=substr('idx_db_log_retrolektive_mrpbewertung_fe_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_input_dt ON db_log.retrolektive_mrpbewertung_fe USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_retrolektive_mrpbewertung_fe_hash RENAME TO del_db_log_retrolektive_mrpbewertung_fe_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_retrolektive_mrpbewertung_fe_hash;
	    CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_hash ON db_log.retrolektive_mrpbewertung_fe USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_retrolektive_mrpbewertung_fe_hash ON db_log.retrolektive_mrpbewertung_fe USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for retrolektive_mrpbewertung_fe ----------------------------------------------------

------------------------- Index for db_log - risikofaktor_fe ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'risikofaktor_fe_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_risikofaktor_fe_id',1,63) AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_risikofaktor_fe_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_risikofaktor_fe_id ON db_log.risikofaktor_fe USING btree (risikofaktor_fe_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_risikofaktor_fe_id RENAME TO del_idx_risikofaktor_fe_id;
		DROP INDEX IF EXISTS db_log.del_idx_risikofaktor_fe_id;
   	        CREATE INDEX idx_risikofaktor_fe_id ON db_log.risikofaktor_fe USING btree (risikofaktor_fe_id DESC);
            END IF; -- check current status
	  ELSE -- (easy) Create new
	    CREATE INDEX idx_risikofaktor_fe_id ON db_log.risikofaktor_fe USING btree (risikofaktor_fe_id DESC);
        END IF; -- INDEX available
    END IF; -- target column
      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_risikofaktor_fe_record_id',1,63) AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_risikofaktor_fe_record_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_risikofaktor_fe_record_id ON db_log.risikofaktor_fe USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_risikofaktor_fe_record_id RENAME TO del_idx_risikofaktor_fe_record_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_risikofaktor_fe_record_id;
       	        CREATE INDEX idx_risikofaktor_fe_record_id ON db_log.risikofaktor_fe USING btree (record_id DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_risikofaktor_fe_record_id ON db_log.risikofaktor_fe USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_risikofaktor_fe_rc_re_id',1,63) AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_risikofaktor_fe_rc_re_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_risikofaktor_fe_rc_re_id ON db_log.risikofaktor_fe USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_risikofaktor_fe_rc_re_id RENAME TO del_idx_risikofaktor_fe_rc_re_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_risikofaktor_fe_rc_re_id;
       	        CREATE INDEX idx_risikofaktor_fe_rc_re_id ON db_log.risikofaktor_fe USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_risikofaktor_fe_rc_re_id ON db_log.risikofaktor_fe USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column

-- Index idx_db_log_risikofaktor_fe_input_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_risikofaktor_fe_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_risikofaktor_fe_input_dt ON db_log.risikofaktor_fe USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_risikofaktor_fe_input_dt RENAME TO del_db_log_risikofaktor_fe_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_risikofaktor_fe_i_dt;
	    CREATE INDEX idx_db_log_risikofaktor_fe_input_dt ON db_log.risikofaktor_fe USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_risikofaktor_fe_input_dt ON db_log.risikofaktor_fe USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_risikofaktor_fe_input_pnr for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_risikofaktor_fe_input_pnr ON db_log.risikofaktor_fe USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_risikofaktor_fe_input_pnr RENAME TO del_db_log_risikofaktor_fe_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_risikofaktor_fe_i_pnr;
	    CREATE INDEX idx_db_log_risikofaktor_fe_input_pnr ON db_log.risikofaktor_fe USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_risikofaktor_fe_input_pnr ON db_log.risikofaktor_fe USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_risikofaktor_fe_last_dt for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_risikofaktor_fe_last_dt ON db_log.risikofaktor_fe USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_risikofaktor_fe_last_dt RENAME TO del_db_log_risikofaktor_fe_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_risikofaktor_fe_l_dt;
	    CREATE INDEX idx_db_log_risikofaktor_fe_last_dt ON db_log.risikofaktor_fe USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_risikofaktor_fe_last_dt ON db_log.risikofaktor_fe USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_risikofaktor_fe_last_pnr for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_risikofaktor_fe_last_pnr ON db_log.risikofaktor_fe USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_risikofaktor_fe_last_pnr RENAME TO del_db_log_risikofaktor_fe_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_risikofaktor_fe_l_pnr;
	    CREATE INDEX idx_db_log_risikofaktor_fe_last_pnr ON db_log.risikofaktor_fe USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_risikofaktor_fe_last_pnr ON db_log.risikofaktor_fe USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_risikofaktor_fe_hash for Table "risikofaktor_fe" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'risikofaktor_fe' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_hash',1,63) AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'risikofaktor_fe' AND substr(indexname,1,63)=substr('idx_db_log_risikofaktor_fe_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_risikofaktor_fe_input_dt ON db_log.risikofaktor_fe USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_risikofaktor_fe_hash RENAME TO del_db_log_risikofaktor_fe_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_risikofaktor_fe_hash;
	    CREATE INDEX idx_db_log_risikofaktor_fe_hash ON db_log.risikofaktor_fe USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_risikofaktor_fe_hash ON db_log.risikofaktor_fe USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for risikofaktor_fe ----------------------------------------------------

------------------------- Index for db_log - trigger_fe ---------------------------------
    -- Primary key of the entity - already filled in this schema - History via timestamp
    IF EXISTS ( -- target column
        SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'trigger_fe_id'
    ) THEN
        IF EXISTS ( -- INDEX available
            SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_trigger_fe_id',1,63) AND schemaname = 'db_log' AND tablename = 'trigger_fe'
        ) THEN -- check current status
            IF EXISTS ( -- INDEX nicht auf akuellen Stand
                SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_trigger_fe_id',1,63)
		  AND indexdef != 'CREATE INDEX idx_trigger_fe_id ON db_log.trigger_fe USING btree (trigger_fe_id DESC)'
            ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
		ALTER INDEX db_log.idx_trigger_fe_id RENAME TO del_idx_trigger_fe_id;
		DROP INDEX IF EXISTS db_log.del_idx_trigger_fe_id;
   	        CREATE INDEX idx_trigger_fe_id ON db_log.trigger_fe USING btree (trigger_fe_id DESC);
            END IF; -- check current status
	  ELSE -- (easy) Create new
	    CREATE INDEX idx_trigger_fe_id ON db_log.trigger_fe USING btree (trigger_fe_id DESC);
        END IF; -- INDEX available
    END IF; -- target column
      -- Primary key in RedCap frontend record_id - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'record_id'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_trigger_fe_record_id',1,63) AND schemaname = 'db_log' AND tablename = 'trigger_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_trigger_fe_record_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_trigger_fe_record_id ON db_log.trigger_fe USING btree (record_id DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_trigger_fe_record_id RENAME TO del_idx_trigger_fe_record_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_trigger_fe_record_id;
       	        CREATE INDEX idx_trigger_fe_record_id ON db_log.trigger_fe USING btree (record_id DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_trigger_fe_record_id ON db_log.trigger_fe USING btree (record_id DESC);
          END IF; -- INDEX available
      END IF; -- target column
      -- Primary key in RedCap frontend redcap_repeat_instance - for last version
      IF EXISTS ( -- target column
          SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'redcap_repeat_instance'
      ) THEN
          IF EXISTS ( -- INDEX available
              SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_trigger_fe_rc_re_id',1,63) AND schemaname = 'db_log' AND tablename = 'trigger_fe'
          ) THEN -- check current status
              IF EXISTS ( -- INDEX nicht auf akuellen Stand
                  SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
                  AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_trigger_fe_rc_re_id',1,63)
	         	 AND indexdef != 'CREATE INDEX idx_trigger_fe_rc_re_id ON db_log.trigger_fe USING btree (redcap_repeat_instance DESC)'
              ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
	        	ALTER INDEX db_log.idx_trigger_fe_rc_re_id RENAME TO del_idx_trigger_fe_rc_re_id;
	        	DROP INDEX IF EXISTS db_log.del_idx_trigger_fe_rc_re_id;
       	        CREATE INDEX idx_trigger_fe_rc_re_id ON db_log.trigger_fe USING btree (redcap_repeat_instance DESC);
              END IF; -- check current status
  	 ELSE -- (easy) Create new
	             CREATE INDEX idx_trigger_fe_rc_re_id ON db_log.trigger_fe USING btree (redcap_repeat_instance DESC);
          END IF; -- INDEX available
      END IF; -- target column

-- Index idx_db_log_trigger_fe_input_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
-- Time at which the data record is inserted
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'input_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63) = substr('idx_db_log_trigger_fe_input_dt',1,63) AND schemaname = 'db_log' AND tablename = 'trigger_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_db_log_trigger_fe_input_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_trigger_fe_input_dt ON db_log.trigger_fe USING brin (input_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_trigger_fe_input_dt RENAME TO del_db_log_trigger_fe_i_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_trigger_fe_i_dt;
	    CREATE INDEX idx_db_log_trigger_fe_input_dt ON db_log.trigger_fe USING brin (input_datetime);
        END IF; -- check current status
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_trigger_fe_input_dt ON db_log.trigger_fe USING brin (input_datetime);
    END IF; -- INDEX available
END IF; -- target column

-- Index idx_db_log_trigger_fe_input_pnr for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
-- (First) Processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'input_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_trigger_fe_input_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'trigger_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_db_log_trigger_fe_input_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_trigger_fe_input_pnr ON db_log.trigger_fe USING brin (input_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_trigger_fe_input_pnr RENAME TO del_db_log_trigger_fe_i_pnr;
	    DROP INDEX IF EXISTS db_log.del_db_log_trigger_fe_i_pnr;
	    CREATE INDEX idx_db_log_trigger_fe_input_pnr ON db_log.trigger_fe USING brin (input_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_trigger_fe_input_pnr ON db_log.trigger_fe USING brin (input_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_trigger_fe_last_dt for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
-- Time at which data record was last checked
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'last_check_datetime'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_trigger_fe_last_dt',1,63)  AND schemaname = 'db_log' AND tablename = 'trigger_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_db_log_trigger_fe_last_dt',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_trigger_fe_last_dt ON db_log.trigger_fe USING brin (last_check_datetime)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_trigger_fe_last_dt RENAME TO del_db_log_trigger_fe_l_dt;
	    DROP INDEX IF EXISTS db_log.del_db_log_trigger_fe_l_dt;
	    CREATE INDEX idx_db_log_trigger_fe_last_dt ON db_log.trigger_fe USING brin (last_check_datetime);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_trigger_fe_last_dt ON db_log.trigger_fe USING brin (last_check_datetime);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_trigger_fe_last_pnr for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
-- Last processing number of the data record
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'last_processing_nr'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_trigger_fe_last_pnr',1,63) AND schemaname = 'db_log' AND tablename = 'trigger_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_db_log_trigger_fe_last_pnr',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_trigger_fe_last_pnr ON db_log.trigger_fe USING brin (last_processing_nr)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_trigger_fe_last_pnr RENAME TO del_db_log_trigger_fe_l_pnr;
            DROP INDEX IF EXISTS db_log.del_db_log_trigger_fe_l_pnr;
	    CREATE INDEX idx_db_log_trigger_fe_last_pnr ON db_log.trigger_fe USING brin (last_processing_nr);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_trigger_fe_last_pnr ON db_log.trigger_fe USING brin (last_processing_nr);
    END IF; -- INDEX available"%>
END IF; -- target column

-- Index idx_db_log_trigger_fe_hash for Table "trigger_fe" in schema "db_log"
----------------------------------------------------
-- Column for automatic hash value for comparing FHIR data
IF EXISTS ( -- target column
    SELECT 1 FROM information_schema.columns WHERE table_schema = 'db_log' AND table_name = 'trigger_fe' AND column_name = 'hash_index_col'
) THEN
    IF EXISTS ( -- INDEX available
        SELECT 1 FROM pg_indexes where substr(indexname,1,63)=substr('idx_db_log_trigger_fe_hash',1,63) AND schemaname = 'db_log' AND tablename = 'trigger_fe'
    ) THEN -- check current status
        IF EXISTS ( -- INDEX nicht auf akuellen Stand
            SELECT 1 FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            AND schemaname = 'db_log' AND tablename = 'trigger_fe' AND substr(indexname,1,63)=substr('idx_db_log_trigger_fe_hash',1,63)
	    AND indexdef != 'CREATE INDEX idx_db_log_trigger_fe_input_dt ON db_log.trigger_fe USING btree (hash_index_col)'
        ) THEN -- Index entspricht nicht aktuellen Stand - deshalb Index löschen und neu anlegen
            ALTER INDEX db_log.idx_db_log_trigger_fe_hash RENAME TO del_db_log_trigger_fe_hash;
	    DROP INDEX IF EXISTS db_log.del_db_log_trigger_fe_hash;
	    CREATE INDEX idx_db_log_trigger_fe_hash ON db_log.trigger_fe USING btree (hash_index_col);
        END IF; -- check current status"%>
    ELSE -- (easy) Create new
        CREATE INDEX idx_db_log_trigger_fe_hash ON db_log.trigger_fe USING btree (hash_index_col);
    END IF; -- INDEX available"%>
END IF; -- target column

-- index by definition table for trigger_fe ----------------------------------------------------


------------------------------------------------------------------------------------------------
    END IF; -- do migration
END
$$;

