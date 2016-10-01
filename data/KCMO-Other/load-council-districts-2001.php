<?php

require '../../vendor/autoload.php';
require '../../config/config.php';

ini_set("auto_detect_line_endings", true);

/**
 * Class Address
 */
class KCMOTIF extends \Code4KC\Address\AreaLoad
{

    /*  councildistricts_2001
     *  ----------------------
     *  ogc_fid      | integer                     | not null default nextval('councildistricts_2001_ogc_fid_seq'::regclass)
     *  wkb_geometry | geometry(MultiPolygon,4326) |
     *  district     | character varying           |
     *  acres        | double precision            |
     *  ord_no       | character varying           |
     *  lastupdate   | timestamp with time zone    |
     *  shape_length | double precision            |
     *  shape_area   | double precision            |
     */
    var $area_name = "CouncilDistricts2001";

    var $spatial_fields_to_update = array(
        'fid',
        'name',
        'geom',
        'lastupdate',
        'shape_length',
        'shape_area',
    );

    var $sql = "SELECT objectid AS fid, wkb_geometry::geography::geometry AS geom, CONCAT(district, ' (', ord_no , ')') AS name, lastupdate, shape_length, shape_area  FROM public.councildistricts_2001;";

    function load_spatial()
    {

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
        }

        if (!$this->dry_run && count($this->active_spatial_ids)) {
            $this->totals['spatial']['inactive'] = $this->Areas->mark_inactive_if_not_in($this->active_spatial_ids);
        }

    }


    function load()
    {

        $address = new \Code4KC\Address\Address($this->dbh, true);

        $row = 0;

        if ( $query = $address->get_all_address_lat_lng() ) {

            $city_address_attributes = new \Code4KC\Address\CityAddressAttributes($this->dbh, true);

            while ($rec = $query->fetch(PDO::FETCH_ASSOC)) {

                $row++;
                $lng = $rec['longitude'];
                $lat = $rec['latitude'];
                $city_address_id = $rec['city_address_id'];

                if (empty($city_address_id)) {
                    $this->totals['city_address_attributes']['input']['N/A']++;
                    continue;
                }

                $cc_rec = $this->Areas->find_name_by_lng_lat($lng, $lat);

                if ($cc_rec) {       // We found a shape this address is in

                    $cc_rec['neighborhood_census'] = $cc_rec['name'];                                       // rename to source table field
                    unset($cc_rec['name']);

                    $new_rec = array('neighborhood_census' => $cc_rec['neighborhood_census']);

                    if ($city_address_attributes_rec = $city_address_attributes->find_by_id($city_address_id)) {
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
            }
        }
    }

    function display_record($line_number, $msg, $data)
    {

        printf("%10s: %5d %16.16s %s \n", $msg, $line_number, $data['district'], $data['ord_no']);
    }

    function display_rejected_record($line_number, $data, $data_errors)
    {

        printf("\nERROR: %5d %16.16s %s \n", $line_number, $data['district'], $data['ord_no']);
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
