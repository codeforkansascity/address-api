<?php

require '../../vendor/autoload.php';
require '../../config/config.php';
require '../../vendor/Convissor/address/AddressStandardizationSolution.php';


$census = new \Code4KC\Address\Census();

$row = 0;
$out = array();
$names = array();

global $dbh;

$totals = array(
    'input' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address_alias' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'address_keys' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
    'city_address_attributes' => array('insert' => 0, 'update' => 0, 'N/A' => 0, 'error' => 0),
);

if (($handle = fopen("kcmo_addresses_kiva_nbrhd_06_18_2015.csv", "r")) !== FALSE) {
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
print "$row\n";
        if ($row == 1) {
            for ($c = 0; $c < $num; $c++) {
                $names[$c] = $data[$c];
            }
        } else {
            $rec = array();
            for ($c = 0; $c < $num; $c++) {
                $rec [$names [$c]] = $data[$c];
            }

            if ( empty($rec['kivapin'] )) {
                print "ERROR: NO kivapin for line $row county id = " . $rec['apn'] . "\n";
                $totals['input']['error']++;
                continue;
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
                $totals['address_alias']['N/A']++;
                $address_id = $exisiting_address_alias_rec['address_id'];
                if ( $exisiting_address_rec = $address->find_by_id( $address_id ) ) {
                    if ( $address_differences = $address->diff($exisiting_address_rec, $rec) ) {
                        $address->update( $address_id, $address_differences );
                        $totals['address']['update']++;
                    } else {
                        $totals['address']['N/A']++;
                    }
                } else {
                    $address->add( $rec );
                    $totals['address']['insert']++;
                }

            } else {
                if ( $exisiting_address_rec = $address->find_by_single_line_address( $single_line_address ) ) {       // Just in case we had a failuer to clean up
                    $address_id = $exisiting_address_rec['id'];
                    $totals['address']['N/A']++;

                } else {
                    $address_id = $address->add( $address_in );
                    $totals['address']['insert']++;
                }

                $new_rec = array(
                    'single_line_address' => $single_line_address,
                    'address_id' => $address_id
                );

                $address_alias->add( $new_rec );
                $totals['address_alias']['insert']++;

            }

            $new_rec = array('address_id' => $address_id,
                'city_address_id' => $city_address_id,
                'county_address_id' => $county_address_id
            );

            if ( $address_keys_rec = $address_keys->find_by_address_id( $address_id ) ) {
                $address_key_id = $address_keys_rec[ 'id' ];
                if ( $address_key_differences = $address_keys->diff($address_keys_rec, $new_rec) ) {
                    $address_keys->update( $address_key_id, $address_key_differences );
                    $totals['address_keys']['update']++;
                } else {
                    $totals['address_keys']['N/A']++;
                }
            } else {
                $address_keys->add( $new_rec );
                $totals['address_keys']['insert']++;
            }

            $new_rec = array(
                'id' => $city_address_id,
                'neighborhood' => $rec['neighborhood']
            );

            if ( $city_address_attributes_rec = $city_address_attributes->find_by_id( $city_address_id ) ) {
                $city_address_attributes_id = $city_address_attributes_rec[ 'id' ];
                if ( $city_address_attribute_differences = $city_address_attributes->diff($city_address_attributes_rec, $new_rec) ) {
                    $city_address_attributes->update( $city_address_attributes_id, $city_address_attribute_differences );
                    $totals['city_address_attributes']['update']++;
                } else {
                    $totals['city_address_attributes']['N/A']++; 
                }
            } else {
                $city_address_attributes->add( $new_rec );
                $totals['city_address_attributes']['insert']++;
            }
        }
    }
    fclose($handle);

    print "\nTotals\n--------------------------------------------------------------------------\n";

    printf("%-30.30s %10s %10s %10s %10s\n", 'table', 'insert', 'update', 'N/A', 'ERROR');
    foreach ( $totals AS $table => $counts ) {
        printf("%-30.30s %10d %10d %10d %10d\n", $table, $counts['insert'], $counts['update'], $counts['N/A'], $counts['error']);
    }
    print "--------------------------------------------------------------------------\n\n";

}

    print "Number of lines processed $row including header\n\n";
