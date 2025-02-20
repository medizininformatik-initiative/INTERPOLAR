CREATE OR REPLACE FUNCTION db.test()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
temp VARCHAR;
BEGIN
-- Quelle der einzelnen Blöcke für ENCOUNTER
-- Selbstreferenz - TableDes. Zeile 21
-- Refernz zu anderer Tabelle Zeile 57

-- Nachladen von encounter passend zu einträgen aus encounter
FOR rec in (SELECT * FROM cds2db_out.v_encounter_raw_last_version q
	    WHERE q.enc_patient_ref IN (SELECT enc_patient_ref FROM cds2db_in.encounter_raw)
	    AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.encounter_raw)
           ) LOOP
	       temp:=rec.enc_id::TEXT;
END LOOP;

-- Nachladen von encounter passend zu einträgen aus encounter
FOR rec in (SELECT * FROM cds2db_out.v_location_raw_last_version q
	    WHERE q.loc_id IN (SELECT enc_location_ref FROM cds2db_in.encounter_raw)
	    AND q.hash_index_col NOT IN (SELECT hash_index_col FROM cds2db_in.location_raw)
           ) LOOP
	       temp:=rec.enc_id::TEXT;
END LOOP;

RETURN 'ende';
END;
$$ LANGUAGE plpgsql;
