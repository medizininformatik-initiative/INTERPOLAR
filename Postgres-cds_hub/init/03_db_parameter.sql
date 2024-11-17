-- ###################### PARAMETER ############################
-- >>>> WICHTIG Standort / Zeitabhängig <<<<
insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('release_version','2.5','GitHup release version');

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('project_participants','IMISE Leipzig','project participants to distinguish between different instances');
-- >>>> WICHTIG <<<<

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('database_initialization_time',to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS'),'Timestamp of database initialization');

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('pause_after_process_execution','20','Pause after copy process execution in second [10-45 sec]');