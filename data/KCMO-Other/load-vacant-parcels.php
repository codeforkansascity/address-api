<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

ini_set("auto_detect_line_endings", true);

/**
 * Class Address
 */
class KCMOTIF extends \Code4KC\Address\AreaLoad
{

    var $area_name = "VacantParcels";

    var $spatial_fields_to_update = array(
        'name',
        'fid',
        'geom',
        'shape_length',
        'shape_area',
    );

    var $sql = "SELECT ogc_fid AS fid, wkb_geometry::geography::geometry AS geom, kivapin AS name, shape_length, shape_area  FROM public.vacantparcels;";

    function load_spatial()
    {

        $city_address_attributes = new \Code4KC\Address\CityAddressAttributes($this->dbh, true);

        $records = $this->get_spatial_records($this->sql);

        foreach ($records AS $rec) {

            $data = $rec;
            $this->row++;


            $fid = $data['fid'];
            $data['active'] = 1;

            if ($current_record = $this->Areas->find_by_fid($fid)) {

                $this->active_spatial_ids[] = $current_record['id'];

                $changes = $this->Areas->is_same($data, $current_record, $this->spatial_fields_to_update);

                $number_of_changes = count($changes);

                if ($number_of_changes > 0) {

                    $this->have_spatial_changes = true;

                    if (array_key_exists('active', $changes)) {                  // Are we reactivating
                        $this->totals['spatial']['re-activate']++;
                        if ($number_of_changes > 1) {                            // and are there other changes
                            $this->totals['spatial']['update']++;
                        }
                    } else {
                        $this->totals['spatial']['update']++;                    // We only have changes NO reactivating
                    }

                    if ($this->verbose) {
                        $this->display_record($this->row, 'Change', $data);
                    }

                    if (!$this->dry_run && $this->Areas->save_changes($current_record['id'], $changes)) {
                    }

                } else {

                    $this->totals['spatial']['N/A']++;

                    if ($this->verbose) {
                        $this->display_record($this->row, 'N/A', $data);
                    }
                }
            } else {

                $this->have_spatial_changes = true;

                $this->totals['spatial']['insert']++;

                if ($this->verbose) {
                    $this->display_record($this->row, 'Add', $data);
                }

                if (!$this->dry_run && $id = $this->Areas->add($data)) {
                    $this->active_spatial_ids[] = $id;
                }
            }

            $new_rec = array('vacant_parcel' => 1);

            if ($city_address_attributes_rec = $city_address_attributes->find_by_id($rec['name'])) {
                $city_address_attributes_id = $city_address_attributes_rec['id'];

                if ($city_address_attribute_differences = $city_address_attributes->diff($city_address_attributes_rec, $new_rec)) {
                    if (!$this->dry_run) {
                        $city_address_attributes->update($city_address_attributes_id, $city_address_attribute_differences);
                    }
                    $this->totals['city_address_attributes']['update']++;
                } else {
                    $this->totals['city_address_attributes']['N/A']++;
                }
            } else {
                // We are not adding new addresses,
                // this would be some sort of an error
                $this->totals['city_address_attributes']['error']++;
            }
        }

        if (!$this->dry_run && count($this->active_spatial_ids)) {
            $this->totals['spatial']['inactive'] = $this->Areas->mark_inactive_if_not_in($this->active_spatial_ids);
        }
    }

    /**
     * This is a stub since we update the attributes in the Spatial load
     * @return bool
     */
    function load() {
        return true;
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


$run = new KCMOTIF($DB_NAME, $DB_USER, $DB_PASS, $DB_CODE4KC_NAME, $DB_CODE4KC_USER, $DB_CODE4KC_PASS);
