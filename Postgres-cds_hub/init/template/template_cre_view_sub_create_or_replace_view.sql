-- CREATE OR REPLACE VIEW cds2db_out.v_encounter AS (select * from cds2db_in.Encounter_raw where encounter_raw_id not in (select encounter_id from cds2db_in.Encounter));
-- nicht den TablePrefix v_ im <%%TABLE_NAME%%> vergessen !!!
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%%TABLE_NAME%%> AS (select * from cds2db_in.Encounter_raw where encounter_raw_id not in (select encounter_id from cds2db_in.Encounter));
