-------------- Tabelle für die einmalige berechnung der Referenzen für "Altdaten" --------------------- 
DO
$$
BEGIN
    IF NOT EXISTS ( -- Table exists
        SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'cds2db_in' AND table_name = 'temp_calculated_items'
    ) THEN

        CREATE TABLE IF NOT EXISTS cds2db_in.temp_calculated_items (
          cal_schema VARCHAR         -- Ziel für die Berechnung
          , cal_resource VARCHAR     -- Resourcce für welche etwas berechnet werden soll
          , cal_fhir_column VARCHAR  -- Spaltenname der FHIR ID
          , cal_fhir_id VARCHAR      -- FHIR ID auf die geändert werden soll
          , cal_calculated_column_name VARCHAR  -- Name der berechneten Spalte
          , cal_calculated_value VARCHAR        -- Wert der berechneten Spalte
          , cal_theme VARCHAR        -- Zur Info was berechnet wurde z.b. "calculated refs"
          , input_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP -- Time at which data record was created
         );       

         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_schema IS 'Ziel für die Berechnung';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_resource IS 'Resourcce für welche etwas berechnet werden soll';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_fhir_column IS 'Spaltenname der FHIR ID';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_fhir_id IS 'FHIR ID auf die geändert werden soll';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_calculated_column_name IS 'Name der berechneten Spalte';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_calculated_value IS 'Wert der berechneten Spalte';
         COMMENT ON COLUMN cds2db_in.temp_calculated_items.cal_theme IS 'Info was berechnet wurde';

         CREATE INDEX idx_temp_calculated_items_cal_fhir_id ON cds2db_in.temp_calculated_items USING btree (cal_fhir_id);

         GRANT INSERT, DELETE, UPDATE, SELECT ON TABLE cds2db_in.temp_calculated_items TO cds2db_user; -- Additional authorizations for testing
    END IF; -- Table exists
END
$$;
