-------------- Tabelle für die einmalige berechnung der Referenzen für "Altdaten" - nur temporär daher wieder löschen --------------------- 
DO
$$
BEGIN
    IF EXISTS ( -- Table exists
        SELECT 1 s FROM information_schema.columns 
        WHERE table_schema = 'cds2db_in' AND table_name = 'temp_calculated_items'
    ) THEN
        DROP TABLE Icds2db_in.temp_calculated_items;
    END IF; -- Table exists
END
$$;
