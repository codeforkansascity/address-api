# Requirements

* Virtual Box
* PHP 5.6
* Composer


# Create site



1. Clone repository

````
    git clone git@github.com:codeforkansascity/address-api.git your-dir
````



# Create image


````
    vagrant up
````

You should now be logged into the new virtual box, using `vagrant ssh` and beable to connect to the postgress at 192.168.33.11 from your host computer.


````
sudo su - postgres
````

````
psql
````


# Final db
````
ALTER USER c4kc with encrypted password 'data';
CREATE DATABASE c4kc_address_api  WITH ENCODING 'UTF8' TEMPLATE=template0;
GRANT ALL PRIVILEGES ON DATABASE c4kc_address_api TO c4kc;

CREATE DATABASE address_api  WITH ENCODING 'UTF8' TEMPLATE=template0;
GRANT ALL PRIVILEGES ON DATABASE address_api TO c4kc;

CREATE DATABASE code4kc  WITH ENCODING 'UTF8' TEMPLATE=template0;
GRANT ALL PRIVILEGES ON DATABASE code4kc TO c4kc;


\c code4kc
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION fuzzystrmatch;
\q
````

We need to figure out how if we need sfcgal and address_standardizer and if so how to install them.

````
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION address_standardizer;
````

# Restore databases
You will need to grab the dumps from https://drive.google.com/drive/u/0/folders/0B1F5BJsDsPCXb2NYSmxCT09TX1k is where the data is stored.
and copy them to `/var/www/dumps`



````
   cd /var/www/dumps

   gunzip address_api-20160220-0548.dump.gz 
   gunzip code4kc-20160220-0548.dump.gz 

   pg_restore -C -d address_api address_api-20160220-0548.dump 
   pg_restore -C -d code4kc code4kc-20160220-0548.dump
````

You will get several errors but you can ignor them

# Set permissions
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




On your computer add the following to /etc/hosts


````
192.168.33.11 dev-api.codeforkc.local
````


You should not beable to browse to the following

````
http://dev-api.codeforkc.local/address-attributes/V0/210%20W%2019TH%20TER%20FL%201%2C?city=Kansas%20City&state=mo
````

And see

````
{"code":200,"status":"success","message":"","data":{"id":200567,"single_line_address":"210 W 19TH TER FL 1, KANSAS CITY...
````
