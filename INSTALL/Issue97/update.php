<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

ini_set("auto_detect_line_endings", true);

/**
 * Class Address
 */
class UpdateStreetAddress extends \Code4KC\Address\BaseLoad
{

    var $totals = array(
        'internal' => array('insert' => 0, 'update' => 0, 'inactive' => 0, 're-activate' => 0, 'N/A' => 0, 'error' => 0),
        'street_address' => array('insert' => 0, 'update' => 0, 'inactive' => 0, 're-activate' => 0, 'N/A' => 0, 'error' => 0),
    );

    function __construct(&$dbh, $DB_NAME, $debug = false)
    {
            parent::__construct($dbh, $debug);

            $this->update($dbh);
            $this->end_load();

    }

    function update()
    {

        $Address = new \Code4KC\Address\Address($this->dbh, true);

        $query = $Address->find_all();

        $row = 0;

        while ($address_rec = $query->fetch(PDO::FETCH_ASSOC)) {

            $row++;

            $street_address = '';
            $street_address .= $address_rec['street_number'];
            $street_address .= !empty($address_rec['pre_direction']) ? ' ' . $address_rec['pre_direction'] : '';
            $street_address .= !empty($address_rec['street_name']) ? ' ' . $address_rec['street_name'] : '';
            $street_address .= !empty($address_rec['street_type']) ? ' ' . $address_rec['street_type'] : '';
            $street_address .= !empty($address_rec['post_direction']) ? ' ' . $address_rec['post_direction'] : '';
            $street_address .= !empty($address_rec['internal']) ? ' ' . $address_rec['internal'] : '';

            $street_address = trim($street_address);

            $internal = str_replace(', KANSAS CITY, MO', "", $address_rec['single_line_address']);
            $internal = str_replace($street_address, "", $internal);
            $internal = trim($internal);

            switch ($internal) {
                case 'CTOF':

                    $internal = '';
                    break;

            }

            if ( empty($address_rec['internal']) && !empty($internal) && strlen($internal) < 11 ) {
                print $address_rec['single_line_address']."|$internal|$street_address|".$address_rec['internal']."\n";

                $address_rec['internal'] = $internal;

                $street_address .= !empty($address_rec['internal']) ? ' ' . $address_rec['internal'] : '';


                $Address->update_field_in('internal', $internal, array($address_rec['id']));

                $this->totals['internal']['update']++;
            }



            $ret = $Address->update_field_in('street_address', $street_address, array($address_rec['id']));

            $this->totals['street_address']['update']++;


        }


    }

    function display_record($line_number, $msg, $data)
    {

        printf("%10s: %5d %16.16s %s \n", $msg, $line_number, $data['land_use_code'], $data['land_use_description']);
    }

    function display_rejected_record($line_number, $data, $data_errors)
    {

        printf("\nERROR: %5d %16.16s %s \n", $line_number, $data['land_use_code'], $data['land_use_description']);
        $last_field = '.';
        foreach ($data_errors AS $field => $msgs) {
            foreach ($msgs AS $msg) {

                if ($last_field != $field) {
                    $dsp_field = $field . ':';
                    $last_field = $field;
                } else {
                    $dsp_field = '';
                }

                printf("         %20.20s %-s\n", $dsp_field, $msg);
            }
        }
    }

}

try {
    $dbh = new PDO("pgsql:host=localhost; dbname=$DB_NAME", $DB_USER, $DB_PASS);
} catch (PDOException $e) {
    error_log($e->getMessage() . ' ' . __FILE__ . ' ' . __LINE__);
    return false;
}

$run = new UpdateStreetAddress($dbh, $DB_NAME);
