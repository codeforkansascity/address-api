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
    $address_alias = new \Code4KC\Address\AddressAlias($dbh, true);
    $address_keys = new \Code4KC\Address\AddressKeys($dbh, true);
    $city_address_attributes = new \Code4KC\Address\CityAddressAttributes($dbh, true);

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

            $single_line_address  = $address_converter->AddressLineStandardization($rec['address']);
            $single_line_address .= ', KANSAS CITY, MO';                    // We keep unit 'internal'

            $normalized_address = $census->normalize_address($single_line_address);                // Strips off unit 'internal'
            $address_in = array_merge(
                array('single_line_address' => $single_line_address),
                $normalized_address, $rec);

            $city_address_id = $rec['kivapin'];
            $county_address_id = $rec['apn'];

            // We need to start out with an alias and address records
            $address_id = 0;
            if ( $exisiting_address_alias_rec = $address_alias->find_by_single_line_address( $single_line_address ) ) {
                $address_id = $exisiting_address_alias_rec['address_id'];
                if ( $exisiting_address_rec = $address->find_by_id( $address_id ) ) {
                    if ( $address_differences = $address->diff($exisiting_address_rec, $rec) ) {
                        $address->update( $address_id, $address_differences );
                    }
                } else {
                    $address->add( $rec );
                }

            } else {
                if ( $exisiting_address_rec = $address->find_by_single_line_address( $single_line_address ) ) {       // Just in case we had a failuer to clean up
                    $address_id = $exisiting_address_rec['id'];

                } else {
                    $address_id = $address->add( $address_in );
                }

                $new_rec = array(
                    'single_line_address' => $single_line_address,
                    'address_id' => $address_id
                );

                $address_alias->add( $new_rec );


            }

            $new_rec = array('address_id' => $address_id,
                'city_address_id' => $city_address_id,
                'county_address_id' => $county_address_id
            );

            if ( $address_keys_rec = $address_keys->find_by_address_id( $address_id ) ) {
                $address_key_id = $address_keys_rec[ 'id' ];
                if ( $address_key_differences = $address_keys->diff($address_keys_rec, $new_rec) ) {
                    $address_keys->update( $address_key_id, $address_key_differences );
                } 
            } else {
                $address_keys->add( $new_rec );
            }

            $new_rec = array(
                'id' => $city_address_id,
                'neighborhood' => $rec['neighborhood']
            );

            if ( $city_address_attributes_rec = $city_address_attributes->find_by_id( $city_address_id ) ) {
                $city_address_attributes_id = $city_address_attributes_rec[ 'id' ];
                if ( $city_address_attribute_differences = $city_address_attributes->diff($city_address_attributes_rec, $new_rec) ) {
                    $city_address_attributes->update( $city_address_attributes_id, $city_address_attribute_differences );
                } 
            } else {
                $city_address_attributes->add( $new_rec );
            }


            /*
            $address_id = $address->save_address($address_in);
            // 
            $address_alias_id = $address->save_address_alias(
                array('single_line_address' => $single_line_address, 'address_id' => $address_id)
            );
            $address_key_id = $address->save_address_keys(
                array('address_id' => $address_id,
                    'city_address_id' => $city_address_id,
                    'county_address_id' => $county_address_id));
            print "address $address_id added\n";
             */

        }
    }
    fclose($handle);
}

