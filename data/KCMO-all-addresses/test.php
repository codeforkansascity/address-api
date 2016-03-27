<?php
// http://api.codeforkc.org/normalize_address/v0000/210%20West%2019th%20terrace/?city=KANSAS%20CITY&state=MO


require '/var/www/vendor/autoload.php';
require '/var/www/config/config.php';

    global $DB_NAME;
    global $DB_USER;
    global $DB_PASS;
    global $DB_HOST;

    print "\npgsql:host=localhost; dbname=$DB_NAME, $DB_USER, $DB_PASS\n";
    try {
        $dbh = new PDO("pgsql:host=localhost; dbname=$DB_NAME", $DB_USER, $DB_PASS);
    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        return false;
    }

print "pgsql:host=localhost; dbname=$DB_NAME, $DB_USER, $DB_PASS\n";

    try {
        $dbh = new PDO("pgsql:host=localhost; dbname=$DB_NAME", $DB_USER, $DB_PASS);
    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        return false;
    }

