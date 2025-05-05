            ---- Start check <%SCHEMA_2%>.<%TABLE_NAME_2%> ---- Update FHIR Metadata
            UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%> z SET
                <%LOOP_COLS_SUB_LOOP_TABS_SUB_take_over_check_date_function_update_fhir_data_SET%>
                z.last_check_datetime = q.last_check_datetime
            FROM <%SCHEMA_2%>.<%TABLE_NAME%> q
            WHERE z.<%TABLE_NAME%>_id = q.<%TABLE_NAME%>_id AND (
                <%LOOP_COLS_SUB_LOOP_TABS_SUB_take_over_check_date_function_update_fhir_data_WHERE%>
                z.last_check_datetime != q.last_check_datetime
            );
            ---- End check <%SCHEMA_2%>.<%TABLE_NAME_2%> ---- Update FHIR Metadata

