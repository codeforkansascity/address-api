<?php

require '../../vendor/autoload.php';
require '../../config/config.php';



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

    $address = new \Code4KC\Address\Address($dbh, true);

    $names = array(
	'id', 'longitude', 'latitude', 'land_use_code', 'classification', 'land_use', 'sub_class'
    );

    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        $num = count($data);
        $row++;

        if ($row == 1) {

        } else {
            $rec = array();
            for ($c = 0; $c < $num; $c++) {
                $rec [$names [$c]] = $data[$c];
            }

            $city_address_id = $rec['id'];

            if ( $address_keys = $address->get_address_keys_by_city_id( $city_address_id ) ) {

print "\nFOUND\n";
print_r($address_keys);
              $address_rec = array(
		  'id' => $address_keys['address_id'],
                  'longitude' => $rec['longitude'],
                  'latitude' => $rec['latitude']
              );
              $address_rec = $address->save_address_by_id($address_rec, array('id', 'longitude', 'latitude'));

              $address_rec = array(
		  'id' => $city_address_id,
                  'land_use_code' => $rec['land_use_code'],
                  'land_use' => $rec['land_use'],
                  'classification' => $rec['classification'],
                  'sub_class' => $rec['sub_class']
              );

              $x = $address->save_city_address_attributes($address_rec, array('id', 'land_use_code', 'classification', 'land_use', 'sub_class'));


            } else {
               print "\nERROR: $city_address_id was not found line $row\n";


            }
        }
    }
    fclose($handle);
}

