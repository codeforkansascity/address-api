#!/bin/sh
psql address_api < create.sql
php load.php -f=test1.json -U -v
php load.php -f=test2.json -U -v
php load.php -f=test3.json -U -v
