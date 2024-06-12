--Create SQL View not Typed Datasets in Schema db2frontend_out direct from DataProc
CREATE OR REPLACE VIEW db2frontend_out.v_patient AS (
SELECT * FROM db_log.patient_fe
WHERE TO_CHAR(COALESCE(last_check_datetime,input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime,input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.patient_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_fall AS (
SELECT * FROM db_log.fall_fe
WHERE TO_CHAR(COALESCE(last_check_datetime,input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime,input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.fall_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_medikationsanalyse AS (
SELECT * FROM db_log.medikationsanalyse_fe
WHERE TO_CHAR(COALESCE(last_check_datetime,input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime,input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.medikationsanalyse_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_mrpdokumentation_validierung AS (
SELECT * FROM db_log.mrpdokumentation_validierung_fe
WHERE TO_CHAR(COALESCE(last_check_datetime,input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime,input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.mrpdokumentation_validierung_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_risikofaktor AS (
SELECT * FROM db_log.risikofaktor_fe
WHERE TO_CHAR(COALESCE(last_check_datetime,input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime,input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.risikofaktor_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_trigger AS (
SELECT * FROM db_log.trigger_fe
WHERE TO_CHAR(COALESCE(last_check_datetime,input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime,input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.trigger_fe)
);


--SQL Role for Views in Schema db2frontend_out
GRANT SELECT ON TABLE db2frontend_out.v_patient TO db2frontend_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE db2frontend_out.v_patient TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_fall TO db2frontend_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE db2frontend_out.v_fall TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_medikationsanalyse TO db2frontend_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE db2frontend_out.v_medikationsanalyse TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_mrpdokumentation_validierung TO db2frontend_user; -- View dem Anwender zuordnen
GRANT SELECT ON TABLE db2frontend_out.v_mrpdokumentation_validierung TO db_user; -- Entwicklungsphase
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;
