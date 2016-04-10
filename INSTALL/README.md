# Requirements

# Create a Virtual Box with Address API

The following software will be installed

* Ubuntu 14.04.3 LTS - trusty
* PHP 5.5.9
* Apache/2.4.7
* Postgresql 9.3.11 - server encoding UTF8, installed extensions
 
  * fuzzystrmatch     1.0     - determine similarities and distance between strings
  * ogr_fdw           1.0     - foreign-data wrapper for GIS data access - https://github.com/pramsey/pgsql-ogr-fdw
  * plpgsql           1.0     - PL/pgSQL procedural language
  * postgis           2.1.2   - PostGIS geometry, geography, and raster spatial types and functions
  * postgis_topology  2.1.2   - PostGIS topology spatial types and functions
  * postgres_fdw      1.0     - foreign-data wrapper for remote PostgreSQL servers
 
* PostGIS 2.1.2 r12389
  * GDAL 1.11.2, released 2015/02/10

## Requirements

* Make certain ssh can be executed and it must be in you path  
* [Virtual Box](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)


## Clone repository

````
    git clone git@github.com:codeforkansascity/address-api.git 
    cd address-api
````

## Setup data to be restored

You need to create a directory called `dumps` and copy the dump files to them

````
    mkdir dumps
````

Copy he dumps from https://drive.google.com/drive/u/0/folders/0B1F5BJsDsPCXb2NYSmxCT09TX1k 
to the dumps directory and unzip them

````
   cd dumps

   gunzip address_api-20160220-0548.dump.gz
   gunzip code4kc-20160220-0548.dump.gz 

   cd ..
````

## Create image


````
    vagrant up
````


## Login


````
    vagrant ssh
````

# Setup postgres

## Login as postgres
````
sudo su - postgres
````


## Restore databases


````
   cd /var/www/dumps

   pg_restore -C -d address_api address_api-20160220-0548.dump 
   pg_restore -C -d code4kc code4kc-20160220-0548.dump
````

You will get several errors but you can ignor them

## Fix ownerships
````
psql
\c address_api
alter table  address                     OWNER TO c4kc;
alter table  address_alias               OWNER TO c4kc;
alter table  address_id_seq              OWNER TO c4kc;
alter table  address_id_seq_02           OWNER TO c4kc;
alter table  address_key_id_seq          OWNER TO c4kc;
alter table  address_keys                OWNER TO c4kc;
alter table  address_string_alias_id_seq OWNER TO c4kc;
alter table  census_attributes           OWNER TO c4kc;
alter table  city_address_attributes     OWNER TO c4kc;
alter table  county_address_attributes   OWNER TO c4kc;
alter table  county_address_data         OWNER TO c4kc;
alter table  jd_wp                       OWNER TO c4kc;
alter table  jd_wp_id_seq                OWNER TO c4kc;
alter table  neighborhoods               OWNER TO c4kc;
alter table  neighborhoods_id_seq        OWNER TO c4kc;
alter table  tmp_kcmo_all_addresses      OWNER TO c4kc;
alter table  tmp_kcmo_all_addresses_id_seq  OWNER TO c4kc;

\d

\c code4kc

alter SCHEMA  address_spatial                     OWNER TO c4kc;
alter table  address_spatial.auto_metro_area_tmp                     OWNER TO c4kc;
alter table  address_spatial.census_metro_area_tmp               OWNER TO c4kc;
alter table  address_spatial.census_metro_areas                  OWNER TO c4kc;
alter table  address_spatial.jackson_cnt_mo_1_tmp                OWNER TO c4kc;
alter table  address_spatial.jackson_cnt_mo_2_tmp                OWNER TO c4kc;
alter table  address_spatial.jackson_county_mo_tax_neighborhoods OWNER TO c4kc;
alter table  address_spatial.kc_nhood_tmp                        OWNER TO c4kc;
alter table  address_spatial.kcc_tmp                             OWNER TO c4kc;
alter table  address_spatial.kcmo_address_nbhd_tmp               OWNER TO c4kc;
alter table  address_spatial.mo_kc_city_council_districts_2012   OWNER TO c4kc;
alter table  address_spatial.mo_kc_city_neighborhoods            OWNER TO c4kc;
alter table  address_spatial.paul                                OWNER TO c4kc;

\dt *.*

\q

exit
````

## Restart postgres

````
sudo service postgresql stop
sudo service postgresql start
````

# Setup host environment

On your computer add the following to /etc/hosts


````
192.168.33.11 dev-api.codeforkc.local
````


You should now be able to browse to the following

````
http://dev-api.codeforkc.local/address-attributes/V0/210%20W%2019TH%20TER%20FL%201%2C?city=Kansas%20City&state=mo
````

And see

````
{"code":200,"status":"success","message":"","data":{"id":200567,"single_line_address":"210 W 19TH TER FL 1, KANSAS CITY...
````


You should have access to OGR Foreign Data Wrapper see https://github.com/pramsey/pgsql-ogr-fdw
### Notes


We need to figure out how if we need sfcgal and address_standardizer and if so how to install them.

````
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION address_standardizer;
````
