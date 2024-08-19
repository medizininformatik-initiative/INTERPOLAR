--Create View for frontend tables for schema db2frontend_out

CREATE OR REPLACE VIEW db2frontend_out.v_patient AS (
SELECT * FROM db_log.patient_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.patient_fe)
);

CREATE OR REPLACE VIEW db2frontend_out.v_fall AS (
SELECT * FROM db_log.fall_fe
WHERE TO_CHAR(COALESCE(last_check_datetime, input_datetime),'YYYY-MM-DD HH24:MI') IN (SELECT TO_CHAR(MAX(COALESCE(last_check_datetime, input_datetime)),'YYYY-MM-DD HH24:MI') FROM db_log.fall_fe)
);

--SQL Role for Views in Schema db2frontend_out
GRANT SELECT ON TABLE db2frontend_out.v_patient TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_patient TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;

GRANT SELECT ON TABLE db2frontend_out.v_fall TO db2frontend_user;
GRANT SELECT ON TABLE db2frontend_out.v_fall TO db_user;
GRANT USAGE ON SCHEMA db2frontend_out TO db2frontend_user;


