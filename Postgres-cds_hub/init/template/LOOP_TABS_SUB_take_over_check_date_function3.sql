            ----------------- Update for <%TABLE_NAME%> ----------------------------------    
            --err_section:='UPDATE-35';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME_2%>';
	    UPDATE <%SCHEMA_2%>.<%TABLE_NAME_2%> SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE <%TABLE_NAME%>_id IN (SELECT <%TABLE_NAME%>_ID FROM <%SCHEMA_2%>.<%TABLE_NAME%> t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;

            --err_section:='UPDATE-40';    err_schema:='<%SCHEMA_2%>';    err_table:='<%TABLE_NAME%>';
            UPDATE <%SCHEMA_2%>.<%TABLE_NAME%> SET last_check_datetime = last_pro_datetime, last_processing_nr = new_last_pro_nr
            WHERE <%TABLE_NAME%>_id IN (SELECT <%TABLE_NAME%>_ID FROM <%SCHEMA_2%>.<%TABLE_NAME%> t, lpn_collection l WHERE t.last_processing_nr=l.lpn)
            AND last_processing_nr!=new_last_pro_nr;
