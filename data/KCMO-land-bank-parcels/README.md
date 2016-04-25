# KCMO Land Use Codes - Load

This is a program for adding a lookup table.


* Doc URL https://data.kcmo.org/Land-Use/Land-Use-Codes/24u6-hh4w/about
* DATA URL https://data.kcmo.org/resource/mgwp-vfsh.json

## Install

1. Add land_bank_property to city_address_attributes

````
psql address_api < create.sql
````

2. Do inital load
````
/usr/bin/php /var/www/data/KCMO-land-use-codes/load.php  -u=https://maps.kcmo.org/kcgis/rest/services/external/DataLayers/MapServer/12/query -d=geometry=&geometryType=esriGeometryPolygon&inSR=4326&spatialRel=esriSpatialRelIntersects&relationParam=&objectIds=&where=1%3D1&time=&returnCountOnly=false&returnIdsOnly=false&returnGeometry=true&maxAllowableOffset=&outSR=&outFields=&f=pjson
````

3. Add to cron to run every Monday at 10:10am

````
55 3 * * * (cd /var/wwwsites/dev-api.codeforkc.org/data/KCMO-land-bank-parcels; /usr/bin/php ./load.php -U -u=https://data.kcmo.org/resource/mgwp-vfsh.json | mail -s "KCMO-land-bank-properties" paulb@savagesoft.com )````


## Files is this directory

`create.sql`
: SQL to create the lookup table.

`load.php`
: PHP program to add, change and mark Land Use Codes inactive

`test.sh`
: Script to do some simple test using `test[1-3].json'

`test[1-3].json'
: Test data for `test.sh`

### `load.php` CLI options

`-i` or `--input-file`
: filename for input file, if not using a URL

`-u' or `--input-url`
: URL for RESTful json data, if not using a file for input

`-d` or `--dry-run`
: program will not update the database, but print the number of records it would add and change

`-U` or `--update`
: will update the database

`-v` or `--verbose`
: will print records added and changed.  Will also print the id's it will mark inactive.

### Summary output

This is for run using the file `test2.json` to UPDATE the database with the verbose option.

````
Processing  test2.json  UPDATE 
 database address_api
       N/A:     1             1111 Single Family (Non-Mobile Home Park) 
    Change:     2             1121 Townhouses 
       N/A:     3             9600 Vacant Non-Residential (including billboards) 
1 id's  to Inactivate:       2002

Totals
------------------------------------------------------------------------------------
table                              insert     update   inactive        N/A      ERROR
input                                   0          0          0          0          0
land_use_codes                          0          1          1          2          0
------------------------------------------------------------------------------------

Number of lines processed 3

This process used 3 ms for its computations
It spent 2 ms in system calls
Run time:   0 seconds
````

