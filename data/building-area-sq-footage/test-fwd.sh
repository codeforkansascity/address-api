#/bin/sh
#
# Will need to extract
#

SCRIPT_PATH=`dirname $0`


#
# Create a Foreign Data Wrapper to connect to the CSV file
#
SQL=$(cat <<EOF
DROP SERVER import;
DROP EXTENSION file_fdw;


CREATE EXTENSION file_fdw;
CREATE SERVER import FOREIGN DATA WRAPPER file_fdw;
EOF
)

echo "${SQL}" | sudo -u postgres psql address_api

#
# Create sample CREATE
#
head -n 1 kcblgdapproxarea.csv  | tr '[:upper:]' '[:lower:]' | sed -e 's/[^,a-zA-Z0-9\r]/_/g' | sed -e 's/,/ text, /g' \
  | awk -v spath="`pwd`" '{print "CREATE FOREIGN TABLE building_area (" $0 "  text) SERVER import OPTIONS ( filename \47" spath "/kcblgdapproxarea.csv\47, format \47csv\47 );"}' \
  | sudo -u postgres psql address_api
#
# Final CREATE with bldgsqft being NUMERIC
#
echo "CREATE FOREIGN TABLE building_area (id text, bldgsqft NUMERIC(10,1), kivapin  text) SERVER import OPTIONS ( filename '"`pwd`"/kcblgdapproxarea.csv', format 'csv' );"

#
# Dump the first 10 lines
#
SQL=$(cat <<EOF

select count(*), kivapin, sum(cast(bldgsqft AS NUMERIC(10,1))) FROM building_area WHERE id <> 'id' GROUP BY kivapin HAVING count(*) > 1 LIMIT 5;

EOF
)

echo "${SQL}" | sudo -u postgres psql address_api


#
# Cleanup
#
SQL=$(cat <<EOF
DROP FOREIGN TABLE building_area;
DROP SERVER import;
DROP EXTENSION file_fdw;

EOF
)

echo "${SQL}" | sudo -u postgres psql address_api


