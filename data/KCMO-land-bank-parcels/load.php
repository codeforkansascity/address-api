<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

ini_set("auto_detect_line_endings", true);

/**
 * Class Address
 */
class KCMOLandBankParcels extends \Code4KC\Address\BaseLoad
{

    var $totals = array(
        'input' => array('insert' => 0, 'update' => 0, 'inactive' => 0, 're-activate' => 0, 'N/A' => 0, 'error' => 0),
        'land_bank_parcels' => array('insert' => 0, 'update' => 0, 'inactive' => 0, 're-activate' => 0, 'N/A' => 0, 'error' => 0),
    );

    function __construct(&$dbh, $DB_NAME, $debug = false)
    {

        if (!$this->valid_cli_options()) {
            $this->help();
        } else {

            parent::__construct($dbh, $debug);

            $this->display_cli_options($DB_NAME);

            $this->load($dbh);
            $this->end_load();

        }

    }

    function load()
    {

        $CityAddressAttributes = new \Code4KC\Address\CityAddressAttributes($this->dbh, true);

        if (!empty($this->input_file)) {
            if (file_exists($this->input_file)) {
                $records = $this->get_data_file($this->input_file);
            } else {
                print "\nERROR: input file " . $this->input_file . " was not found or readable.\n";
                return;
            }
        } else {

            print "\n".$this->parameters."\n";
            $json = $this->get_data_curl($this->input_url, $this->parameters);
            $records = json_decode($json, true);        // Convert JSON into an array
        }

        $active_ids = array();

        foreach ($records['features'] AS $rec) {

            $record = $rec['attributes'];

            /**
             *     [features] => Array(
                        [0] => Array(
                            [attributes] => Array(
                                [OBJECTID] => 592422
                                [KIVAPIN] => 47371
                                [LANDUSECODE] => 9500
                                [APN] => JA27530020101000000
                                [ADDRESS] =>
                                [ADDR] =>
                                [FRACTION] =>
                                [PREFIX] =>
                                [STREET] =>
                                [STREET_TYPE] =>
                                [SUITE] =>
                                [OWN_NAME] => Land Bank of Kansas City Missouri
                                [OWN_ADDR] => 4900 Swope Pkwy
                                [OWN_CITY] => Kansas City
                                [OWN_STATE] => MO
                                [OWN_ZIP] => 64130
                                [SHAPE.AREA] => 979.35888888889
                                [SHAPE.LEN] => 158.40463690498
             */

            $data['kivapin'] = $record['KIVAPIN'];
            $data['land_bank_property'] = 1;

            $this->row++;



            if ( false /* !$CityAddressAttributes->load_and_validate($data) */) {
                $this->display_rejected_record($this->row, $data, $CityAddressAttributes->error_messages);
                $this->totals['input']['error']++;
            } else {


                $fields_to_update = array(
                    'land_bank_property',
                );

                $city_id = $data['kivapin'];

                if ($current_record = $CityAddressAttributes->find_by_id($city_id)) {

                    $changes = $CityAddressAttributes->is_same($data, $current_record, $fields_to_update);

                    if (count($changes)) {

                        if ($this->verbose) {
                            $this->display_record($this->row, 'Change', $data);
                        }

                        if (!$this->dry_run
     //                       && $current_record['active']
                            && $CityAddressAttributes->save_changes($current_record['id'], $changes)
                        ) {

                        }

                        $active_ids[] = $current_record['id'];
                        $this->totals['land_bank_parcels']['update']++;
                    } else {
                        if ($this->verbose) {
                            $this->display_record($this->row, 'N/A', $data);
                        }

                        $this->totals['land_bank_parcels']['N/A']++;
                        $active_ids[] = $current_record['id'];
                    }

                } else {
                    $this->totals['land_bank_parcels']['error']++;
 //                   if ($this->verbose) {
                        $this->display_record($this->row, 'Add', $data);
                    print_r($record);
 //                   }


//                    if ($id = $CityAddressAttributes->add($data)) {
//                        $active_ids[] = $id;
//                    }
                }
            }
        }


    }

    function display_record($line_number, $msg, $data)
    {

        printf("%10s: %5d %16.16s %s \n", $msg, $line_number, $data['kivapin'], $data['land_bank_property']);
    }

    function display_rejected_record($line_number, $data, $data_errors)
    {

        printf("\nERROR: %5d %16.16s %s \n", $line_number, $data['kivapin'], $data['land_bank_property']);
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

$run = new KCMOLandBankParcels($dbh, $DB_NAME);
