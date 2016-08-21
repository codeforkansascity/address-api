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
