<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class LandUseCodes extends BaseTable
{

    var $single_line_address_query = null;
    var $table_name = 'land_use_codes';
    var $primary_key_sequence = null;
    var $fields = array(
        'land_use_code' => '',
        'land_use_description' => '',
        'active' => '1'
    );

    var $field_definitions = array(
        'land_use_code' => array('size' => 10, 'type' => 'char'),
        'land_use_description' => array('size' => 80, 'type' => 'char'),
        'active' => array('size' => false, 'type' => 'int')
    );

    /**
     * @param $city_id
     * @return bool
     */
    function find_by_code($code)
    {
        if (!$this->single_line_address_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE land_use_code = :code';
            $this->single_line_address_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->single_line_address_query->execute(array(':code' => $code));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->single_line_address_query->fetch(PDO::FETCH_ASSOC);
    }
}
