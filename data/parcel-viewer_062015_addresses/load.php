<?php

require '../../vendor/autoload.php';
require '../../config/config.php';
require '../../vendor/Convissor/address/AddressStandardizationSolution.php';

/**
 * Class Address
 */
class Address
{

    var $dbh;
    var $address_key_by_city_id_query = null;
    var $address_by_alias_query = null;
    var $address_query = null;
    var $address_add_query = null;

    /**
     * @param $dbh
     */
    function __construct(&$dbh, $debug = false)
    {
        $this->dbh = $dbh;

        if ($debug) {
            $this->dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }
    }

    /**
     * @param $city_id
     * @return bool
     */
    function get_address_keys_by_city_id($city_id)
    {

        if (!$this->address_key_by_city_id_query) {
            $sql = 'SELECT address_id, county_address_id FROM address_keys WHERE city_address_id = :id';
            $this->address_key_by_city_id_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->address_key_by_city_id_query->execute(array(':id' => $city_id));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->address_key_by_city_id_query->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * @param $single_line_address
     * @return bool
     */
    function get_address_by_alias($single_line_address)
    {

        if (!$this->address_by_alias_query) {
            $sql = 'SELECT * FROM address_alias WHERE single_line_address = :single_line_address';
            $this->address_by_alias_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->address_by_alias_query->execute(array(':single_line_address' => $single_line_address));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->address_by_alias_query->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * @param $single_line_address
     * @return bool
     */
    function get_address($single_line_address)
    {

        if (!$this->address_query) {
            $sql = 'SELECT * FROM address WHERE single_line_address = :single_line_address';
            $this->address_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->address_query->execute(array(':single_line_address' => $single_line_address));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->address_query->fetch(PDO::FETCH_ASSOC);
    }

    function record_is_diff($a, $b, $fields)
    {

        $same = '';
        $sep = '';
        foreach ($fields AS $i) {

            if ($a[$i] != $b[$i]) {

                $same .= $sep . "$i = :$i";
                $sep = ', ';

                $values[':' . $i] = $a[$i];
            }
        }

        if ($same) {
            return array('set' => $same, 'values' => $values);
        } else {
            return false;
        }

    }

    /**
     * @param $rec
     * @return bool
     */
    function save_address(& $rec, $fields_to_update = array()) {
    {


        if ($fields_to_update) {                    // Set fields to update
            $fields = $fields_to_update;
        } else {
            $fields = array('single_line_address', 'street_number', 'pre_direction',
                'street_name', 'street_type', 'post_direction', 'internal', 'city', 'state');
        }

        if ($address_rec = $this->get_address($rec['single_line_address'])) {
            print_r($address_rec);

            if ($set = $this->record_is_diff($rec, $address_rec, $fields)) {

                $sql = 'UPDATE address SET ' . $set['set']  . ', changed = current_timestamp ' . ' WHERE id = :id -- ' . __FILE__ . ' ' . __LINE__;

print "\n\n$sql\n\n";
                try {
                    $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
                    $values = $set['values']['id'] = $address_rec['id'];
                    $ret = $query->execute($set['values']);
                } catch (PDOException  $e) {
                    print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    //throw new Exception('Unable to query database');
                    return false;
                }
            }

        }
        return $address_rec['id'];

    }

if (!$this->address_add_query)
{
$names = '';
$values = '';
$sep = '';
foreach ($fields AS $v)
{
$names .= $sep . $v;
$values .= $sep . ':' . $v;
$sep = ', ';
}

$sql = 'INSERT INTO address (' . $names . ') VALUES (' . $values . ')';
$this->address_add_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
}

try {
    $new_rec = array();
    foreach ($fields AS $v) {
        $new_rec[':' . $v] = $rec[$v];
    }
    print_r($new_rec);
    $ret = $this->address_add_query->execute($new_rec);
} catch (PDOException  $e) {
    print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    //throw new Exception('Unable to query database');
    return false;
}


$id = $this->dbh->lastInsertId('address_id_seq_02');

return $id;

}


}

/**
 * Class Census
 */
class Census
{

    var $dbh;
    var $single_line_address = '';

    /**
     * @throws Exception
     */
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
    }

    /**
     * @param $address_line
     * @return mixed
     * @throws Exception
     */
    function normalize_address($address_line)
    {
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
            $query->execute(array(':address' => $address_line));

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

        $this->single_line_address = preg_replace('/\s+/', ' ', "$street_number $pre_direction $street_name $street_type $post_direction $internal, $city, $state $zip");
        $this->single_line_address = preg_replace('/\s+,/', ',', $this->single_line_address);

        return $row;

    }

    /**
     * @return string
     */
    function get_single_line_address()
    {
        return $this->single_line_address;
    }

    /**
     * @return mixed
     */
    function get_input_address()
    {
        return $this->input_address;
    }

}

$census = new Census();

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
    $address = new Address($dbh, true);

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


            if ($address_keys = $address->get_address_keys_by_city_id($city_address_id)) {
                print "found\n";
            } else {

                if ($address_rec = $address->get_address_by_alias($single_line_address)) {
                    print "address found\n";

                } else {
                    $address_id = $address->save_address($address_in);
                    print "address $address_id added\n";

                }
                print "not found\n";

            }

        }
    }
    fclose($handle);
}
print_r($out);

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
