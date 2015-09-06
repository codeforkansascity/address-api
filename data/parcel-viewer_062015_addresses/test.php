<?php

require '../../vendor/autoload.php';
require '../../config/config.php';


    try {
        $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);
    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        throw new Exception('Unable to connect to database');
    }

    $address_alias = new \Code4KC\Address\AddressAlias($dbh, true);
    $address = new \Code4KC\Address\Address($dbh, true);

    $single_line_address = '523 GRAND BLVD, KANSAS CITY, MO';

    $exisiting_address_alias_rec = $address_alias->find_by_single_line_address( $single_line_address ) ;

    var_dump( $exisiting_address_alias_rec );

    $address_id = $exisiting_address_alias_rec['address_id'];


    $exisiting_address_rec = $address->find_by_id( $address_id ) ;

print_r($exisiting_address_rec);
