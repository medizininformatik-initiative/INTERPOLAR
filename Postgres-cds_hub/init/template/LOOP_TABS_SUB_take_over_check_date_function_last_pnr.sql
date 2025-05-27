    ---- Start check <%SCHEMA_2%>.<%TABLE_NAME%> - last_processing_nr ----
    err_section:='CHECK-15';    err_schema:='<%SCHEMA_2%>';    err_table:='<%SCHEMA_2%>.<%TABLE_NAME%>';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>;
    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;
    ---- End check <%SCHEMA_2%>.<%TABLE_NAME_2%> - last_processing_nr ----

