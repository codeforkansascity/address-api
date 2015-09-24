<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class CountyAddressData extends BaseTable
{

    var $table_name = 'county_address_data';
    var $primary_key_sequence = null;
    var $fields = array(
        'id' => '',
        'situs_address' => '',
        'situs_city' => '',
        'situs_state' => '',
        'situs_zip' => '',
        'owner' => '',
        'owner_address' => '',
        'owner_city' => '',
        'owner_state' => '',
        'owner_zip' => '',
        'stated_area' => '',
        'tot_sqf_l_area' => '',
        'year_built' => '',
        'property_area' => '',
        'property_picture' => '',
        'property_report' => '',
        'market_value' => '',
        'assessed_value' => '',
        'assessed_improvement' => '',
        'assessed_land' => '',
        'taxable_value' => '',
        'mtg_co' => '',
        'mtg_co_address' => '',
        'mtg_co_city' => '',
        'mtg_co_state' => '',
        'mtg_co_zip' => '',
        'common_area' => '',
        'floor_designator' => '',
        'floor_name_designator' => '',
        'exempt' => '',
        'complex_name' => '',
        'cid' => '',
        'eff_from_date' => '',
        'eff_to_date' => '',
        'extract_date' => '',
        'shape_st_area' => '',
        'shape_st_lenght' => '',
        'shape_st_area_1' => '',
        'shape_st_length_1' => '',
        'shape_st_legnth_2' => '',
        'shape_st_area_2' => '',
        'sim_con_div_type' => '',
        'tax_year' => '',
        'type' => '',
        'z_designator' => '',
    );

}
