<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class BaseTable
 */
class BaseTable
{

    var $dbh;
    var $table_name = '';
    var $fields = array();

    var $id_query = null;
    var $add_query = null;

    var $single_line_address_query = null;

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
     * @param $id
     * @return false or found record
     */
    function find_by_id($id)
    {
        if (!$this->id_query) {
            $sql = 'SELECT *  FROM ' . $this->table_name . ' WHERE id = :id';
            $this->id_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {
            $this->id_query->execute(array(':id' => $id));
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $this->id_query->fetch(PDO::FETCH_ASSOC);
    }


    function diff($existing, $new)
    {

        $same = '';
        $sep = '';
        foreach ($existing AS $field => $value) {

            switch ($field) {
                case "id":
                case "added":
                case "changed":
                    break;

                default:

                    if (array_key_exists($field, $new)) {               // If the exiting fields is in the new array
                        if ($existing[$field] != $new[$field]) {

                            $same .= $sep . "$field = :$field";
                            $sep = ', ';
                            $values[':' . $field] = $new[$field];
                        }

                    }
                    break;
            }

        }

        if ($same) {
            return array('set' => $same, 'values' => $values);
        } else {
            return false;
        }

    }

    public function update($id, $diff)
    {

        $fields = $diff['set'];
        $values = $diff['values'];
        $values['id'] = $id;

        $sql = 'UPDATE ' . $this->table_name . ' SET ' . $fields . ', changed = current_timestamp ' . ' WHERE id = :id -- ' . __FILE__ . ' ' . __LINE__;

        try {
            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
            $ret = $query->execute($values);
        } catch (PDOException  $e) {
            print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $id;

    }

    /**
     * Add record's fields.  Use default values from $fields
     */
    function add($record)
    {
        if (!$this->add_query) {                                                                // Have we already built the query?
            $names = '';
            $values = '';                                                                               // Build it
            $sep = '';
            foreach ($this->fields AS $f => $v) {
                $names .= $sep . $f;
                $values .= $sep . ':' . $f;
                $sep = ', ';
            }

            $sql = 'INSERT INTO ' . $this->table_name . ' (' . $names . ') VALUES (' . $values . ')';
            $this->add_query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
        }

        try {                                                                                           // Now we can add thr record
            $new_rec = array();
            foreach ($this->fields AS $f => $v) {
                if (array_key_exists($f, $record)) {
                    $value = $record[$f];
                } else {
                    $value = $v;
                }
                $new_rec[':' . $f] = $value;
            }
            $ret = $this->add_query->execute($new_rec);
        } catch (PDOException  $e) {
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }


        if ($this->primary_key_sequence) {
            $id = $this->dbh->lastInsertId($this->primary_key_sequence);
        } else {
            $id = null;
        }


        return $id;


    }

}
