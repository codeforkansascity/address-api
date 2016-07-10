<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class AddressTable
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
            $fields = array('street_address', 'single_line_address', 'street_number', 'pre_direction',
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
            $fields = array('street_address', 'single_line_address', 'street_number', 'pre_direction',
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
