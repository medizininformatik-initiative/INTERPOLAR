-- Create View  DB2FRONTEND_OUT
-- Temporär aus LogSchema
CREATE OR REPLACE VIEW db2frontend_out.patient AS
select
patient_raw_id as record_id
, pat_id AS pat_id
, pat_name_family AS pat_name
, pat_name_given AS pat_vorname
, EXTRACT(YEAR FROM AGE(NOW(), pat_birthdate::DATE)) AS pat_ak_alter
, EXTRACT(MONTH FROM AGE(NOW(), pat_birthdate::DATE)) AS pat_ak_alter_MM
, pat_gender AS pat_gschlcht
, to_char(input_datetime,'YYYY-MM-DD HH24:MI:SS') erster_datenimport_zeitpunkt
, to_char(last_check_datetime,'YYYY-MM-DD HH24:MI:SS') letzte_datensatzaenderung_zeitpunkt
, to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS') letzter_abrufzeitpunkt_dieser_daten
from db_log.patient_raw order by pat_id;

GRANT USAGE ON SCHEMA db2frontend_out to db2frontend_user;
GRANT SELECT ON db2frontend_out.patient to db2frontend_user;
