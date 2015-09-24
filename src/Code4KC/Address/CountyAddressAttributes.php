<?php

namespace Code4KC\Address;

use \PDO as PDO;

/**
 * Class Address
 */
class CountyAddressAttributes extends BaseTable
{

    var $table_name = 'county_address_attributes';
    var $primary_key_sequence = null;
    var $fields = array(
        'id' => '',
        'gid' => '',
        'parcel_number' => '',
        'name' => '',
        'tif_district' => '',
        'tif_project' => '',
        'neighborhood_code' => '',
        'pca_code' => '',
        'land_use_code' => '',
        'tca_code' => '',
        'document_number' => '',
        'book_number' => '',
        'conveyance_area' => '',
        'conveyance_designator' => '',
        'legal_description' => '',
        'object_id' => '',
        'page_number' => '',
    );

}
