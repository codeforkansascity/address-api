#!/usr/bin/env bash
    # print command to stdout before executing it:
    set -x

    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby

    source "$HOME/.rvm/scripts/rvm"
    rvm install 2.2.3
    rvm use 2.2.3

    echo 'source "$HOME/.rvm/scripts/rvm"' >> .bashrc
    echo "rvm use 2.2.3" >> .bashrc

    # install postgres
    sudo apt-get -y install postgresql postgresql-contrib libpq-dev postgresql-9.3-postgis-2.1 redis-server

    # Install GDAL/OGR
    sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable && sudo apt-get update
    sudo apt-get install gdal-bin

    # Install some friends
    sudo apt-get -y unzip wget

    # From https://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS22UbuntuPGSQL95Apt
    # sudo apt-get -y install postgresql-9.5-postgis-2.2 pgadmin3 postgresql-contrib-9.5 

    # From previous postgresql install line
    sudo apt-get -y install libpq-dev

    sudo -u postgres psql -c "CREATE USER vagrant WITH PASSWORD 'vagrant';"
    sudo -u postgres psql -c "ALTER ROLE vagrant SUPERUSER CREATEROLE CREATEDB REPLICATION;"
    sudo -u postgres psql -c "CREATE EXTENSION postgis;"

    POSTGRE_VERSION=9.3

    # listen for localhost connections
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$POSTGRE_VERSION/main/postgresql.conf

    # identify users via "md5", rather than "ident", allowing us to make postgres
    # users separate from system users. "md5" lets us simply use a password
    echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a /etc/postgresql/$POSTGRE_VERSION/main/pg_hba.conf
    sudo service postgresql start

    sudo -u postgres createuser c4kc

SQL=$(cat <<EOF
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
EOF
)

   echo "${SQL}" > sudo -u postgres psql


    ### Apache + PHP ###
    sudo apt-get update -y
    sudo apt-get install -y apache2
    sudo apt-get install -y php5 libapache2-mod-php5 php5-cli php5-mcrypt php5-gd php5-curl php5-pgsql

    sudo a2enmod headers
    sudo a2enmod rewrite



    cd /tmp
    wget https://getcomposer.org/installer
    php installer
    sudo mv composer.phar /usr/local/bin/composer


VHOST=$(cat <<EOF
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

        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php?url=$1 [QSA,L]
        Order allow,deny
        Allow from all

    </Directory>
</VirtualHost>
EOF
)

    echo "${VHOST}" > /etc/apache2/sites-available/002-dev-api.conf


    cd /etc/apache2/sites-enabled
    sudo ln -s ../sites-available/002-dev-api.conf .


    cd /var/wwww
    composer update


APPCONFIG=$(cat <<EOF
<?php

global \$DB_NAME;
global \$DB_USER;
global \$DB_PASS;
global \$DB_HOST;

if ( !empty( \$_SERVER["DB_HOST"] )) { \$DB_HOST = \$_SERVER["DB_HOST"]; } else { \$DB_HOST = 'localhost'; }
if ( !empty( \$_SERVER["DB_USER"] )) { \$DB_USER = \$_SERVER["DB_USER"]; } else { \$DB_USER = 'c4kc'; }
if ( !empty( \$_SERVER["DB_PASS"] )) { \$DB_PASS = \$_SERVER["DB_PASS"]; } else { \$DB_PASS = 'data'; }
if ( !empty( \$_SERVER["DB_NAME"] )) { \$DB_NAME = \$_SERVER["DB_NAME"]; } else { \$DB_NAME = 'address_api'; }

global \$DB_CENSUS_NAME;
global \$DB_CENSUS_USER;
global \$DB_CENSUS_PASS;
global \$DB_CENSUS_HOST;

if ( !empty( \$_SERVER["DB_CENSUS_HOST"] )) { \$DB_CENSUS_HOST = \$_SERVER["DB_CENSUS_HOST"]; } else { \$DB_CENSUS_HOST = 'localhost'; }
if ( !empty( \$_SERVER["DB_CENSUS_USER"] )) { \$DB_CENSUS_USER = \$_SERVER["DB_CENSUS_USER"]; } else { \$DB_CENSUS_USER = 'c4kc'; }
if ( !empty( \$_SERVER["DB_CENSUS_PASS"] )) { \$DB_CENSUS_PASS = \$_SERVER["DB_CENSUS_PASS"]; } else { \$DB_CENSUS_PASS = 'data'; }
if ( !empty( \$_SERVER["DB_CENSUS_NAME"] )) { \$DB_CENSUS_NAME = \$_SERVER["DB_CENSUS_NAME"]; } else { \$DB_CENSUS_NAME = 'census'; }

global \$DB_CODE4KC_NAME;
global \$DB_CODE4KC_USER;
global \$DB_CODE4KC_PASS;
global \$DB_CODE4KC_HOST;

if ( !empty( \$_SERVER["DB_CODE4KC_HOST"] )) { \$DB_CODE4KC_HOST = \$_SERVER["DB_CODE4KC_HOST"]; } else { \$DB_CODE4KC_HOST = 'localhost'; }
if ( !empty( \$_SERVER["DB_CODE4KC_USER"] )) { \$DB_CODE4KC_USER = \$_SERVER["DB_CODE4KC_USER"]; } else { \$DB_CODE4KC_USER = 'c4kc'; }
if ( !empty( \$_SERVER["DB_CODE4KC_PASS"] )) { \$DB_CODE4KC_PASS = \$_SERVER["DB_CODE4KC_PASS"]; } else { \$DB_CODE4KC_PASS = 'data'; }
if ( !empty( \$_SERVER["DB_CODE4KC_NAME"] )) { \$DB_CODE4KC_NAME = \$_SERVER["DB_CODE4KC_NAME"]; } else { \$DB_CODE4KC_NAME = 'code4kc'; }

EOF
)

    echo "${APPCONFIG}" > /var/www/config/config.php

    sudo service apache2 restart

    # sudo apt-get install -y libgmp-dev node
    # gem install bundle
    # bundle install

    # bundle exec rake db:create db:migrate

    # sudo service redis-server stop
