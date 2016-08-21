#!/usr/bin/env bash
#
# Used by Vagrant startup
#
    # print command to stdout before executing it:
    set -x

    # Resolve error dpkg-reconfigure: unable to re-open stdin: No file or directory
    # From: http://serverfault.com/questions/500764/dpkg-reconfigure-unable-to-re-open-stdin-no-file-or-directory
    #    This makes debconf use a frontend that expects no interactive input at all
    #
    export DEBIAN_FRONTEND=noninteractive

    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby

    source "$HOME/.rvm/scripts/rvm"
    rvm install 2.2.3
    rvm use 2.2.3

    echo 'source "$HOME/.rvm/scripts/rvm"' >> .bashrc
    echo "rvm use 2.2.3" >> .bashrc

    sudo apt-get update -y
    sudo sudo apt-get autoclean -y
    sudo dpkg --configure -a 
    sudo apt-get -u dist-upgrade
    sudo sudo apt-get autoclean -y


    # Install some friends
    sudo apt-get -y install unzip wget git make

    # Used for postgres and  GDAL/OGR

    sudo apt-get install -y python-software-properties
    sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable && sudo apt-get update

    # install postgres
    sudo apt-get -y install postgresql postgresql-contrib libpq-dev postgresql-9.3-postgis-2.2 redis-server

#
# ------------
#


    ### support PostGres Foreign data wrapers

    # Install GDAL/OGR
    sudo apt-get install -y gdal-bin

    # From previous postgresql install line
    sudo apt-get install -y libgdal-dev

    # since we do not have pgxs.mk needed for making pgsql-ogr-fdw in the next step
    # WARNING:  this may cause issues
    sudo apt-get install -y --force-yes postgresql-server-dev-9.3

    (
        cd /tmp
        git clone https://github.com/pramsey/pgsql-ogr-fdw.git
        cd pgsql-ogr-fdw
        make
        sudo make install
    )


    sudo -u postgres psql -c "CREATE USER vagrant WITH PASSWORD 'vagrant';"
    sudo -u postgres psql -c "ALTER ROLE vagrant SUPERUSER CREATEROLE CREATEDB REPLICATION;"
    sudo -u postgres psql -c "CREATE EXTENSION postgis;"

    POSTGRE_VERSION=9.3

    # listen for localhost connections
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$POSTGRE_VERSION/main/postgresql.conf

    # identify users via "md5", rather than "ident", allowing us to make postgres
    # users separate from system users. "md5" lets us simply use a password
    echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a /etc/postgresql/$POSTGRE_VERSION/main/pg_hba.conf


    sudo sed -i "s/local   all             all                                     peer/local   all             all         md5/g" /etc/postgresql/$POSTGRE_VERSION/main/pg_hba.conf

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
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgres_fdw;
CREATE EXTENSION ogr_fdw;
\q
EOF
)

   echo "${SQL}" | sudo -u postgres psql


OGR=$(cat <<EOF
#
# OGR profile
#
# /etc/profile.d/ogr.sh # sh extension required for loading.
#

if
  [ -n "\${BASH_VERSION:-}" -o -n "\${ZSH_VERSION:-}" ] &&
  test "`\command \ps -p \$\$ -o ucomm=`" != dash &&
  test "`\command \ps -p \$\$ -o ucomm=`" != sh
then
  ogr_bin_path="/usr/lib/postgresql/9.3/bin"
  # Add \$ogr_bin_path to \$PATH if necessary
  if [[ -n "\${ogr_bin_path}" && ! ":\${PATH}:" == *":\${ogr_bin_path}:"* ]]
  then PATH="\${PATH}:\${ogr_bin_path}"
  fi
fi
EOF
)

   echo "${OGR}" > /etc/profile.d/ogr.sh


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

    ###php unit###
    wget https://phar.phpunit.de/phpunit-4.8.9.phar
    chmod +x phpunit-4.8.9.phar
    sudo mv phpunit-4.8.9.phar /usr/local/bin/phpunit.phar

VHOST=$(cat <<EOF
<VirtualHost *:80>

    ServerAdmin webmaster@localhost
    ServerName dev-api.codeforkc.devel
    DocumentRoot /var/www/address-api/webroot

    # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
    # error, crit, alert, emerg.
    # It is also possible to configure the loglevel for particular
    # modules, e.g.
    #LogLevel info ssl:warn

    ErrorLog /var/log/apache2/dev-api-error.log
    CustomLog /var/log/apache2/dev-api-access.log combined

    # For most configuration files from conf-available/, which are
    # enabled or disabled at a global level, it is possible to
    # include a line for only one particular virtual host. For example the
    # following line enables the CGI configuration for this host only
    # after it has been globally disabled with "a2disconf".
    #Include conf-available/serve-cgi-bin.conf

    DirectoryIndex index.php index.html


    <Directory /var/www/address-api/webroot>
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


    echo "${VHOST}" > /tmp/002-dev-api.conf
    sudo mv /tmp/002-dev-api.conf /etc/apache2/sites-available/002-dev-api.conf


    cd /etc/apache2/sites-enabled
    sudo ln -s ../sites-available/002-dev-api.conf .


    sudo rm /etc/apache2/sites-enabled/000-default.conf

    cd /var/www/address-api
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

    echo "${APPCONFIG}" > /tmp/config.php
    sudo mv /tmp/config.php /var/www/address-api/config

    sudo service apache2 restart

    sudo service postgresql stop
    sudo service postgresql start
