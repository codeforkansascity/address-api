<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Neighborhood
 */
class Neighborhood extends BaseTable
{
    var $table_name = 'neighborhoods';
    var $primary_key_sequence = null;
    var $list_query = null;
    var $fields = array(
        'id' => '',
        'name' => '',
    );

    /**
     * @param $id
     * @return false or found record
     */
    function findall()
    {


        if (!$this->list_query) {
            $sql = 'SELECT id, name  FROM ' . $this->table_name . ' order by name';
            $this->list_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->list_query->execute();
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }
        return $this->list_query->fetchAll(PDO::FETCH_ASSOC);
    }
}
