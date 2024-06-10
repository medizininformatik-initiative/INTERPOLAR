------------------------------
CREATE OR REPLACE FUNCTION db.copy_fe_fe_in_to_db_log()
RETURNS VOID AS $$
DECLARE
    record_count INT;
    current_record record;
    data_count integer;
BEGIN
    -- Copy Functionname: copy_fe_fe_in_to_db_log - From: db2frontend_in -> To: db_log
    -- Start patient_fe
    FOR current_record IN (SELECT * FROM db2frontend_in.patient_fe)
        LOOP
        BEGIN
            SELECT count(1) INTO data_count
            FROM db_log.patient_fe target_record
            WHERE   COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                    COALESCE(target_record.pat_id::text,'#NULL#') = COALESCE(current_record.pat_id::text,'#NULL#') AND
                    COALESCE(target_record.pat_name::text,'#NULL#') = COALESCE(current_record.pat_name::text,'#NULL#') AND
                    COALESCE(target_record.pat_vorname::text,'#NULL#') = COALESCE(current_record.pat_vorname::text,'#NULL#') AND
                    COALESCE(target_record.pat_gebdat::text,'#NULL#') = COALESCE(current_record.pat_gebdat::text,'#NULL#') AND
                    COALESCE(target_record.pat_aktuell_alter::text,'#NULL#') = COALESCE(current_record.pat_aktuell_alter::text,'#NULL#') AND
                    COALESCE(target_record.pat_geschlecht::text,'#NULL#') = COALESCE(current_record.pat_geschlecht::text,'#NULL#') AND
                    COALESCE(target_record.patient_complete::text,'#NULL#') = COALESCE(current_record.patient_complete::text,'#NULL#')
                  ;

            IF data_count = 0
            THEN
                INSERT INTO db_log.patient_fe (
                        patient_fe_id,
                        record_id,
                        pat_id,
                        pat_name,
                        pat_vorname,
                        pat_gebdat,
                        pat_aktuell_alter,
                        pat_geschlecht,
                        patient_complete,
                        input_datetime
                )
                VALUES (current_record.patient_fe_id,
                        current_record.record_id,
                        current_record.pat_id,
                        current_record.pat_name,
                        current_record.pat_vorname,
                        current_record.pat_gebdat,
                        current_record.pat_aktuell_alter,
                        current_record.pat_geschlecht,
                        current_record.patient_complete,
                        current_record.input_datetime
                );

                -- Delete importet datasets
                DELETE FROM db2frontend_in.patient_fe WHERE patient_fe_id = current_record.patient_fe_id;
            ELSE
	        UPDATE db_log.patient_fe target_record
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                WHERE 	COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                        COALESCE(target_record.pat_id::text,'#NULL#') = COALESCE(current_record.pat_id::text,'#NULL#') AND
                        COALESCE(target_record.pat_name::text,'#NULL#') = COALESCE(current_record.pat_name::text,'#NULL#') AND
                        COALESCE(target_record.pat_vorname::text,'#NULL#') = COALESCE(current_record.pat_vorname::text,'#NULL#') AND
                        COALESCE(target_record.pat_gebdat::text,'#NULL#') = COALESCE(current_record.pat_gebdat::text,'#NULL#') AND
                        COALESCE(target_record.pat_aktuell_alter::text,'#NULL#') = COALESCE(current_record.pat_aktuell_alter::text,'#NULL#') AND
                        COALESCE(target_record.pat_geschlecht::text,'#NULL#') = COALESCE(current_record.pat_geschlecht::text,'#NULL#') AND
                        COALESCE(target_record.patient_complete::text,'#NULL#') = COALESCE(current_record.patient_complete::text,'#NULL#')
                ;

                -- Delete updatet datasets
                DELETE FROM db2frontend_in.patient_fe WHERE patient_fe_id = current_record.patient_fe_id;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                UPDATE db2frontend_in.patient_fe
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                WHERE patient_fe_id = current_record.patient_fe_id;
        END;
    END LOOP;
    -- END patient_fe

    -- Start fall_fe
    FOR current_record IN (SELECT * FROM db2frontend_in.fall_fe)
        LOOP
        BEGIN
            SELECT count(1) INTO data_count
            FROM db_log.fall_fe target_record
            WHERE   COALESCE(target_record.fall_id::text,'#NULL#') = COALESCE(current_record.fall_id::text,'#NULL#') AND
                    COALESCE(target_record.fall_pat_id::text,'#NULL#') = COALESCE(current_record.fall_pat_id::text,'#NULL#') AND
                    COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                    COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                    COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                    COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                    COALESCE(target_record.fall_studienphase::text,'#NULL#') = COALESCE(current_record.fall_studienphase::text,'#NULL#') AND
                    COALESCE(target_record.fall_station::text,'#NULL#') = COALESCE(current_record.fall_station::text,'#NULL#') AND
                    COALESCE(target_record.fall_aufn_dat::text,'#NULL#') = COALESCE(current_record.fall_aufn_dat::text,'#NULL#') AND
                    COALESCE(target_record.fall_aufn_diag::text,'#NULL#') = COALESCE(current_record.fall_aufn_diag::text,'#NULL#') AND
                    COALESCE(target_record.fall_gewicht_aktuell::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktuell::text,'#NULL#') AND
                    COALESCE(target_record.fall_gewicht_aktl_einheit::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktl_einheit::text,'#NULL#') AND
                    COALESCE(target_record.fall_groesse::text,'#NULL#') = COALESCE(current_record.fall_groesse::text,'#NULL#') AND
                    COALESCE(target_record.fall_groesse_einheit::text,'#NULL#') = COALESCE(current_record.fall_groesse_einheit::text,'#NULL#') AND
                    COALESCE(target_record.fall_bmi::text,'#NULL#') = COALESCE(current_record.fall_bmi::text,'#NULL#') AND
                    COALESCE(target_record.fall_nieren_insuf_chron::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_chron::text,'#NULL#') AND
                    COALESCE(target_record.fall_nieren_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_ausmass::text,'#NULL#') AND
                    COALESCE(target_record.fall_nieren_insuf_dialysev::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_dialysev::text,'#NULL#') AND
                    COALESCE(target_record.fall_leber_insuf::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf::text,'#NULL#') AND
                    COALESCE(target_record.fall_leber_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf_ausmass::text,'#NULL#') AND
                    COALESCE(target_record.fall_schwanger_mo::text,'#NULL#') = COALESCE(current_record.fall_schwanger_mo::text,'#NULL#') AND
                    COALESCE(target_record.fall_op_geplant::text,'#NULL#') = COALESCE(current_record.fall_op_geplant::text,'#NULL#') AND
                    COALESCE(target_record.fall_op_dat::text,'#NULL#') = COALESCE(current_record.fall_op_dat::text,'#NULL#') AND
                    COALESCE(target_record.fall_status::text,'#NULL#') = COALESCE(current_record.fall_status::text,'#NULL#') AND
                    COALESCE(target_record.fall_ent_dat::text,'#NULL#') = COALESCE(current_record.fall_ent_dat::text,'#NULL#') AND
                    COALESCE(target_record.fall_complete::text,'#NULL#') = COALESCE(current_record.fall_complete::text,'#NULL#')
                  ;

            IF data_count = 0
            THEN
                INSERT INTO db_log.fall_fe (
                        fall_fe_id,
                        fall_id,
                        fall_pat_id,
                        patient_id_fk,
                        record_id,
                        redcap_repeat_instrument,
                        redcap_repeat_instance,
                        fall_studienphase,
                        fall_station,
                        fall_aufn_dat,
                        fall_aufn_diag,
                        fall_gewicht_aktuell,
                        fall_gewicht_aktl_einheit,
                        fall_groesse,
                        fall_groesse_einheit,
                        fall_bmi,
                        fall_nieren_insuf_chron,
                        fall_nieren_insuf_ausmass,
                        fall_nieren_insuf_dialysev,
                        fall_leber_insuf,
                        fall_leber_insuf_ausmass,
                        fall_schwanger_mo,
                        fall_op_geplant,
                        fall_op_dat,
                        fall_status,
                        fall_ent_dat,
                        fall_complete,
                        input_datetime
                )
                VALUES (current_record.fall_fe_id,
                        current_record.fall_id,
                        current_record.fall_pat_id,
                        current_record.patient_id_fk,
                        current_record.record_id,
                        current_record.redcap_repeat_instrument,
                        current_record.redcap_repeat_instance,
                        current_record.fall_studienphase,
                        current_record.fall_station,
                        current_record.fall_aufn_dat,
                        current_record.fall_aufn_diag,
                        current_record.fall_gewicht_aktuell,
                        current_record.fall_gewicht_aktl_einheit,
                        current_record.fall_groesse,
                        current_record.fall_groesse_einheit,
                        current_record.fall_bmi,
                        current_record.fall_nieren_insuf_chron,
                        current_record.fall_nieren_insuf_ausmass,
                        current_record.fall_nieren_insuf_dialysev,
                        current_record.fall_leber_insuf,
                        current_record.fall_leber_insuf_ausmass,
                        current_record.fall_schwanger_mo,
                        current_record.fall_op_geplant,
                        current_record.fall_op_dat,
                        current_record.fall_status,
                        current_record.fall_ent_dat,
                        current_record.fall_complete,
                        current_record.input_datetime
                );

                -- Delete importet datasets
                DELETE FROM db2frontend_in.fall_fe WHERE fall_fe_id = current_record.fall_fe_id;
            ELSE
	        UPDATE db_log.fall_fe target_record
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                WHERE 	COALESCE(target_record.fall_id::text,'#NULL#') = COALESCE(current_record.fall_id::text,'#NULL#') AND
                        COALESCE(target_record.fall_pat_id::text,'#NULL#') = COALESCE(current_record.fall_pat_id::text,'#NULL#') AND
                        COALESCE(target_record.patient_id_fk::text,'#NULL#') = COALESCE(current_record.patient_id_fk::text,'#NULL#') AND
                        COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                        COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                        COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                        COALESCE(target_record.fall_studienphase::text,'#NULL#') = COALESCE(current_record.fall_studienphase::text,'#NULL#') AND
                        COALESCE(target_record.fall_station::text,'#NULL#') = COALESCE(current_record.fall_station::text,'#NULL#') AND
                        COALESCE(target_record.fall_aufn_dat::text,'#NULL#') = COALESCE(current_record.fall_aufn_dat::text,'#NULL#') AND
                        COALESCE(target_record.fall_aufn_diag::text,'#NULL#') = COALESCE(current_record.fall_aufn_diag::text,'#NULL#') AND
                        COALESCE(target_record.fall_gewicht_aktuell::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktuell::text,'#NULL#') AND
                        COALESCE(target_record.fall_gewicht_aktl_einheit::text,'#NULL#') = COALESCE(current_record.fall_gewicht_aktl_einheit::text,'#NULL#') AND
                        COALESCE(target_record.fall_groesse::text,'#NULL#') = COALESCE(current_record.fall_groesse::text,'#NULL#') AND
                        COALESCE(target_record.fall_groesse_einheit::text,'#NULL#') = COALESCE(current_record.fall_groesse_einheit::text,'#NULL#') AND
                        COALESCE(target_record.fall_bmi::text,'#NULL#') = COALESCE(current_record.fall_bmi::text,'#NULL#') AND
                        COALESCE(target_record.fall_nieren_insuf_chron::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_chron::text,'#NULL#') AND
                        COALESCE(target_record.fall_nieren_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_ausmass::text,'#NULL#') AND
                        COALESCE(target_record.fall_nieren_insuf_dialysev::text,'#NULL#') = COALESCE(current_record.fall_nieren_insuf_dialysev::text,'#NULL#') AND
                        COALESCE(target_record.fall_leber_insuf::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf::text,'#NULL#') AND
                        COALESCE(target_record.fall_leber_insuf_ausmass::text,'#NULL#') = COALESCE(current_record.fall_leber_insuf_ausmass::text,'#NULL#') AND
                        COALESCE(target_record.fall_schwanger_mo::text,'#NULL#') = COALESCE(current_record.fall_schwanger_mo::text,'#NULL#') AND
                        COALESCE(target_record.fall_op_geplant::text,'#NULL#') = COALESCE(current_record.fall_op_geplant::text,'#NULL#') AND
                        COALESCE(target_record.fall_op_dat::text,'#NULL#') = COALESCE(current_record.fall_op_dat::text,'#NULL#') AND
                        COALESCE(target_record.fall_status::text,'#NULL#') = COALESCE(current_record.fall_status::text,'#NULL#') AND
                        COALESCE(target_record.fall_ent_dat::text,'#NULL#') = COALESCE(current_record.fall_ent_dat::text,'#NULL#') AND
                        COALESCE(target_record.fall_complete::text,'#NULL#') = COALESCE(current_record.fall_complete::text,'#NULL#')
                ;

                -- Delete updatet datasets
                DELETE FROM db2frontend_in.fall_fe WHERE fall_fe_id = current_record.fall_fe_id;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                UPDATE db2frontend_in.fall_fe
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                WHERE fall_fe_id = current_record.fall_fe_id;
        END;
    END LOOP;
    -- END fall_fe

    -- Start medikationsanalyse_fe
    FOR current_record IN (SELECT * FROM db2frontend_in.medikationsanalyse_fe)
        LOOP
        BEGIN
            SELECT count(1) INTO data_count
            FROM db_log.medikationsanalyse_fe target_record
            WHERE   COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                    COALESCE(target_record.fall_id_fk::text,'#NULL#') = COALESCE(current_record.fall_id_fk::text,'#NULL#') AND
                    COALESCE(target_record.meda_fall_id::text,'#NULL#') = COALESCE(current_record.meda_fall_id::text,'#NULL#') AND
                    COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                    COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                    COALESCE(target_record.meda_dat::text,'#NULL#') = COALESCE(current_record.meda_dat::text,'#NULL#') AND
                    COALESCE(target_record.meda_typ::text,'#NULL#') = COALESCE(current_record.meda_typ::text,'#NULL#') AND
                    COALESCE(target_record.meda_risiko_pat::text,'#NULL#') = COALESCE(current_record.meda_risiko_pat::text,'#NULL#') AND
                    COALESCE(target_record.meda_ma_thueberw::text,'#NULL#') = COALESCE(current_record.meda_ma_thueberw::text,'#NULL#') AND
                    COALESCE(target_record.meda_aufwand_zeit::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit::text,'#NULL#') AND
                    COALESCE(target_record.meda_aufwand_zeit_and::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit_and::text,'#NULL#') AND
                    COALESCE(target_record.meda_notiz::text,'#NULL#') = COALESCE(current_record.meda_notiz::text,'#NULL#') AND
                    COALESCE(target_record.medikationsanalyse_complete::text,'#NULL#') = COALESCE(current_record.medikationsanalyse_complete::text,'#NULL#')
                  ;

            IF data_count = 0
            THEN
                INSERT INTO db_log.medikationsanalyse_fe (
                        medikationsanalyse_fe_id,
                        record_id,
                        fall_id_fk,
                        meda_fall_id,
                        redcap_repeat_instrument,
                        redcap_repeat_instance,
                        meda_dat,
                        meda_typ,
                        meda_risiko_pat,
                        meda_ma_thueberw,
                        meda_aufwand_zeit,
                        meda_aufwand_zeit_and,
                        meda_notiz,
                        medikationsanalyse_complete,
                        input_datetime
                )
                VALUES (current_record.medikationsanalyse_fe_id,
                        current_record.record_id,
                        current_record.fall_id_fk,
                        current_record.meda_fall_id,
                        current_record.redcap_repeat_instrument,
                        current_record.redcap_repeat_instance,
                        current_record.meda_dat,
                        current_record.meda_typ,
                        current_record.meda_risiko_pat,
                        current_record.meda_ma_thueberw,
                        current_record.meda_aufwand_zeit,
                        current_record.meda_aufwand_zeit_and,
                        current_record.meda_notiz,
                        current_record.medikationsanalyse_complete,
                        current_record.input_datetime
                );

                -- Delete importet datasets
                DELETE FROM db2frontend_in.medikationsanalyse_fe WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
            ELSE
	        UPDATE db_log.medikationsanalyse_fe target_record
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                WHERE 	COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                        COALESCE(target_record.fall_id_fk::text,'#NULL#') = COALESCE(current_record.fall_id_fk::text,'#NULL#') AND
                        COALESCE(target_record.meda_fall_id::text,'#NULL#') = COALESCE(current_record.meda_fall_id::text,'#NULL#') AND
                        COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                        COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                        COALESCE(target_record.meda_dat::text,'#NULL#') = COALESCE(current_record.meda_dat::text,'#NULL#') AND
                        COALESCE(target_record.meda_typ::text,'#NULL#') = COALESCE(current_record.meda_typ::text,'#NULL#') AND
                        COALESCE(target_record.meda_risiko_pat::text,'#NULL#') = COALESCE(current_record.meda_risiko_pat::text,'#NULL#') AND
                        COALESCE(target_record.meda_ma_thueberw::text,'#NULL#') = COALESCE(current_record.meda_ma_thueberw::text,'#NULL#') AND
                        COALESCE(target_record.meda_aufwand_zeit::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit::text,'#NULL#') AND
                        COALESCE(target_record.meda_aufwand_zeit_and::text,'#NULL#') = COALESCE(current_record.meda_aufwand_zeit_and::text,'#NULL#') AND
                        COALESCE(target_record.meda_notiz::text,'#NULL#') = COALESCE(current_record.meda_notiz::text,'#NULL#') AND
                        COALESCE(target_record.medikationsanalyse_complete::text,'#NULL#') = COALESCE(current_record.medikationsanalyse_complete::text,'#NULL#')
                ;

                -- Delete updatet datasets
                DELETE FROM db2frontend_in.medikationsanalyse_fe WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                UPDATE db2frontend_in.medikationsanalyse_fe
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                WHERE medikationsanalyse_fe_id = current_record.medikationsanalyse_fe_id;
        END;
    END LOOP;
    -- END medikationsanalyse_fe

    -- Start mrpdokumentation_validierung_fe
    FOR current_record IN (SELECT * FROM db2frontend_in.mrpdokumentation_validierung_fe)
        LOOP
        BEGIN
            SELECT count(1) INTO data_count
            FROM db_log.mrpdokumentation_validierung_fe target_record
            WHERE   COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                    COALESCE(target_record.meda_id_fk::text,'#NULL#') = COALESCE(current_record.meda_id_fk::text,'#NULL#') AND
                    COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                    COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                    COALESCE(target_record.mrp_entd_dat::text,'#NULL#') = COALESCE(current_record.mrp_entd_dat::text,'#NULL#') AND
                    COALESCE(target_record.mrp_kurzbeschr::text,'#NULL#') = COALESCE(current_record.mrp_kurzbeschr::text,'#NULL#') AND
                    COALESCE(target_record.mrp_entd_algorithmisch::text,'#NULL#') = COALESCE(current_record.mrp_entd_algorithmisch::text,'#NULL#') AND
                    COALESCE(target_record.mrp_hinweisgeber::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber::text,'#NULL#') AND
                    COALESCE(target_record.mrp_gewissheit::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit::text,'#NULL#') AND
                    COALESCE(target_record.mrp_gewiss_grund_abl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl::text,'#NULL#') AND
                    COALESCE(target_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') AND
                    COALESCE(target_record.mrp_wirkstoff::text,'#NULL#') = COALESCE(current_record.mrp_wirkstoff::text,'#NULL#') AND
                    COALESCE(target_record.mrp_atc1::text,'#NULL#') = COALESCE(current_record.mrp_atc1::text,'#NULL#') AND
                    COALESCE(target_record.mrp_atc2::text,'#NULL#') = COALESCE(current_record.mrp_atc2::text,'#NULL#') AND
                    COALESCE(target_record.mrp_atc3::text,'#NULL#') = COALESCE(current_record.mrp_atc3::text,'#NULL#') AND
                    COALESCE(target_record.mrp_med_prod::text,'#NULL#') = COALESCE(current_record.mrp_med_prod::text,'#NULL#') AND
                    COALESCE(target_record.mrp_med_prod_sonst::text,'#NULL#') = COALESCE(current_record.mrp_med_prod_sonst::text,'#NULL#') AND
                    COALESCE(target_record.mrp_dokup_fehler::text,'#NULL#') = COALESCE(current_record.mrp_dokup_fehler::text,'#NULL#') AND
                    COALESCE(target_record.mrp_dokup_intervention::text,'#NULL#') = COALESCE(current_record.mrp_dokup_intervention::text,'#NULL#') AND
                    COALESCE(target_record.mrp_pigrund::text,'#NULL#') = COALESCE(current_record.mrp_pigrund::text,'#NULL#') AND
                    COALESCE(target_record.mrp_ip_klasse::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse::text,'#NULL#') AND
                    COALESCE(target_record.mrp_ip_klasse_disease::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_disease::text,'#NULL#') AND
                    COALESCE(target_record.mrp_ip_klasse_labor::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_labor::text,'#NULL#') AND
                    COALESCE(target_record.mrp_massn_am::text,'#NULL#') = COALESCE(current_record.mrp_massn_am::text,'#NULL#') AND
                    COALESCE(target_record.mrp_massn_orga::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga::text,'#NULL#') AND
                    COALESCE(target_record.mrp_notiz::text,'#NULL#') = COALESCE(current_record.mrp_notiz::text,'#NULL#') AND
                    COALESCE(target_record.mrp_dokup_hand_emp_akz::text,'#NULL#') = COALESCE(current_record.mrp_dokup_hand_emp_akz::text,'#NULL#') AND
                    COALESCE(target_record.mrp_merp::text,'#NULL#') = COALESCE(current_record.mrp_merp::text,'#NULL#') AND
                    COALESCE(target_record.mrp_wiedervorlage::text,'#NULL#') = COALESCE(current_record.mrp_wiedervorlage::text,'#NULL#') AND
                    COALESCE(target_record.mrpdokumentation_validierung_complete::text,'#NULL#') = COALESCE(current_record.mrpdokumentation_validierung_complete::text,'#NULL#')
                  ;

            IF data_count = 0
            THEN
                INSERT INTO db_log.medikationsanalyse_fe (
                        mrpdokumentation_validierung_fe_id,
                        record_id,
                        meda_id_fk,
                        redcap_repeat_instrument,
                        redcap_repeat_instance,
                        mrp_entd_dat,
                        mrp_kurzbeschr,
                        mrp_entd_algorithmisch,
                        mrp_hinweisgeber,
                        mrp_gewissheit,
                        mrp_gewiss_grund_abl,
                        mrp_gewiss_grund_abl_sonst,
                        mrp_wirkstoff,
                        mrp_atc1,
                        mrp_atc2,
                        mrp_atc3,
                        mrp_med_prod,
                        mrp_med_prod_sonst,
                        mrp_dokup_fehler,
                        mrp_dokup_intervention,
                        mrp_pigrund,
                        mrp_ip_klasse,
                        mrp_ip_klasse_disease,
                        mrp_ip_klasse_labor,
                        mrp_massn_am,
                        mrp_massn_orga,
                        mrp_notiz,
                        mrp_dokup_hand_emp_akz,
                        mrp_merp,
                        mrp_wiedervorlage,
                        mrpdokumentation_validierung_complete,
                        input_datetime
                )
                VALUES (current_record.mrpdokumentation_validierung_fe_id,
                        current_record.record_id,
                        current_record.meda_id_fk,
                        current_record.redcap_repeat_instrument,
                        current_record.redcap_repeat_instance,
                        current_record.mrp_entd_dat,
                        current_record.mrp_kurzbeschr,
                        current_record.mrp_entd_algorithmisch,
                        current_record.mrp_hinweisgeber,
                        current_record.mrp_gewissheit,
                        current_record.mrp_gewiss_grund_abl,
                        current_record.mrp_gewiss_grund_abl_sonst,
                        current_record.mrp_wirkstoff,
                        current_record.mrp_atc1,
                        current_record.mrp_atc2,
                        current_record.mrp_atc3,
                        current_record.mrp_med_prod,
                        current_record.mrp_med_prod_sonst,
                        current_record.mrp_dokup_fehler,
                        current_record.mrp_dokup_intervention,
                        current_record.mrp_pigrund,
                        current_record.mrp_ip_klasse,
                        current_record.mrp_ip_klasse_disease,
                        current_record.mrp_ip_klasse_labor,
                        current_record.mrp_massn_am,
                        current_record.mrp_massn_orga,
                        current_record.mrp_notiz,
                        current_record.mrp_dokup_hand_emp_akz,
                        current_record.mrp_merp,
                        current_record.mrp_wiedervorlage,
                        current_record.mrpdokumentation_validierung_complete,
                        current_record.input_datetime
                );

                -- Delete importet datasets
                DELETE FROM db2frontend_in.mrpdokumentation_validierung_fe WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
            ELSE
	        UPDATE db_log.mrpdokumentation_validierung_fe target_record
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'Last Time the same Dataset : '||CURRENT_TIMESTAMP
                WHERE 	COALESCE(target_record.record_id::text,'#NULL#') = COALESCE(current_record.record_id::text,'#NULL#') AND
                        COALESCE(target_record.meda_id_fk::text,'#NULL#') = COALESCE(current_record.meda_id_fk::text,'#NULL#') AND
                        COALESCE(target_record.redcap_repeat_instrument::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instrument::text,'#NULL#') AND
                        COALESCE(target_record.redcap_repeat_instance::text,'#NULL#') = COALESCE(current_record.redcap_repeat_instance::text,'#NULL#') AND
                        COALESCE(target_record.mrp_entd_dat::text,'#NULL#') = COALESCE(current_record.mrp_entd_dat::text,'#NULL#') AND
                        COALESCE(target_record.mrp_kurzbeschr::text,'#NULL#') = COALESCE(current_record.mrp_kurzbeschr::text,'#NULL#') AND
                        COALESCE(target_record.mrp_entd_algorithmisch::text,'#NULL#') = COALESCE(current_record.mrp_entd_algorithmisch::text,'#NULL#') AND
                        COALESCE(target_record.mrp_hinweisgeber::text,'#NULL#') = COALESCE(current_record.mrp_hinweisgeber::text,'#NULL#') AND
                        COALESCE(target_record.mrp_gewissheit::text,'#NULL#') = COALESCE(current_record.mrp_gewissheit::text,'#NULL#') AND
                        COALESCE(target_record.mrp_gewiss_grund_abl::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl::text,'#NULL#') AND
                        COALESCE(target_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') = COALESCE(current_record.mrp_gewiss_grund_abl_sonst::text,'#NULL#') AND
                        COALESCE(target_record.mrp_wirkstoff::text,'#NULL#') = COALESCE(current_record.mrp_wirkstoff::text,'#NULL#') AND
                        COALESCE(target_record.mrp_atc1::text,'#NULL#') = COALESCE(current_record.mrp_atc1::text,'#NULL#') AND
                        COALESCE(target_record.mrp_atc2::text,'#NULL#') = COALESCE(current_record.mrp_atc2::text,'#NULL#') AND
                        COALESCE(target_record.mrp_atc3::text,'#NULL#') = COALESCE(current_record.mrp_atc3::text,'#NULL#') AND
                        COALESCE(target_record.mrp_med_prod::text,'#NULL#') = COALESCE(current_record.mrp_med_prod::text,'#NULL#') AND
                        COALESCE(target_record.mrp_med_prod_sonst::text,'#NULL#') = COALESCE(current_record.mrp_med_prod_sonst::text,'#NULL#') AND
                        COALESCE(target_record.mrp_dokup_fehler::text,'#NULL#') = COALESCE(current_record.mrp_dokup_fehler::text,'#NULL#') AND
                        COALESCE(target_record.mrp_dokup_intervention::text,'#NULL#') = COALESCE(current_record.mrp_dokup_intervention::text,'#NULL#') AND
                        COALESCE(target_record.mrp_pigrund::text,'#NULL#') = COALESCE(current_record.mrp_pigrund::text,'#NULL#') AND
                        COALESCE(target_record.mrp_ip_klasse::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse::text,'#NULL#') AND
                        COALESCE(target_record.mrp_ip_klasse_disease::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_disease::text,'#NULL#') AND
                        COALESCE(target_record.mrp_ip_klasse_labor::text,'#NULL#') = COALESCE(current_record.mrp_ip_klasse_labor::text,'#NULL#') AND
                        COALESCE(target_record.mrp_massn_am::text,'#NULL#') = COALESCE(current_record.mrp_massn_am::text,'#NULL#') AND
                        COALESCE(target_record.mrp_massn_orga::text,'#NULL#') = COALESCE(current_record.mrp_massn_orga::text,'#NULL#') AND
                        COALESCE(target_record.mrp_notiz::text,'#NULL#') = COALESCE(current_record.mrp_notiz::text,'#NULL#') AND
                        COALESCE(target_record.mrp_dokup_hand_emp_akz::text,'#NULL#') = COALESCE(current_record.mrp_dokup_hand_emp_akz::text,'#NULL#') AND
                        COALESCE(target_record.mrp_merp::text,'#NULL#') = COALESCE(current_record.mrp_merp::text,'#NULL#') AND
                        COALESCE(target_record.mrp_wiedervorlage::text,'#NULL#') = COALESCE(current_record.mrp_wiedervorlage::text,'#NULL#') AND
                        COALESCE(target_record.mrpdokumentation_validierung_complete::text,'#NULL#') = COALESCE(current_record.mrpdokumentation_validierung_complete::text,'#NULL#')
                ;

                -- Delete updatet datasets
                DELETE FROM db2frontend_in.mrpdokumentation_validierung_fe WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                UPDATE db2frontend_in.mrpdokumentation_validierung_fe
                SET last_check_datetime = CURRENT_TIMESTAMP
                , current_dataset_status = 'ERROR func: copy_fe_fe_in_to_db_log'
                WHERE mrpdokumentation_validierung_fe_id = current_record.mrpdokumentation_validierung_fe_id;
        END;
    END LOOP;
    -- END mrpdokumentation_validierung_fe
END;
$$ LANGUAGE plpgsql;

-- CopyJob FrontEnd-Data Dataproc_in 2 DB_log
SELECT cron.schedule('*/1 * * * *', 'SELECT db.copy_fe_fe_in_to_db_log();');
-----------------------------
