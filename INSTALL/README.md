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
    vagrant ssh
````

You should now be logged into the new virtual box

# Install postgres, unzip, and wget

````
    sudo su -
    apt-get install postgresql-contrib postgis postgresql-9.3-postgis-2.1 php5-pgsql unzip wget
````


# Install module mod_headers

````
a2enmod headers
````


#  Configure PostGres 
````
vi /etc/postgresql/9.3/main/postgresql.conf
````

Change the listen_addresses to your IP address

````
listen_addresses = '*'      # what IP address(es) to listen on;
````

# Remote from Vagrant Host

````
sudo vi /etc/postgresql/9.3/main/pg_hba.conf 
````

Change `peer` to `md5` on `local all all` line

````
#local   all             all                                     peer
local   all             all                               md5
local   all             all                               trust
host    all             all             192.168.56.0/24            md5
````

Restart PostGres

````
/etc/init.d/postgresql stop

/etc/init.d/postgresql start

exit
````

# Create database

````
sudo su - postgres
````

Create user

````
createuser c4kc
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
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION address_standardizer;
\q
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




Install GDAL/OGR

````
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable && sudo apt-get update
sudo apt-get install gdal-bin
````

Install composer

````
wget https://getcomposer.org/installer
php installer
sudo mv composer.phar /usr/local/bin/composer
````

2. Upate PHP with curl

````
sudo apt-get install php5-curl
sudo service apache2 restart
````

2. Run composer update

````
    cd /var/wwww
    composer update
````


Now create website


````
sudo su -
cd /etc/apache2/sites-available
````

````
cat > 002-dev-api.conf


<VirtualHost *:80>

    ServerAdmin webmaster@localhost
    ServerName dev-api.codeforkc.org
    ServerAlias dev-api.codeforkc.local
    DocumentRoot /var/www/webroot

    # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
    # error, crit, alert, emerg.
    # It is also possible to configure the loglevel for particular
    # modules, e.g.
    #LogLevel info ssl:warn

    ErrorLog ${APACHE_LOG_DIR}/dev-api-error.log
    CustomLog ${APACHE_LOG_DIR}/dev-api-access.log combined

    # For most configuration files from conf-available/, which are
    # enabled or disabled at a global level, it is possible to
    # include a line for only one particular virtual host. For example the
    # following line enables the CGI configuration for this host only
    # after it has been globally disabled with "a2disconf".
    #Include conf-available/serve-cgi-bin.conf

    DirectoryIndex index.php


    <Directory /var/www/webroot>
        Header set Access-Control-Allow-Origin "*"
        Header set Access-Control-Allow-Credentials "true"
        Header set Access-Control-Allow-Methods "POST, GET, OPTIONS"

        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted 

        <FilesMatch "\.php$">
            Require all granted
            SetHandler proxy:fcgi://127.0.0.1:9000
        </FilesMatch>
        
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php?url=$1 [QSA,L]
        Order allow,deny
        Allow from all

    </Directory>
</VirtualHost>
````

Enable the site to start 

````
cd ../sites-enabled/
ln -s ../sites-available/002-dev-api.conf .
apache2ctl restart
````

On your computer add the following to /etc/hosts


````
192.168.56.219 dev.api.codeforkc.org dev-api.codeforkc.local
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
