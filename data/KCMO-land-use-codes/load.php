<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

ini_set("auto_detect_line_endings", true);

/**
 * Class Address
 */
class KCMOLandUse extends \Code4KC\Address\BaseLoad
{

    var $totals = array(
        'input' => array('insert' => 0, 'update' => 0, 'inactive' => 0, 'N/A' => 0, 'error' => 0),
        'land_use_codes' => array('insert' => 0, 'update' => 0,'inactive' => 0, 'N/A' => 0, 'error' => 0),
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

        $LandUseCodes = new \Code4KC\Address\LandUseCodes($this->dbh, true);

        if ( !empty($this->input_file) ) {
            if ( file_exists( $this->input_file)) {
                $records = $this->get_data_file($this->input_file);
            } else {
                print "\nERROR: input file " . $this->input_file . " was not found or readable.\n";
                return;
            }
        } else {
            $json = $this->get_data_curl($this->input_url);
            $records = json_decode($json, true);        // Convert JSON into an array
        }

        $fields_to_update = array(
            'land_use_code',
            'land_use_description'
        );

        $active_ids = array();

        foreach ($records AS $data) {

            $this->row++;

            if (!$LandUseCodes->load_and_validate($data)) {
                $this->display_rejected_record($this->row, $data, $LandUseCodes->error_messages);
                $this->totals['input']['error']++;
            } else {

                $land_use_code = $data['land_use_code'];

                if ($current_record = $LandUseCodes->find_by_code($land_use_code)) {

                    $changes = $LandUseCodes->is_same($data, $current_record, $fields_to_update);

                    if (count($changes)) {

                        if ( $this->verbose ) {
                            $this->display_record($this->row, 'Change', $data);
                        }

                        if (!$this->dry_run
                            && $current_record['active']
                            && $LandUseCodes->save_changes($current_record['id'], $changes)
                        ) {

                        }

                        $active_ids[] = $current_record['id'];
                        $this->totals['land_use_codes']['update']++;
                    } else {
                        if ( $this->verbose ) {
                            $this->display_record($this->row, 'N/A', $data);
                        }

                        $this->totals['land_use_codes']['N/A']++;
                        $active_ids[] = $current_record['id'];
                    }

                } else {
                    $this->totals['land_use_codes']['insert']++;
                    if ( $this->verbose ) {
                        $this->display_record($this->row, 'Add', $data);
                    }


                    if ($id = $LandUseCodes->add($data)) {
                        $active_ids[] = $id;
                    }
                }
            }
        }

        if ( !$this->dry_run                                                // Can not report correct number of deletes on a dry run
        && count($active_ids) > 0 ) {
            $inactive_ids = $LandUseCodes->git_ids_not_in($active_ids);

            if ( $this->verbose) {

                if ( count($inactive_ids)) {
                    $ids_to_inactivate = implode(',', $inactive_ids);
                    printf("%d %10s: %5s %s\n", count($inactive_ids), "id's  to Inactivate", '', $ids_to_inactivate);
                }
            }
            if ( count($inactive_ids)) {
                $this->totals['land_use_codes']['inactive'] = $LandUseCodes->update_field_not_in('active', 0, $active_ids);
            }
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

$run = new KCMOLandUse($dbh, $DB_NAME);



