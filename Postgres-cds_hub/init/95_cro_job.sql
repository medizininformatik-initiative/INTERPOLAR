CREATE OR REPLACE FUNCTION db.cron_job_data_transfer()
RETURNS VOID AS $$
DECLARE
    temp varchar;
BEGIN
    -- FHIR Data
    SELECT db.copy_raw_cds_in_to_db_log() INTO temp;

    SELECT pg_sleep(1) INTO temp;

    SELECT db.copy_type_cds_in_to_db_log() INTO temp;

    SELECT pg_sleep(1) INTO temp;

    SELECT db.take_over_last_check_date() INTO temp;

    SELECT pg_sleep(1) INTO temp;

    -- Study data
    SELECT db.copy_fe_dp_in_to_db_log() INTO temp;

    SELECT pg_sleep(1) INTO temp;

    SELECT db.copy_fe_fe_in_to_db_log() INTO temp;
END;
$$ LANGUAGE plpgsql;

-- Datatransfer Job
SELECT cron.schedule('*/1 * * * *', 'SELECT db.cron_job_data_transfer();');
