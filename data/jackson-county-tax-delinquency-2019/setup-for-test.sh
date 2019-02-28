#!/bin/sh

#
# Recreate the databases
#

# Need to drop databases first

sudo -u postgres dropdb address_api
sudo -u postgres dropdb code4kc

SQL=$(cat <<EOF
CREATE DATABASE address_api  WITH ENCODING 'UTF8' TEMPLATE=template0;
GRANT ALL PRIVILEGES ON DATABASE address_api TO c4kc;

CREATE DATABASE code4kc  WITH ENCODING 'UTF8' TEMPLATE=template0;
GRANT ALL PRIVILEGES ON DATABASE code4kc TO c4kc;

\q
EOF
)

echo "${SQL}" | sudo -u postgres psql

echo "\n\n----- setup post gis -----\n\n"

#
# For some unknown resone I had to load the extension separatly
#
SQL=$(cat <<EOF

CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION ogr_fdw;

\q
EOF
)

echo "${SQL}" | sudo -u postgres psql code4kc


echo "\n\n------ load the backups -----\n\n"

#
# Load the backups
#
(
    cd /var/www/dumps
    cd /tmp

    echo "\n\n------ load address_api -----\n\n"
    sudo -u postgres pg_restore -C -d address_api address_api-20190227-0402.dump
    echo "\n\n------ load code4kc -----\n\n"
    sudo -u postgres pg_restore -C -d code4kc code4kc-20190227-0402.dump

)
sudo service postgresql stop
sudo service postgresql start

#
# INSTALL THIS RELEASE
# Fix Permissions
#
(
   cd /var/www/data/scripts
#   sudo -u postgres psql -f fix_ownerships.psql
)



