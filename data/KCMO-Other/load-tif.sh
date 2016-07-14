#!/bin/sh
#
# Move the data from KCMO Other.zip's layer incentivetaxincrementfinancing to our spatial database.
#
# Some extra code in here for debuging, and extra calls to psql for debuging
#
(
cd /tmp
#
# Unpack Other.zip into Other.gdb

#
# Clean up from last run
#
#
sudo -u postgres psql -d code4kc -c "DROP TABLE incentivetaxincrementfinancing;"
#
# Load the one layer incentivetaxincrementfinancing
#
sudo -u postgres ogr2ogr -f "PostgreSQL" PG:"dbname=code4kc user=postgres" Other.gdb incentivetaxincrementfinancing
#
# Lets take a look at what we have
#
#sudo -u postgres psql -d code4kc -c "\dt"
#sudo -u postgres psql -d code4kc -c "\d incentivetaxincrementfinancing"
#
# Do the conversion to 4326  INPUT may be EPSG 102698
#
sudo -u postgres psql -d code4kc -c "ALTER TABLE incentivetaxincrementfinancing ALTER COLUMN wkb_geometry  TYPE geometry(MultiPolygon, 4326) USING ST_Transform(wkb_geometry, 4326);"
#
# Now rename columns so I do not need to change everything else
#
sudo -u postgres psql -d code4kc -c "ALTER TABLE incentivetaxincrementfinancing RENAME ogc_fid TO fid"
sudo -u postgres psql -d code4kc -c "ALTER TABLE incentivetaxincrementfinancing RENAME wkb_geometry TO geom"

#
# Now lets try to get a point that we know is in the River Market TIF
#
#echo "\nFirst Point\n"
#sudo -u postgres psql -d code4kc -c "SELECT name  FROM incentivetaxincrementfinancing WHERE ST_Intersects( ST_MakePoint( -94.5799701873, 39.1081197154)::geography::geometry, geom);"

#
# Now change ownership
#
sudo -u postgres psql -d code4kc -c "ALTER TABLE incentivetaxincrementfinancing OWNER TO c4kc;"
sudo -u postgres psql -d code4kc -c "ALTER TABLE incentivetaxincrementfinancing_pkey OWNER TO c4kc;"
sudo -u postgres psql -d code4kc -c "ALTER TABLE incentivetaxincrementfinancing_wkb_geometry_geom_idx OWNER TO c4kc;"

)


#################################################
# Now load the data in to the perment tables
#################################################

/usr/bin/php ./load-tif.php -U -f=/tmp/Other.gdb

sudo -u postgres psql -d code4kc -c "DROP TABLE incentivetaxincrementfinancing;"
