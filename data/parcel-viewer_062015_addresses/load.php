<?php

require '../../vendor/autoload.php';
require '../../config/config.php';
require '../../vendor/Convissor/address/AddressStandardizationSolution.php';


class Census
{

    var $dbh;
    var $single_line_address = '';

    function __construct()
    {
    global $DB_CENSUS_NAME;
    global $DB_CENSUS_USER;
    global $DB_CENSUS_PASS;
    global $DB_CENSUS_HOST;

        try {

            $this->dbh = new PDO("pgsql:dbname=$DB_CENSUS_NAME", $DB_CENSUS_USER, $DB_CENSUS_PASS);

        } catch (PDOException $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to connect to database');
        }
        print "In BaseClass constructor\n";
    }
    
    function normalize_address( $address_line ) {
        $this->input_address = strtoupper($address_line);
        try {

            $sql = 'SELECT g.address                   AS street_number,
                           UPPER( g.predirAbbrev )     AS pre_direction,
                           UPPER( g.streetName )       AS street_name,
                           UPPER( g.streetTypeAbbrev ) AS street_type,
                           UPPER( g.postdirAbbrev )    AS post_direction,
                           UPPER( g.internal )         AS internal,
                           UPPER( g.location )         AS city,
                           UPPER( g.stateAbbrev )      AS state,
                           g.zip                       AS zip,
                           g.parsed                    AS parsed
                      FROM normalize_address( :address ) AS g';

            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
            $query->execute(array(':address' => $address_line ));

        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            throw new Exception('Unable to query database');
        }

        $row = $query->fetch(PDO::FETCH_ASSOC);

	$street_number = $row['street_number'];
	$pre_direction = $row['pre_direction'];
	$street_name = $row['street_name'];
	$street_type = $row['street_type'];
	$post_direction = $row['post_direction'];
	$internal = $row['internal'];
	$city = $row['city'];
	$state = $row['state'];
	$zip = $row['zip'];
	$parsed = $row['parsed'];

	$this->single_line_address = preg_replace('/\s+/', ' ', "$street_number $pre_direction $street_name $street_type $post_direction $internal, $city, $state $zip" );
	$this->single_line_address = preg_replace('/\s+,/', ',', $this->single_line_address );

        return $row;

    }

    function get_single_line_address() {
        return $this->single_line_address;
    }

    function get_input_address() {
        return $this->input_address;
    }

}

    $census = new Census();

$row = 0;
$out = array();
$names = array();
if (($handle = fopen("test.csv", "r")) !== FALSE) {
    while (($data = fgetcsv($handle, 1000, ";")) !== FALSE) {
        $num = count($data);
        $row++;

	if ( $row == 1 ) {

            for ($c=0; $c < $num; $c++) {
                $names[ $c ] = $data[ $c ];
            }
	

	} else {
	    $rec = array();
            for ($c=0; $c < $num; $c++) {
                $rec [ $names [ $c ] ] = $data[ $c ];
            }
            $normalized_address = $census->normalize_address( $rec[ 'address' ] . ", Kansas City, MO" );
            $single_line_address = $census->get_single_line_address();
            $input_address = $census->get_input_address();

$address_converter = new Convissor\address\AddressStandardizationSolution();

            $x = $address_converter->AddressLineStandardization( $rec[ 'address' ] );
            $out [ $row - 1 ] = array_merge( 
                 array('input_address' => $input_address), 
                 array('x' => $x), 
                 array('single_line_address' => $single_line_address), 
                 $normalized_address, $rec );

/*
    [9] => Array
        (
            [address] => 4239 E 62nd St
            [predirabbrev] => E
            [streetname] => 62ND
            [streettypeabbrev] => ST
            [postdirabbrev] => 
            [internal] => 
            [city] => KANSAS CITY
            [state] => MO
            [zip] => 
            [parsed] => 1
            [kivapin] => 466
            [apn] => JA46220141400000000
            [neighborhood] => Swope Parkway-Elmwood
        )
*/

	

	}
    }
    fclose($handle);
}
print_r ( $out );

// Normalize one address with Census API



die('end');

$id = 'JA29620120500000000';

try {

    $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);

} catch (PDOException $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    throw new Exception('Unable to connect to database');
}


try {

    $query = $dbh->prepare("SELECT * FROM jd_wp WHERE county_apn_link = :id LIMIT 1 -- " . __FILE__ . ' ' . __LINE__);
    $query->execute(array(':id' => $id));

} catch (PDOException  $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    throw new Exception('Unable to query database');
}


$row = $query->fetch(PDO::FETCH_ASSOC);

var_dump($row);
print_r($row);
