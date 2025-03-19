-- <%OWNER_SCHEMA%>.<%TABLE_NAME%>
------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION <%OWNER_SCHEMA%>.<%TABLE_NAME%>_ins_fkt()
RETURNS TRIGGER 
SECURITY DEFINER
AS $$
BEGIN
    -- Entering a data record ID if the data record was created for the first time in the FrontEnd and cannot yet have an ID in the database
    IF NEW.<%TABLE_NAME%>_id IS NULL THEN
        NEW.<%TABLE_NAME%>_id := nextval('db.db_seq'); -- New Primary key of the entity
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER <%TABLE_NAME%>_tr_ins
  BEFORE INSERT
  ON  <%OWNER_SCHEMA%>.<%TABLE_NAME%>
  FOR EACH ROW
  EXECUTE PROCEDURE <%OWNER_SCHEMA%>.<%TABLE_NAME%>_ins_fkt();