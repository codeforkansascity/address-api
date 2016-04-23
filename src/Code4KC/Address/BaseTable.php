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
    var $field_definitions = array();

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

    /**
     * Original
     * @param $id
     * @param $diff
     * @return bool
     */
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


    public function git_ids_not_in($ids)
    {

        $inQuery = implode(',', $ids);

        $sql = 'SELECT id  AS id FROM ' . $this->table_name . '  WHERE id  NOT IN (' . $inQuery . ')';

        try {
            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);

            $query->execute();

            $result = $query->fetchAll(PDO::FETCH_COLUMN);

        } catch (PDOException  $e) {
            print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $result;

    }

    public function update_field_in($field, $value, $ids)
    {

        $inQuery = implode(',', array_fill(0, count($ids), '?'));

        $sql = 'UPDATE ' . $this->table_name . ' SET ' . $field . ' = ?,  changed = current_timestamp ' . ' WHERE id IN (' . $inQuery . ')';

        try {
            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
            $query->bindValue(1, $value);
            foreach ($ids as $k => $id)
                $query->bindValue(($k + 2), $id);
            $ret = $query->execute();
        } catch (PDOException  $e) {
            print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $ret;

    }

    /**
     * New version that allows for reporting of changes, ie original and current values
     * changes is an array with an element for each field, with has an array with two element, the 'from' or old value, and 'to' new value.
     * This allows us to easily report differences in other sections of the code.
     * @param $id
     * @param $changes
     * @return bool
     */
    public function save_changes($id, $changes)
    {
        $query = '';
        $sep = '';
        $fields = '';
        $values = array();

        foreach ($changes AS $field => $value) {

            $fields .= $sep . $field . " = :$field ";
            $values[":$field"] = $value['to'];
            $sep = ', ';

        }

        $values['id'] = $id;

        $sql = 'UPDATE ' . $this->table_name . ' SET ' . $fields . ', changed = current_timestamp ' . ' WHERE id = :id -- ' . __FILE__ . ' ' . __LINE__;

        try {
            $query = $this->dbh->prepare("$sql  -- " . __FILE__ . ' ' . __LINE__);
            $ret = $query->execute(
                $values
            );
        } catch (PDOException  $e) {
            print ($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
            //throw new Exception('Unable to query database');
            return false;
        }

        return $id;

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


    function is_same($data, $current_record, $fields)
    {

        $changes = array();

        foreach ($fields AS $field) {

            if (array_key_exists($field, $data) && $current_record[$field] != $data[$field]) {

                $change = array(
                    'from' => $current_record[$field],
                    'to' => $data[$field]
                );

                $changes[$field] = $change;
            }
        }

        return $changes;
    }

    function load_and_validate($data)
    {

        $is_valid = true;
        $this->error_messages = array();
        foreach ($data AS $field => $value) {
            $valid = $this->load_and_validate_field($this->record, $field, $value);

            if (!$valid) {
                $is_valid = false;
            }
        }

        return $is_valid;
    }

    /**
     * load_and_validate_field
     * @param $record - an array of fields indexed by name
     * @param $field_name
     * @param $value
     * @return bool
     */
    function load_and_validate_field(&$record, $field_name, $value)
    {

        $valid_record = true;
        if (array_key_exists($field_name, $this->field_definitions)) {
            $size = $this->field_definitions[$field_name]['size'];

            if ($size && $size > 0) {
                if (strlen($value) > $size) {
                    $this->add_to_error_messages($field_name, ' is ' . strlen($value) . ' long, only ' . $size . ' allowed  "' . $value . '""');
                    $valid_record = false;
                }
            }

            $type = $this->field_definitions[$field_name]['type'];

            switch ($type) {
                case 'int':
                    if (!is_numeric($value)) {
                        $this->add_to_error_messages($field_name, ' is not an integer it is ' . $value);
                        $valid_record = false;
                    }
                    break;

                case 'char':

                    break;

                case 'date':

                    break;

                case 'bool':
                    if (!is_int(( int)$value)) {
                        $this->add_to_error_messages($field_name, ' is not an bool it is ' . $value);
                        $valid_record = false;
                    }
                    break;

                case 'lookup':

                    if (array_key_exists($field_name, $this->field_value_lookup)) {
                        if (!array_key_exists($value, $this->field_value_lookup[$field_name])) {
                            $this->add_to_error_messages($field_name, $value . ' is not a valid value');
                            $valid_record = false;
                        }
                    } else {
                        $this->add_to_error_messages($type, ' is not valid is not a valid LOOKUP field type');
                        $valid_record = false;
                    }
                    break;

                case 'YN':

                    if (!($value == 'Y' || $value == 'N')) {
                        $this->add_to_error_messages($field_name, ' is not Y/N it is ' . $value);
                        $valid_record = false;
                    }

                    break;

                default:
                    $this->add_to_error_messages($type, ' is not valid is not a valid field type');
                    $valid_record = false;
                    break;

            }

            if ($valid_record) {
                $record[$field_name] = $value;
            }

        } else {
            $this->add_to_error_messages($field_name, ' is not a valid field');
            $valid_record = false;
        }


        return $valid_record;
    }

    function add_to_error_messages($field_name, $msg)
    {
        if (!array_key_exists($field_name, $this->error_messages)) {
            $this->error_messages[$field_name] = array();
        }
        $this->error_messages[$field_name][] = $msg;
    }

}
