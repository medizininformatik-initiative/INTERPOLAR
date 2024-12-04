    UNION SELECT DISTINCT last_processing_nr
    FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE <%TABLE_NAME%>_id IN 
            (SELECT <%TABLE_NAME%>_id FROM <%SCHEMA_2%>.<%TABLE_NAME_2%> WHERE last_processing_nr=(SELECT MAX(last_processing_nr) FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
            )
         )
    AND last_processing_nr!=(SELECT MAX(last_processing_nr) FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>)
