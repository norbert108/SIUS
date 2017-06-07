# README

# Public endpoints

https://sius.herokuapp.com/initialise  (GET)  
https://sius.herokuapp.com/coords      (GET - int id)  
https://sius.herokuapp.com/update  (PUT - int id, double lat, double long)
# Database

### Preparation

1. Install _PostgreSQL_ (server and client)
2. Set password for user _postgres_
3. Verify installation by running _psql_

### Install PostGIS

1. Install _PostGIS_ extensions to your _PostgreSQL_ installation (see: [documentation](http://postgis.net/install/ "install documentation"))
2. Now it should be possible to create PostGIS extensions in database

### Working with database

* To create database run _sh create_db.sh_
  * In first step script creates database object
  * Then adds necessary extensions
  * Finally creates whole database structure
* To drop database run _sh drop_db.sh_
* Each time you run commands you will be asked for password for user _postgres_. You can either:
  * Supply password each time
  * Set environment variable _PGPASSWORD_ (e.g. PGPASSWORD=pass1234) **NOT RECOMMENDED**
  * Create _.pgpass_ file (see: [documentation](https://www.postgresql.org/docs/8.3/static/libpq-pgpass.html "pgpass documentation"))
* Scripts are in progress, so will likely change in near future, but should be functional and their primary objective and usage will remain the same

### API

* When starting application call method _api.sign_in_
  * This methods creates new object(or user) in database and returns it's ID or if object already existed returns it's ID
  * Object ID is needed to update it's position
  * Parameters:
    * __i_obj_name__ (_string_) - Object name (__mandatory__)
    * __i_obj_desc__ (_string_) - Object description (__optional__)
    * __i_obj_device__ (_string_) - Object device identificator (__optional__)
    * __i_obj_data__ (_json_) - Object configuration parameters (__optional__)
    * __i_obj_access_key__ (_uuid_) - Object access key used for checking if user has been created previously (__mandatory__)
  * Returns: _integer_ - Object ID
* Periodically call method _api.update_position_
  * This method updates object position with given latitude and longitude and returns all positions within given radius
  * Parameters:
    * __i_obj_id__ (_integer_) - Object ID (__mandatory__)
    * __i_latitude__ (_double_) - Position latitude (__mandatory__)
    * __i_longitude__ (_double_) - Position longitude (__mandatory__)
    * __i_radius__ (_double_) - Search radius (__mandatory__)
  * Returns: _list_ - List object with _dict_ elements of structure:
    * __o_pos_id__ (_integer_) - Position ID
    * __o_latitude__ (_double_) - Position latitude
    * __o_longitude__ (_double_) - Position longitude
