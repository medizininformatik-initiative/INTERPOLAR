-- ###################### PARAMETER ############################
-- >>>> WICHTIG Standort / Zeitabhängig <<<<
insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('release_version','2.9','GitHup release version');
--update db_config.db_parameter set parameter_value='?' where parameter_name='release_version';

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('release_version_date','2025-02-14','GitHup release version');
--update db_config.db_parameter set parameter_value='YYYY-MM-DD' where parameter_name='release_version_date';

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('project_participants','IMISE Leipzig','project participants to distinguish between different instances');
--update db_config.db_parameter set parameter_value='?' where parameter_name='project_participants';
-- >>>> WICHTIG <<<<

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('database_initialization_time',to_char(CURRENT_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS'),'Timestamp of database initialization');
--update db_config.db_parameter set parameter_value='?' where parameter_name='database_initialization_time';

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('pause_after_process_execution','10','Pause after copy process execution in second [5-30 sec]');
--update db_config.db_parameter set parameter_value='?' where parameter_name='pause_after_process_execution';

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('data_import_hist_every_dataset','no','Documentation of each individual data record (db_log.data_import_hist) in all the transfer functions [yes|no]');
--update db_config.db_parameter set parameter_value='?' where parameter_name='data_import_hist_every_dataset';

insert into db_config.db_parameter (parameter_name, parameter_value, parameter_description)
values ('max_process_time_set_ready','120','Maximum time that the semaphore may remain in use before it is released again in minutes [5-120]');
--update db_config.db_parameter set parameter_value='?' where parameter_name='max_process_time_set_ready';
