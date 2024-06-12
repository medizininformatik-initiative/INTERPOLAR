-- Example for creating the database (in either MariaDB or MySQL)
CREATE DATABASE IF NOT EXISTS `redcap`;

-- (MARIADB ONLY) Example for creating the MariaDB user (replace the user and password with your own values)
-- CREATE USER 'redcap'@'%' IDENTIFIED BY 'password_for_redcap_user';
GRANT SELECT, INSERT, UPDATE, DELETE ON `redcap`.* TO 'redcap'@'%';

