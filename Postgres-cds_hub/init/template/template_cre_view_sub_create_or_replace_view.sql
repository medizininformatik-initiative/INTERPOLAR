-- CREATE OR REPLACE VIEW cds2db_out.v_encounter AS (select * from cds2db_in.Encounter_raw where encounter_raw_id not in (select encounter_id from cds2db_in.Encounter));
CREATE OR REPLACE VIEW <%OWNER_SCHEMA%>.<%TABLE_NAME%> AS (select * from <%SCHEMA_2%>.<%TABLE_NAME_2%> where <%TABLE_NAME_2%>_id not in (select <%TABLE_NAME%>_id from <%SCHEMA_2%>.<%SIMPLE_TABLENAME%>));
