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

<%LOOP_TABS_SUB_add_hist_records%>

RETURN 'ende';
END;
$$ LANGUAGE plpgsql;
