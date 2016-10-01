# Load Council Districts 2001

Layer: CouncilDistricts_2001


Files added

````
load-council-districts-2001.md
load-council-districts-2001.php
load-council-districts-2001.sh
load-council-districts-2001.sql
test-load-council-districts-2001.sh
````	

Determine table name you are going to load

````
ogr_fdw_info -s Other.gdb -l CouncilDistricts_2001
````


Manualy load temp table

````
sudo -u postgres ogr2ogr -f "PostgreSQL" PG:"dbname=code4kc user=postgres" Other.gdb councildistricts_2001
````

Now see what was loaded.


````
sudo -u postgres psql -d code4kc -c "\d  councildistricts_2001"
````

We get 

````
                                          Table "public.councildistricts_2001"
    Column    |             Type              |                                Modifiers                                 
--------------+-------------------------------+--------------------------------------------------------------------------
 objectid     | integer                       | not null default nextval('councildistricts_2001_objectid_seq'::regclass)
 district     | character varying(2)          | 
 acres        | double precision              | 
 ord_no       | character varying(20)         | 
 lastupdate   | timestamp with time zone      | 
 shape_length | double precision              | 
 shape_area   | double precision              | 
 wkb_geometry | geometry(MultiPolygon,900914) | 
Indexes:
    "councildistricts_2001_pkey" PRIMARY KEY, btree (objectid)
    "councildistricts_2001_wkb_geometry_geom_idx" gist (wkb_geometry)
````

Add the field to city_address_attributes using load-council-districts-2001.sql


Some of the field name changed between councildistricts and councildistricts_2001

I had to fix permissions, 

````
cd /var/www/address-api/data/scripts$ 
sudo -u postgres psql -f fix_ownerships.psqlpsql
````