
    SELECT
      (SELECT COUNT(*) FROM db2dataprocessor_out.v_pids_per_ward w
       LEFT JOIN db2dataprocessor_out.v_encounter_last_version e ON e.enc_id=w.encounter_id
       WHERE e.enc_id IS NULL OR e.enc_period_start IS NULL
         OR e.enc_main_encounter_calculated_ref IS NULL
         OR NOT EXISTS (SELECT 1 FROM db2dataprocessor_out.v_encounter_last_version h
            WHERE 'Encounter/'||h.enc_id=e.enc_main_encounter_calculated_ref
              AND h.enc_type_code='einrichtungskontakt')
         OR NOT EXISTS (SELECT 1 FROM study_periods p WHERE p.ward_name=w.ward_name)) AS invalid_contacts,
      (SELECT COUNT(*) FROM (SELECT case_ref FROM ip_contacts
         WHERE ward_start=first_ip_start GROUP BY case_ref
         HAVING COUNT(DISTINCT ward_name)>1) t) AS ambiguous_first_contacts,
      (SELECT COUNT(*) FROM eligible_cases) AS study_cases
