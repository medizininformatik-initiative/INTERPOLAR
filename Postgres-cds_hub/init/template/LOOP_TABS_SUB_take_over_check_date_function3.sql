    UNION SELECT COUNT(1) AS anz, MAX(max_<%TABLE_NAME_2%>) AS lpn
    FROM <%SCHEMA_2%>.<%TABLE_NAME%>, max_last_processing
    WHERE last_processing_nr IN
        (SELECT last_processing_nr FROM <%SCHEMA_2%>.<%TABLE_NAME%> WHERE <%TABLE_NAME%>_id IN 
            (SELECT <%TABLE_NAME%>_id FROM <%SCHEMA_2%>.<%TABLE_NAME_2%>, max_last_processing
             WHERE last_processing_nr=max_last_processing.max_<%TABLE_NAME_2%>
            )
         )
    AND last_processing_nr!=(SELECT max_<%TABLE_NAME_2%> FROM max_last_processing)
