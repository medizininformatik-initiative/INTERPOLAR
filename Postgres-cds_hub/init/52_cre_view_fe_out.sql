--Create SQL View not Typed Datasets in Schema db2frontend_out
CREATE OR REPLACE VIEW db2frontend_out.v_patient AS (select * from db2dataprocessor_in.patient_fe);
CREATE OR REPLACE VIEW db2frontend_out.v_fall AS (select * from db2dataprocessor_in.fall_fe);
CREATE OR REPLACE VIEW db2frontend_out.v_medikationsanalyse AS (select * from db2dataprocessor_in.medikationsanalyse_fe);
CREATE OR REPLACE VIEW db2frontend_out.v_mrpdokumentation_validierung AS (select * from db2dataprocessor_in.mrpdokumentation_validierung_fe);
CREATE OR REPLACE VIEW db2frontend_out.v_risikofaktor AS (select * from db2dataprocessor_in.risikofaktor_fe);
CREATE OR REPLACE VIEW db2frontend_out.v_trigger AS (select * from db2dataprocessor_in.trigger_fe);

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
