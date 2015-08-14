<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class AddressAlias extends BaseTable
{

    var $single_line_address_query = null;
    var $table_name = 'address_alias';                                                    
    var $primary_key_sequence = null;
    var $fields = array(                                                            
        'single_line_address' => '',                                                
        'address_id' => 0,                                                           
    );

    /**
     * @param $city_id
     * @return bool
     */
    function find_by_single_line_address($single_line_address)
    {
        if (!$this->single_line_address_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE single_line_address = :single_line_address';
            $this->single_line_address_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->single_line_address_query->execute(array(':single_line_address' => $single_line_address));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->single_line_address_query->fetch(PDO::FETCH_ASSOC);
    }
}
