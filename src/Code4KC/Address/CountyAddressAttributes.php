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
    var $id_auto_increment = false;                     // We are going to assigne the id field value
    var $fields = array(
        'id' => '',
        'gid' => 0,
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
        'object_id' => 0,
        'page_number' => '',
        'delinquent_tax_2010' => 0,
        'delinquent_tax_2011' => 0,
        'delinquent_tax_2012' => 0,
        'delinquent_tax_2013' => 0,
        'delinquent_tax_2014' => 0,
        'delinquent_tax_2015' => 0,
        'delinquent_tax_2016' => 0,
        'delinquent_tax_2017' => 0,
        'delinquent_tax_2018' => 0
    );

}
