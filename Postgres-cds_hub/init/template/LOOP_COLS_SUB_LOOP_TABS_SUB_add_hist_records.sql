        -- Nachladen von <%OWNER_SCHEMA%>.<%TABLE_NAME%> passend zu Einträgen aus <%SCHEMA_2%>.<%TABLE_NAME_2%>
        FOR rec in (SELECT * FROM <%OWNER_SCHEMA%>.TABLE_NAME_REFERENCE_TYPES q    -- Tabellenname aus REFERENCE_TYPES und Angaben aus User_Def. für TABLE_NAME zusammensetzen 
	    WHERE q.REFERENCE_ID_COLUMN_NAME IN (SELECT <%COLUMN_NAME%> FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>) -- Zugehörige Spalte REFERENCE_ID_COLUMN_NAME zu REFERENCE_TYPES
	    AND q.hash_index_col NOT IN (SELECT hash_index_col FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
        ) LOOP
            temp:=rec.enc_id::TEXT;
        END LOOP;
