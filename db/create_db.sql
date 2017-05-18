CREATE DATABASE sius_2017
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'Polish_Poland.1250'
       LC_CTYPE = 'Polish_Poland.1250'
       CONNECTION LIMIT = -1;

ALTER DATABASE sius_2017
  SET search_path = "$user", public, tiger;

COMMENT ON DATABASE sius_2017
  IS 'DB for SIUS project';