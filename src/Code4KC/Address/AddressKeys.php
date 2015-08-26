<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class AddressKeys extends BaseTable
{

    var $table_name = 'address_keys';
    var $primary_key_sequence = 'address_key_id_seq';
    var $fields = array(
        'address_id' => '',
        'city_address_id' => '',
        'county_address_id' => '',
    );

    var $address_id_query = '';

    /**
     * @param $id
     * @return false or found record
     */
    function find_by_address_id($address_id)
    {
        if (!$this->address_id_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE address_id = :address_id';
            $this->address_id_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->address_id_query->execute(array(':address_id' => $address_id));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->address_id_query->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * @param $id
     * @return false or found record
     */
    function find_by_city_address_id($id)
    {
        if (!$this->address_id_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE city_address_id = :id';
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

}
