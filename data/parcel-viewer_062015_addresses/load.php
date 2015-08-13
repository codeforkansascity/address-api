<?php

require '../../vendor/autoload.php';
require '../../config/config.php';
require '../../vendor/Convissor/address/AddressStandardizationSolution.php';


$census = new \Code4KC\Address\Census();

$row = 0;
$out = array();
$names = array();

global $dbh;

if (($handle = fopen("test.csv", "r")) !== FALSE) {
    try {
        $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);


    } catch (PDOException $e) {
        error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
        throw new Exception('Unable to connect to database');
    }

    $address_converter = new Convissor\address\AddressStandardizationSolution();
    $address = new \Code4KC\Address\Address($dbh, true);

    while (($data = fgetcsv($handle, 1000, ";")) !== FALSE) {
        $num = count($data);
        $row++;

        if ($row == 1) {

            for ($c = 0; $c < $num; $c++) {
                $names[$c] = $data[$c];
            }


        } else {
            $rec = array();
            for ($c = 0; $c < $num; $c++) {
                $rec [$names [$c]] = $data[$c];
            }


            $standardized_address = $address_converter->AddressLineStandardization($rec['address']);
            $single_line_address = $standardized_address . ', KANSAS CITY, MO';                    // We keep unit 'internal'
            $normalized_address = $census->normalize_address($single_line_address);                // Strips off unit 'internal'
            $address_in = array_merge(
                array('single_line_address' => $single_line_address),
                $normalized_address, $rec);
            $city_address_id = $rec['kivapin'];
            $county_address_id = $rec['apn'];


                    $address_id = $address->save_address($address_in);
                    $address_alias_id = $address->save_address_alias(
			array( 'single_line_address' => $single_line_address, 'address_id' => $address_id )
                    );
                    $address_key_id = $address->save_address_keys(
			array( 'address_id' => $address_id, 
                               'city_address_id' => $city_address_id, 
                               'county_address_id' => $county_address_id ));
                    print "address $address_id added\n";

        }
    }
    fclose($handle);
}

