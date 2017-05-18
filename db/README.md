# README

## Database

### Preparation

1. Install _PostgreSQL_ (server and client)
2. Set password for user _postgres_
3. Verify installation by running _psql_

### Working with database

* To create database run _sh create_db.sh_
* To drop database run _sh drop_db.sh_
* Each time you run commands you will be asked for password for user _postgres_. You can either:
  * Supply password each time
  * Set environment variable _PGPASSWORD_ (e.g. PGPASSWORD=pass1234) **NOT RECOMMENDED**
  * Create _.pgpass_ file (see: [documentation](https://www.postgresql.org/docs/8.3/static/libpq-pgpass.html "pgpass documentation"))
* Scripts are in progress, so will likely change in near future, but should be functional and their primary objective and usage will remain the same
