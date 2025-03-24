-- Anlegen einer Tabelle für Infos zum Test
CREATE TABLE IF NOT EXISTS db_log.test_log (
  test_log_id serial PRIMARY KEY not null, -- Primary key of the entity
  ent_name varchar,
  ent_ident varchar,
  ent_id varchar,
  text1 varchar,
  text2 varchar,
  text3 varchar,
  text4 varchar,
  text5 varchar,
  text6 varchar,
  text7 varchar,
  text8 varchar,
  text9 varchar,
  input_datetime timestamp not null default CURRENT_TIMESTAMP   -- Time at which the data record is inserted
);

GRANT SELECT, INSERT ON db_log.test_log TO db_log_user;