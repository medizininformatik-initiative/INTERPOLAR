    ---- Start check <%SCHEMA_2%>.<%TABLE_NAME%> - last_processing_nr ----
    err_section:='CHECK-15';    err_schema:='<%SCHEMA_2%>';    err_table:='<%SCHEMA_2%>.<%TABLE_NAME%>';
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>;
    SELECT COALESCE(MAX(last_processing_nr),0) INTO max_ent_pro_nr2 FROM <%SCHEMA_2%>.<%TABLE_NAME%>;

    IF COALESCE(max_ent_pro_nr,0)>COALESCE(max_last_pro_nr,0) THEN max_last_pro_nr:=COALESCE(max_ent_pro_nr,0); END IF;
    IF COALESCE(max_ent_pro_nr2,0)>COALESCE(max_ent_pro_nr,0) AND COALESCE(max_ent_pro_nr,0)>0 THEN data_count_raw_to_typed:=max_ent_pro_nr2; END IF; -- Datasets with lpn_raw>lpn_typed - set with last_processing_number
    ---- End check <%SCHEMA_2%>.<%TABLE_NAME_2%> - last_processing_nr ----

