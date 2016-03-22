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

\q

exit
````




On your computer add the following to /etc/hosts


````
192.168.33.11 dev.api.codeforkc.org dev-api.codeforkc.local
````



# Setup config file

````

cd /var/www/config

cat > config.php

<?php

global $DB_NAME;
global $DB_USER;
global $DB_PASS;
global $DB_HOST;

if ( !empty( $_SERVER["DB_HOST"] )) { $DB_HOST = $_SERVER["DB_HOST"]; } else { $DB_HOST = 'localhost'; }
if ( !empty( $_SERVER["DB_USER"] )) { $DB_USER = $_SERVER["DB_USER"]; } else { $DB_USER = 'c4kc'; }
if ( !empty( $_SERVER["DB_PASS"] )) { $DB_PASS = $_SERVER["DB_PASS"]; } else { $DB_PASS = 'data'; }
if ( !empty( $_SERVER["DB_NAME"] )) { $DB_NAME = $_SERVER["DB_NAME"]; } else { $DB_NAME = 'address_api'; }

global $DB_CENSUS_NAME;
global $DB_CENSUS_USER;
global $DB_CENSUS_PASS;
global $DB_CENSUS_HOST;

if ( !empty( $_SERVER["DB_CENSUS_HOST"] )) { $DB_CENSUS_HOST = $_SERVER["DB_CENSUS_HOST"]; } else { $DB_CENSUS_HOST = 'localhost'; }
if ( !empty( $_SERVER["DB_CENSUS_USER"] )) { $DB_CENSUS_USER = $_SERVER["DB_CENSUS_USER"]; } else { $DB_CENSUS_USER = 'c4kc'; }
if ( !empty( $_SERVER["DB_CENSUS_PASS"] )) { $DB_CENSUS_PASS = $_SERVER["DB_CENSUS_PASS"]; } else { $DB_CENSUS_PASS = 'data'; }
if ( !empty( $_SERVER["DB_CENSUS_NAME"] )) { $DB_CENSUS_NAME = $_SERVER["DB_CENSUS_NAME"]; } else { $DB_CENSUS_NAME = 'census'; }

global $DB_CODE4KC_NAME;
global $DB_CODE4KC_USER;
global $DB_CODE4KC_PASS;
global $DB_CODE4KC_HOST;

if ( !empty( $_SERVER["DB_CODE4KC_HOST"] )) { $DB_CODE4KC_HOST = $_SERVER["DB_CODE4KC_HOST"]; } else { $DB_CODE4KC_HOST = 'localhost'; }
if ( !empty( $_SERVER["DB_CODE4KC_USER"] )) { $DB_CODE4KC_USER = $_SERVER["DB_CODE4KC_USER"]; } else { $DB_CODE4KC_USER = 'c4kc'; }
if ( !empty( $_SERVER["DB_CODE4KC_PASS"] )) { $DB_CODE4KC_PASS = $_SERVER["DB_CODE4KC_PASS"]; } else { $DB_CODE4KC_PASS = 'data'; }
if ( !empty( $_SERVER["DB_CODE4KC_NAME"] )) { $DB_CODE4KC_NAME = $_SERVER["DB_CODE4KC_NAME"]; } else { $DB_CODE4KC_NAME = 'code4kc'; }

````

You should not beable to browse to the following

````
http://dev-api.codeforkc.local/address-attributes/V0/210%20W%2019TH%20TER%20FL%201%2C?city=Kansas%20City&state=mo
````

And see

````
{"code":200,"status":"success","message":"","data":{"id":200567,"single_line_address":"210 W 19TH TER FL 1, KANSAS CITY...
````
