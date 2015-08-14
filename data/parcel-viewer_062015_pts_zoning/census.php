<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

use \Httpful\Request;

/**
 * Class Address
 */
class Address
{

    var $dbh;
    var $address_key_by_city_id_query = null;
    var $address_by_alias_query = null;

    var $address_query = null;
    var $address_id_query = null;
    var $address_add_query = null;

    var $address_alias_query = null;
    var $address_alias_add_query = null;

    var $address_keys_query = null;
    var $address_keys_add_query = null;

    var $city_address_attributes_query = null;

    var $city_address_attributes_add_query = null;

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
            $sql = 'SELECT *  FROM address_keys WHERE city_address_id = :id';
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
     * @param $city_id
     * @return bool
     */
    function get_address_by_id($id)
    {
        if (!$this->address_id_query) {
            $sql = 'SELECT *  FROM address WHERE id = :id';
            $this->address_id_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->address_id_query->execute(array(':id' => $id));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->address_id_query->fetch(PDO::FETCH_ASSOC);
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
    function save_address(& $rec, $fields_to_update = array())
    {

        if ($fields_to_update) {                    // Set fields to update
            $fields = $fields_to_update;
        } else {
            $fields = array('single_line_address', 'street_number', 'pre_direction',
                'street_name', 'street_type', 'post_direction', 'internal', 'city', 'state');
        }

        if ($address_rec = $this->get_address($rec['single_line_address'])) {                       // See if we already have a record
            $address_id = $address_rec['id'];

            if ($set = $this->record_is_diff($rec, $address_rec, $fields)) {                        // If we do see if it is different
                // If different update it
                $sql = 'UPDATE address SET ' . $set['set'] . ', changed = current_timestamp ' . ' WHERE id = :id -- ' . __FILE__ . ' ' . __LINE__;

                try {
                    $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
                    $values = $set['values']['id'] = $address_id;
                    $ret = $query->execute($set['values']);
                } catch (PDOException  $e) {
                    print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    //throw new Exception('Unable to query database');
                    return false;
                }
            }

            return $address_id;

        }


        // We need to add this record
        if (!$this->address_add_query) {                                                                // Have we already built the query?
            $names = '';
            $values = '';                                                                               // Build it
            $sep = '';
            foreach ($fields AS $v) {
                $names .= $sep . $v;
                $values .= $sep . ':' . $v;
                $sep = ', ';
            }

            $sql = 'INSERT INTO address (' . $names . ') VALUES (' . $values . ')';
            $this->address_add_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {                                                                                           // Now we can add thr record
            $new_rec = array();
            foreach ($fields AS $v) {
                $new_rec[':' . $v] = $rec[$v];
            }
            $ret = $this->address_add_query->execute($new_rec);
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }


        $id = $this->dbh->lastInsertId('address_id_seq_02');

        return $id;

    }

    /**
     * @param $rec
     * @return bool
     */
    function save_address_by_id(& $rec, $fields_to_update = array())
    {
        if ($fields_to_update) {                    // Set fields to update
            $fields = $fields_to_update;
        } else {
            $fields = array('single_line_address', 'street_number', 'pre_direction',
                'street_name', 'street_type', 'post_direction', 'internal', 'city', 'state');
        }

        if ($address_rec = $this->get_address_by_id($rec['id'])) {                       // See if we already have a record
            $address_id = $address_rec['id'];
            if ($set = $this->record_is_diff($rec, $address_rec, $fields)) {                        // If we do see if it is different
                // If different update it
                $sql = 'UPDATE address SET ' . $set['set'] . ', changed = current_timestamp ' . ' WHERE id = :id -- ' . __FILE__ . ' ' . __LINE__;

                try {
                    $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
                    $values = $set['values']['id'] = $address_id;
                    $ret = $query->execute($set['values']);
                } catch (PDOException  $e) {
                    print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    //throw new Exception('Unable to query database');
                    return false;
                }
            }

            return $address_id;

        } else {
            print "ERROR: address id " . $rec['id'] . " was not found\n";
            return false;
        }

    }

    /**
     * @param $single_line_address
     * @return bool
     */
    function get_address_alias($single_line_address)
    {

        if (!$this->address_alias_query) {
            $sql = 'SELECT * FROM address_alias WHERE single_line_address = :single_line_address';
            $this->address_alias_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->address_alias_query->execute(array(':single_line_address' => $single_line_address));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->address_alias_query->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * @param $rec
     * @return bool
     */
    function save_address_alias($rec, $fields_to_update = array())
    {

        if ($fields_to_update) {                    // Set fields to update
            $fields = $fields_to_update;
        } else {
            $fields = array('single_line_address', 'address_id');
        }

        if ($address_rec = $this->get_address_alias($rec['single_line_address'])) {                       // See if we already have a record
            $address_id = $address_rec['address_id'];

            return $address_id;

        }


        // We need to add this record
        if (!$this->address_alias_add_query) {                                                                // Have we already built the query?
            $names = '';
            $values = '';                                                                               // Build it
            $sep = '';
            foreach ($fields AS $v) {
                $names .= $sep . $v;
                $values .= $sep . ':' . $v;
                $sep = ', ';
            }

            $sql = 'INSERT INTO address_alias (' . $names . ') VALUES (' . $values . ')';
            $this->address_add_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {                                                                                           // Now we can add thr record
            $new_rec = array();
            foreach ($fields AS $v) {
                $new_rec[':' . $v] = $rec[$v];
            }
            $ret = $this->address_add_query->execute($new_rec);
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }


        return true;

    }

    /**
     * @param $single_line_address
     * @return bool
     */
    function get_address_keys($address_id)
    {

        if (!$this->address_keys_query) {
            $sql = 'SELECT * FROM address_keys WHERE address_id = :address_id';
            $this->address_key_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->address_key_query->execute(array(':address_id' => $address_id));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->address_key_query->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * @param $rec
     * @return bool
     */
    function save_address_keys($rec, $fields_to_update = array())
    {

        if ($fields_to_update) {                    // Set fields to update
            $fields = $fields_to_update;
        } else {
            $fields = array('address_id', 'city_address_id', 'county_address_id');
        }

        if ($address_rec = $this->get_address_keys($rec['address_id'])) {                       // See if we already have a record
            $address_key_id = $address_rec['id'];

            if ($set = $this->record_is_diff($rec, $address_rec, $fields)) {                        // If we do see if it is different
                // If different update it
                $sql = 'UPDATE address_keys SET ' . $set['set'] . ', changed = current_timestamp ' . ' WHERE id = :id -- ' . __FILE__ . ' ' . __LINE__;

                try {
                    $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
                    $values = $set['values']['id'] = $address_key_id;
                    $ret = $query->execute($set['values']);
                } catch (PDOException  $e) {
                    print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    //throw new Exception('Unable to query database');
                    return false;
                }
            }

            return $address_key_id;

        }

        print 'a';
        // We need to add this record
        if (!$this->address_keys_add_query) {                                                                // Have we already built the query?
            $names = '';
            $values = '';                                                                               // Build it
            $sep = '';
            foreach ($fields AS $v) {
                $names .= $sep . $v;
                $values .= $sep . ':' . $v;
                $sep = ', ';
            }

            $sql = 'INSERT INTO address_keys (' . $names . ') VALUES (' . $values . ')';
            print "\n$sql\n";
            $this->address_keys_add_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {                                                                                           // Now we can add thr record
            $new_rec = array();
            foreach ($fields AS $v) {
                $new_rec[':' . $v] = $rec[$v];
            }
            $ret = $this->address_keys_add_query->execute($new_rec);
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }


        $id = $this->dbh->lastInsertId('address_key_id_seq');

        return $id;

    }


    /**
     * @param $rec
     * @return bool
     */
    function save_city_address_attributes($rec, $fields_to_update = array())
    {

        if ($fields_to_update) {                    // Set fields to update
            $fields = $fields_to_update;
        } else {
            $fields = array('land_use_code', 'land_use', 'classification', 'sub_class', 'neighborhood');
        }

        if ($address_rec = $this->get_city_address_attributes($rec['id'])) {                       // See if we already have a record
            $address_key_id = $address_rec['id'];

            if ($set = $this->record_is_diff($rec, $address_rec, $fields)) {                        // If we do see if it is different
                // If different update it
                $sql = 'UPDATE city_address_attributes SET ' . $set['set'] . ', changed = current_timestamp ' . ' WHERE id = :id -- ' . __FILE__ . ' ' . __LINE__;

                try {
                    $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
                    $values = $set['values']['id'] = $address_key_id;
                    $ret = $query->execute($set['values']);
                } catch (PDOException  $e) {
                    print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
                    //throw new Exception('Unable to query database');
                    return false;
                }
            }

            return $address_key_id;

        }

        print 'a';
        // We need to add this record
        if (!$this->city_address_attributes_add_query) {                                                                // Have we already built the query?
            $names = '';
            $values = '';                                                                               // Build it
            $sep = '';
            foreach ($fields AS $v) {
                $names .= $sep . $v;
                $values .= $sep . ':' . $v;
                $sep = ', ';
            }

            $sql = 'INSERT INTO city_address_attributes (' . $names . ') VALUES (' . $values . ')';
            print "\n$sql\n";
            $this->city_address_attributes_add_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }
        try {                                                                                           // Now we can add thr record
            $new_rec = array();
            foreach ($fields AS $v) {
                $new_rec[':' . $v] = $rec[$v];
            }
            print_r($rec);
            print_r($new_rec);
            print "=====\n";
            $ret = $this->city_address_attributes_add_query->execute($new_rec);
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }


        return $rec['id'];

    }


    /**
     * @param $single_line_address
     * @return bool
     */
    function get_city_address_attributes($id)
    {

        if (!$this->city_address_attributes_query) {
            $sql = 'SELECT * FROM city_address_attributes WHERE id = :id';
            $this->city_address_attributes_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->city_address_attributes_query->execute(array(':id' => $id));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->city_address_attributes_query->fetch(PDO::FETCH_ASSOC);
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

try {
    $dbh = new PDO("pgsql:dbname=$DB_NAME", $DB_USER, $DB_PASS);


} catch (PDOException $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    throw new Exception('Unable to connect to database');
}


$sql = 'SELECT * FROM address';
$query = $dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

try {
    $query->execute();
} catch (PDOException  $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    //throw new Exception('Unable to query database');
    return false;
}
$cnt = 0;
while ($rec = $query->fetch(PDO::FETCH_ASSOC)) {

    $street_number = $rec['street_number'];
    $pre_direction = $rec['pre_direction'];
    $street_name = $rec['street_name'];
    $street_type = $rec['street_type'];
    $post_direction = $rec['post_direction'];
    $internal = $rec['internal'];
    $city = $rec['city'];
    $state = $rec['state'];
    $zip = $rec['zip'];

    $street = urlencode(trim(preg_replace('/\s+/', ' ', "$street_number $pre_direction $street_name $street_type $post_direction $internal")));
    $city = urlencode(trim(preg_replace('/\s+/', ' ', "$city")));
    $uri = "http://geocoding.geo.census.gov/geocoder/geographies/address?street=$street&city=$city&state=$state&zip=$zip&benchmark=4&vintage=4&format=json";

    $response = Request::get($uri)->send();

    if (property_exists($response, 'body')
        && property_exists($response->body, 'result')
        && property_exists($response->body->result, 'addressMatches')
    ) {

        $c_matches = $response->body->result->addressMatches;

        if (!empty($c_matches)) {

            $f_rec = $c_matches['0'];

            $zip = $f_rec->addressComponents->zip;
            $county_name = $f_rec->geographies->Counties['0']->NAME;
            $county_id = $f_rec->geographies->Counties['0']->COUNTY;
            $state_name = $f_rec->geographies->States['0']->NAME;
            $state_id = $f_rec->geographies->States['0']->STATE;
            $tract_name = $f_rec->geographies->{'Census Tracts'}['0']->NAME;
            $tract_id = $f_rec->geographies->{'Census Tracts'}['0']->TRACT;
            $block_2010_name = $f_rec->geographies->{'2010 Census Blocks'}['0']->NAME;
            $block_2010_id = $f_rec->geographies->{'2010 Census Blocks'}['0']->BLOCK;

        }

    }

    print "\$zip=$zip\n";
    print "\$county_name=$county_name\n";
    print "\$county_id=$county_id\n";
    print "\$state_name=$state_name\n";
    print "\$state_id=$state_id\n";
    print "\$tract_name=$tract_name\n";
    print "\$tract_id=$tract_id\n";
    print "\$block_2010_name=$block_2010_name\n";
    print "\$block_2010_id=$block_2010_id\n";
    die;
}
