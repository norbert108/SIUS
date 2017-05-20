#!/bin/bash

# Create database
psql -U postgres -f ./create_db.sql

# Create database extensions
psql -U postgres -d sius_2017 -f ./create_db_extensions.sql

# Create database structure
psql -U postgres -d sius_2017 -f ./create_db_structure.sql