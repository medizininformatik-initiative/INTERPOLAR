DO
$innerview$
BEGIN
    IF EXISTS ( -- do migration
        SELECT 1 s FROM db_config.db_parameter WHERE parameter_name='current_migration_flag' AND parameter_value='1'
    ) THEN
        IF EXISTS ( -- VIEW exists
            SELECT 1 s FROM information_schema.columns
            WHERE table_schema = '<%OWNER_SCHEMA%>' AND table_name = '<%TABLE_NAME%>'
        ) THEN
            DROP VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%>; -- first drop the view
        END IF; -- DROP VIEW
----------------------------
        CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (
        SELECT o.* FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> o
        WHERE (o.record_id, o.<%IF TABLE_DESCRIPTION:TABLE_NAME "^patient$" "pat_id"%><%IF TABLE_DESCRIPTION:TABLE_NAME "^fall$" "fall_fhir_enc_id"%><%IF NOT TABLE_DESCRIPTION:TABLE_NAME "^(patient|fall)$" "redcap_repeat_instance"%>, o.last_processing_nr) IN (SELECT i.record_id, i.<%IF TABLE_DESCRIPTION:TABLE_NAME "^patient$" "pat_id"%><%IF TABLE_DESCRIPTION:TABLE_NAME "^fall$" "fall_fhir_enc_id"%><%IF NOT TABLE_DESCRIPTION:TABLE_NAME "^(patient|fall)$" "redcap_repeat_instance"%>, MAX(i.last_processing_nr)
                                                                                 FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> i
                                                                                 GROUP BY i.record_id, i.<%IF TABLE_DESCRIPTION:TABLE_NAME "^patient$" "pat_id"%><%IF TABLE_DESCRIPTION:TABLE_NAME "^fall$" "fall_fhir_enc_id"%><%IF NOT TABLE_DESCRIPTION:TABLE_NAME "^(patient|fall)$" "redcap_repeat_instance"%>
                                                                                )
        );

        GRANT <%RIGHTS%> ON <%OWNER_SCHEMA%>.<%TABLE_NAME%> TO <%GRANT_TARGET_USER%>;
        GRANT USAGE ON SCHEMA <%OWNER_SCHEMA%> TO <%OWNER_USER%>;
----------------------------
    END IF; -- do migration
END
$innerview$;

------------------------------------------------------------------------------------------------------------------
