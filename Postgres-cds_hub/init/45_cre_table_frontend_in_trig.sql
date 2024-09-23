-- ########################################################################################################
--
-- This file is static. - Add Trigger to Tables in schema frontend_in
--
-- Create time: 2024-09-21 16:00:00
-- TABLE_DESCRIPTION:  ./R-db2frontend/db2frontend/inst/extdata/Frontend_Table_Description.xlsx[frontend_table_description]
-- SCRIPTNAME:  45_cre_table_frontend_in_trig.sql
-- TEMPLATE:  none
-- OWNER_USER:  db2frontend_user
-- OWNER_SCHEMA:  db2frontend_in
-- TAGS: 
-- TABLE_PREFIX:  
-- TABLE_POSTFIX:  _fe
-- RIGHTS: 
-- ########################################################################################################

-- patient_fe ------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db2frontend_in.patient_fe_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Entering a data record ID if the data record was created for the first time in the FrontEnd and cannot yet have an ID in the database
    IF NEW.patient_fe_id IS NULL THEN
        NEW.patient_fe_id := nextval('db.db_seq'); -- New Primary key of the entity
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER patient_fe_tr_ins
  BEFORE INSERT
  ON  db2frontend_in.patient_fe
  FOR EACH ROW
  EXECUTE PROCEDURE db2frontend_in.patient_fe_ins_fkt();

-- fall_fe ---------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db2frontend_in.fall_fe_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Entering a data record ID if the data record was created for the first time in the FrontEnd and cannot yet have an ID in the database
    IF NEW.fall_fe_id IS NULL THEN
        NEW.fall_fe_id := nextval('db.db_seq'); -- New Primary key of the entity
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER fall_fe_tr_ins
  BEFORE INSERT
  ON  db2frontend_in.fall_fe
  FOR EACH ROW
  EXECUTE PROCEDURE db2frontend_in.fall_fe_ins_fkt();

-- medikationsanalyse_fe -------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db2frontend_in.medikationsanalyse_fe_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Entering a data record ID if the data record was created for the first time in the FrontEnd and cannot yet have an ID in the database
    IF NEW.medikationsanalyse_fe_id IS NULL THEN
        NEW.medikationsanalyse_fe_id := nextval('db.db_seq'); -- New Primary key of the entity
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER medikationsanalyse_fe_tr_ins
  BEFORE INSERT
  ON  db2frontend_in.medikationsanalyse_fe
  FOR EACH ROW
  EXECUTE PROCEDURE db2frontend_in.medikationsanalyse_fe_ins_fkt();

-- mrpdokumentation_validierung_fe ---------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION db2frontend_in.mrpdokumentation_validierung_fe_ins_fkt()
RETURNS TRIGGER AS $$
BEGIN
    -- Entering a data record ID if the data record was created for the first time in the FrontEnd and cannot yet have an ID in the database
    IF NEW.mrpdokumentation_validierung_fe_id IS NULL THEN
        NEW.mrpdokumentation_validierung_fe_id := nextval('db.db_seq'); -- New Primary key of the entity
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER mrpdokumentation_validierung_fe_tr_ins
  BEFORE INSERT
  ON  db2frontend_in.mrpdokumentation_validierung_fe
  FOR EACH ROW
  EXECUTE PROCEDURE db2frontend_in.mrpdokumentation_validierung_fe_ins_fkt();
