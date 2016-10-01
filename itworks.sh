#!/bin/sh


lsb_release -a

#    Posgtres Sever version

pg_config --version

# Postgres Client version
           
psql --version

#
# See that we have GDB installed
# Should display OpenFileGDB -vector- (rov): ESRI FileGDB
#
ogrinfo --formats | grep -i OpenFileGDB
#
# This should display "OpenFileGDB" (readonly)
#
ogr_fdw_info -f | grep -i OpenFileGDB
#
# Should display
#   GDAL 2.1.0, released 2016/04/25
ogr2ogr --version



sudo -u postgres psql code4kc -c 'SELECT PostGIS_full_version();'
sudo -u postgres psql code4kc -c 'SELECT PostGIS_Lib_Version();'


