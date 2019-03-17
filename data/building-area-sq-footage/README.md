'Building Area in Feet' => 'approximate_building_area_in_feet'
=====================================================

`kcblgdapproxarea.csv` contains the area for each building on a parcel.

The Microsoft Bldg Outline file was used, converted the polygons to centroids, then determined which centroids fell within each of the KC Parcels (polygon) file from KCMO Parcel Finder. The attached file contains three columns:

* ID - unique Identifier
* BLDGSQFT - Bldg Sq. Footage in ft squared
* KIVAPIN - KCMO Kiva Pin


# Changes


2) Modified 
    * install.sql
    * load
    * load.php
    * setup-for-test.sh
    * test-all.sh
3) Modified outside of jbuilding-area-sq-footage

* pi-docs/swagger.json
* src/Code4KC/Address/Address.php

`

# Test run

```
cd /var/www/address-api/data/jackson-county-tax-delinquency-2019
sh test-all.sh


-------------------------------------------------------------------------------------------------
table                              insert     update   inactive re-activate        N/A      ERROR 
other_attributes                   159677          0          0          0          0          0
-------------------------------------------------------------------------------------------------

Number of lines processed 0

This process used 1564 ms for its computations
It spent 11599 ms in system calls
Run time:  1m 26s

```

# Production install

1. Badkup Site
    ```
    cd /var/www
    sudo tar czf address-api.tar.gz address-api
    ```
2. Backup DB

    Will make a backup of adddress_api and code4kc databases
    ```
    sudo su - postgres
    sh doit
    ls -lrt dumps
    exit
    ```
3. Update Site
    ```
    cd /var/www/address-api
    git pull origin master
    ```
3. Copy spread sheet to `/tmp`
    ```
    cd /var/www/address-api/data/jackson-county-tax-delinquency-2019
    cp kcblgdapproxarea.csv /tmp
    ```
4. Run the `load` script
    ```
    cd /var/www/address-api/data/jackson-county-tax-delinquency-2019
    sudo -u postgres psql code4kc < install.sql
    sh ./load                
    ```
5. Verify data was loaded.

